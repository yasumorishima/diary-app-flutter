import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';
import '../utils/constants.dart';
import 'backup_payload.dart';
import 'database_service.dart';
import 'program_service.dart';

/// 復元結果（設定画面のスナックバー表示用）
class DriveRestoreResult {
  final int added;
  final int updated;

  const DriveRestoreResult({required this.added, required this.updated});
}

/// ダウンロードしたリモートバックアップ（解析失敗時も生データを保持する）
class _RemoteBackup {
  final String raw;
  final ParsedBackup? parsed;

  const _RemoteBackup(this.raw, this.parsed);
}

/// Google Drive appDataFolder への日記バックアップ。
///
/// 方針:
/// - ログインは任意（既定はローカルのみ・従来 UX 無変更）。
/// - データはユーザー自身の Google Drive の appDataFolder（このアプリ専用の
///   隠し領域）にのみ保存され、開発者側には一切送信されない。
/// - バックアップは read-merge-write（リモートを読み→和集合→書き戻し）で、
///   複数端末が交互に上書きしても新しいエントリーが失われない。
/// - 自動バックアップは保存後デバウンス（45秒）＋バックグラウンド遷移時に即時。
/// - GoogleSignIn の初期化は遅延（起動時に呼ばない。widget テストを壊さない）。
class DriveBackupService with WidgetsBindingObserver {
  static final DriveBackupService _instance = DriveBackupService._internal();
  factory DriveBackupService() => _instance;
  DriveBackupService._internal();

  static const List<String> _scopes = [drive.DriveApi.driveAppdataScope];
  static const String _backupFileName = 'diary_backup.json';
  static const String _corruptFileName = 'diary_backup.corrupt.json';
  static const Duration _autoBackupDebounce = Duration(seconds: 45);

  bool _initialized = false;
  GoogleSignInAccount? _account;
  Timer? _debounce;
  bool _observing = false;
  Future<void>? _inFlight;

  /// 機能が有効か（OAuth クライアント設定済みかつ非 Web）。
  /// serverClientId 未設定の間は設定画面に一切出さない（安全な段階リリース）。
  static bool get isAvailable =>
      !kIsWeb && AppConstants.googleServerClientId.isNotEmpty;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance
        .initialize(serverClientId: AppConstants.googleServerClientId);
    _initialized = true;
  }

  /// サイレント復帰。未サインインなら null。
  /// attemptLightweightAuthentication はプラットフォームの
  /// 「ログインしています」オーバーレイを出すことがあるため、
  /// ①アプリ内でサインイン済みの記録がある場合のみ試行し、
  /// ②結果をプロセス内にキャッシュして試行を最大1回にする。
  Future<GoogleSignInAccount?> silentAccount() async {
    if (!isAvailable) return null;
    final cached = _account;
    if (cached != null) return cached;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(AppConstants.prefDriveSignedIn) != true) return null;
      await _ensureInitialized();
      final attempt = GoogleSignIn.instance.attemptLightweightAuthentication();
      if (attempt == null) return null;
      final account = await attempt;
      _account = account;
      return account;
    } catch (_) {
      return null;
    }
  }

  /// 対話的サインイン（設定画面のログインタイルから）。
  /// 成功時はスコープ同意まで済ませ、自動バックアップを既定 ON にする。
  Future<GoogleSignInAccount> signIn() async {
    await _ensureInitialized();
    final account =
        await GoogleSignIn.instance.authenticate(scopeHint: _scopes);
    await account.authorizationClient.authorizeScopes(_scopes);
    _account = account;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDriveSignedIn, true);
    await prefs.setString(AppConstants.prefDriveAccountEmail, account.email);
    if (!prefs.containsKey(AppConstants.prefDriveAutoBackup)) {
      await prefs.setBool(AppConstants.prefDriveAutoBackup, true);
    }
    return account;
  }

  /// サインアウト（Drive 上のバックアップは残す）
  Future<void> signOut() async {
    await _ensureInitialized();
    _debounce?.cancel();
    await GoogleSignIn.instance.signOut();
    _account = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDriveSignedIn, false);
    await prefs.remove(AppConstants.prefDriveAccountEmail);
  }

  /// 認証済み HTTP クライアントを作る。
  /// [interactive] = true なら必要に応じて同意 UI を出す。false なら
  /// サイレントで取れない場合に null を返す（自動バックアップ経路）。
  Future<http.Client?> _authedClient(GoogleSignInAccount account,
      {required bool interactive}) async {
    var headers =
        await account.authorizationClient.authorizationHeaders(_scopes);
    if (headers == null && interactive) {
      await account.authorizationClient.authorizeScopes(_scopes);
      headers =
          await account.authorizationClient.authorizationHeaders(_scopes);
    }
    if (headers == null) return null;
    return _AuthenticatedClient(headers);
  }

  Future<drive.File?> _findBackupFile(drive.DriveApi api) =>
      _findFileByName(api, _backupFileName);

  Future<drive.File?> _findFileByName(drive.DriveApi api, String name) async {
    final list = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$name'",
      $fields: 'files(id, modifiedTime)',
    );
    final files = list.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  Future<_RemoteBackup> _downloadBackup(
      drive.DriveApi api, String fileId) async {
    final media = await api.files.get(fileId,
        downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;
    final bytes = <int>[];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }
    final raw = utf8.decode(bytes, allowMalformed: true);
    try {
      return _RemoteBackup(raw, parseBackupPayload(raw));
    } catch (_) {
      // 解析できないリモート。呼び出し側で退避してから上書きする
      return _RemoteBackup(raw, null);
    }
  }

  /// 解析できないリモートバックアップを退避コピーとして残す。
  /// そのまま上書きすると唯一のバックアップを失うため（退避に失敗した
  /// 場合は例外がそのまま伝播し、上書きは行われない）。
  Future<void> _preserveCorruptRemote(drive.DriveApi api, String raw) async {
    final bytes = utf8.encode(raw);
    final media = drive.Media(Stream.value(bytes), bytes.length,
        contentType: 'application/json');
    final existing = await _findFileByName(api, _corruptFileName);
    if (existing?.id == null) {
      await api.files.create(
        drive.File()
          ..name = _corruptFileName
          ..parents = ['appDataFolder'],
        uploadMedia: media,
      );
    } else {
      await api.files.update(drive.File(), existing!.id!, uploadMedia: media);
    }
  }

  /// バックアップ実行（read-merge-write）。
  /// リモートの新しいエントリーを取り込んだ和集合をアップロードする。
  /// 成功時は最終バックアップ日時を記録し、失敗時はエラー状態を記録する。
  /// 実行中に再度呼ばれた場合は進行中の1回に相乗りする（single-flight）。
  Future<void> backupNow({required bool interactive}) async {
    final existing = _inFlight;
    if (existing != null) {
      if (!interactive) return existing;
      // 手動実行はサイレント実行の結果に相乗りせず、完了を待って
      // 自分で1回実行する（サイレント側が no-op でも嘘の成功にしない）
      try {
        await existing;
      } catch (_) {}
    }
    final run = _doBackup(interactive: interactive);
    _inFlight = run.whenComplete(() {
      _inFlight = null;
    });
    return _inFlight!;
  }

  Future<void> _doBackup({required bool interactive}) async {
    if (!isAvailable) return;
    try {
      var account = await silentAccount();
      if (account == null) {
        if (!interactive) return;
        // サインイン記録と実セッションがズレていたらその場で再サインイン
        account = await signIn();
      }
      final client = await _authedClient(account, interactive: interactive);
      if (client == null) return; // サイレントで認可が取れない → 何もしない
      try {
        final api = drive.DriveApi(client);
        final localEntries = await DatabaseService().getAllEntries();
        final localSessions = await ProgramService().getAllSessions();

        final existing = await _findBackupFile(api);
        var entries = localEntries;
        var sessions = localSessions;
        if (existing?.id != null) {
          final remote = await _downloadBackup(api, existing!.id!);
          final parsed = remote.parsed;
          if (parsed != null) {
            entries =
                unionNewestEntries(local: localEntries, remote: parsed.entries);
            sessions =
                unionSessions(local: localSessions, remote: parsed.sessions);
          } else {
            await _preserveCorruptRemote(api, remote.raw);
          }
        }

        final jsonString =
            encodeBackupPayload(buildBackupPayload(entries, sessions));
        final bytes = utf8.encode(jsonString);
        final media = drive.Media(Stream.value(bytes), bytes.length,
            contentType: 'application/json');
        if (existing?.id == null) {
          await api.files.create(
            drive.File()
              ..name = _backupFileName
              ..parents = ['appDataFolder'],
            uploadMedia: media,
          );
        } else {
          await api.files.update(drive.File(), existing!.id!,
              uploadMedia: media);
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.prefDriveLastBackupAt,
            DateTime.now().toIso8601String());
        await prefs.remove(AppConstants.prefDriveLastBackupError);
      } finally {
        client.close();
      }
    } catch (e) {
      // 再サインインのシートを閉じただけの場合は「失敗」として記録しない
      // （残留する失敗表示を防ぐ。呼び出し側が黙って戻る）
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        if (interactive) rethrow;
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.prefDriveLastBackupError, e.toString());
      if (interactive) rethrow;
    }
  }

  /// Drive のバックアップをローカルへ取り込む（追加＋新しい方で上書き）。
  /// バックアップが無い場合は null を返す。
  Future<DriveRestoreResult?> restore() async {
    // 実行中の自動バックアップと競合しないよう、完了を待ってから読む
    final inflight = _inFlight;
    if (inflight != null) {
      try {
        await inflight;
      } catch (_) {}
    }
    var account = await silentAccount();
    account ??= await signIn();
    final client = await _authedClient(account, interactive: true);
    if (client == null) throw StateError('authorization failed');
    try {
      final api = drive.DriveApi(client);
      final existing = await _findBackupFile(api);
      if (existing?.id == null) return null;
      final remote = (await _downloadBackup(api, existing!.id!)).parsed;
      if (remote == null) return null;

      final db = DatabaseService();
      final localEntries = await db.getAllEntries();
      final result = mergeEntries(local: localEntries, remote: remote.entries);
      // insertEntry は渡した updatedAt を保持する（updateEntry は now で
      // 上書きするため同期用途では使わない）
      for (final entry in [...result.toInsert, ...result.toUpdate]) {
        await db.insertEntry(_detached(entry));
      }

      final programService = ProgramService();
      final localSessions = await programService.getAllSessions();
      final missing = missingSessions(
        localIds: localSessions.map((s) => s.id).toSet(),
        remote: remote.sessions,
      );
      for (final session in missing) {
        try {
          await programService.upsert(session);
        } catch (_) {
          continue; // 1件の失敗で残りを道連れにしない
        }
      }

      return DriveRestoreResult(
          added: result.toInsert.length, updated: result.toUpdate.length);
    } finally {
      client.close();
    }
  }

  /// Drive 上のバックアップファイルを削除（端末内データは残す）。
  /// アカウント削除導線（Play ポリシー対応）として設定画面から呼ぶ。
  Future<void> deleteBackup() async {
    // 保留タイマー/実行中の自動バックアップが削除直後にファイルを
    // 再生成しないよう、止めて・待ってから削除する
    _debounce?.cancel();
    final inflight = _inFlight;
    if (inflight != null) {
      try {
        await inflight;
      } catch (_) {}
    }
    var account = await silentAccount();
    account ??= await signIn();
    final client = await _authedClient(account, interactive: true);
    if (client == null) throw StateError('authorization failed');
    try {
      final api = drive.DriveApi(client);
      for (final name in [_backupFileName, _corruptFileName]) {
        final existing = await _findFileByName(api, name);
        if (existing?.id != null) {
          await api.files.delete(existing!.id!);
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefDriveLastBackupAt);
      await prefs.remove(AppConstants.prefDriveLastBackupError);
      // 削除直後に自動バックアップが再アップロードしないよう OFF に戻す
      await prefs.setBool(AppConstants.prefDriveAutoBackup, false);
    } finally {
      client.close();
    }
  }

  /// 日記保存後フック（write_screen から呼ぶ）。
  /// 自動バックアップ ON かつサインイン済みのときだけ、デバウンスして
  /// サイレント実行する。UI をブロックせず、失敗しても保存は成功扱い。
  Future<void> onEntrySaved() async {
    if (!isAvailable) return;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(AppConstants.prefDriveSignedIn) ?? false)) return;
    if (!(prefs.getBool(AppConstants.prefDriveAutoBackup) ?? false)) return;
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    _debounce?.cancel();
    _debounce = Timer(_autoBackupDebounce, () {
      unawaited(backupNow(interactive: false));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // アプリがバックグラウンドへ → 保留中の自動バックアップを即時実行
    if (state == AppLifecycleState.paused && _debounce?.isActive == true) {
      _debounce!.cancel();
      unawaited(backupNow(interactive: false));
    }
  }

  /// Hive オブジェクトの二重所属を避けるためのコピー
  DiaryEntry _detached(DiaryEntry e) => DiaryEntry(
        id: e.id,
        date: e.date,
        content: e.content,
        mood: e.mood,
        tags: e.tags,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}

/// Authorization ヘッダを付与するだけの薄い HTTP クライアント
class _AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
