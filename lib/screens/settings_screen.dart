import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/app_lock_service.dart';
import '../services/backup_payload.dart';
import '../services/database_service.dart';
import '../services/drive_backup_service.dart';
import '../services/program_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'onboarding_screen.dart';
import '../widgets/language_dialog.dart';

/// 設定画面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _db = DatabaseService();
  final _localAuth = LocalAuthentication();
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isDeleting = false;

  // リマインダー・アプリロック・バックアップ状態
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(
      hour: NotificationService.defaultHour,
      minute: NotificationService.defaultMinute);
  bool _appLockEnabled = false;
  DateTime? _lastBackupAt;

  // Google Drive バックアップ状態
  // 表示は SharedPreferences の記録だけで組み立てる（画面を開くたびに
  // サイレント認証を走らせると Google の「ログインしています」UI が毎回出るため）
  bool _driveSignedIn = false;
  String? _driveEmail;
  bool _driveAutoBackup = false;
  DateTime? _driveLastBackupAt;
  bool _driveBackupFailed = false;
  bool _driveBusy = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadDriveState();
  }

  Future<void> _loadDriveState() async {
    if (!DriveBackupService.isAvailable) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _driveSignedIn =
          prefs.getBool(AppConstants.prefDriveSignedIn) ?? false;
      _driveEmail = prefs.getString(AppConstants.prefDriveAccountEmail);
      _driveAutoBackup =
          prefs.getBool(AppConstants.prefDriveAutoBackup) ?? false;
      _driveLastBackupAt = DateTime.tryParse(
          prefs.getString(AppConstants.prefDriveLastBackupAt) ?? '');
      _driveBackupFailed =
          prefs.getString(AppConstants.prefDriveLastBackupError) != null;
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _reminderEnabled = prefs.getBool(NotificationService.prefEnabled) ?? false;
      _reminderTime = TimeOfDay(
        hour: prefs.getInt(NotificationService.prefHour) ??
            NotificationService.defaultHour,
        minute: prefs.getInt(NotificationService.prefMinute) ??
            NotificationService.defaultMinute,
      );
      _appLockEnabled = prefs.getBool(AppConstants.prefAppLockEnabled) ?? false;
      _lastBackupAt = DateTime.tryParse(
          prefs.getString(AppConstants.prefLastBackupAt) ?? '');
    });
  }

  // リマインダーのON/OFF
  Future<void> _toggleReminder(bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.reminderPermissionDenied),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      await NotificationService.instance.scheduleDaily(
        time: _reminderTime,
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
      );
    } else {
      await NotificationService.instance.cancelDaily();
    }
    await prefs.setBool(NotificationService.prefEnabled, enabled);
    if (mounted) {
      setState(() {
        _reminderEnabled = enabled;
      });
    }
  }

  // 通知時刻の変更
  Future<void> _pickReminderTime() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(NotificationService.prefHour, picked.hour);
    await prefs.setInt(NotificationService.prefMinute, picked.minute);
    if (_reminderEnabled) {
      await NotificationService.instance.scheduleDaily(
        time: picked,
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
      );
    }
    if (mounted) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  // アプリロックのON/OFF
  Future<void> _toggleAppLock(bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    if (enabled) {
      // 有効化前に、この端末で認証できることを必ず確認する
      // （認証手段が無いままONにすると次回起動時に締め出されるため）
      try {
        final supported = await _localAuth.isDeviceSupported();
        if (!supported) {
          throw PlatformException(code: 'NotSupported');
        }
        final ok = await _localAuth.authenticate(
          localizedReason: l10n.appLockReason,
          options: const AuthenticationOptions(stickyAuth: true),
        );
        if (!ok) return; // キャンセル時は変更しない
      } on PlatformException {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.appLockUnavailable),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }
    // メモリキャッシュ + SharedPreferences + FLAG_SECURE をまとめて更新
    await AppLockService.instance.setEnabled(enabled);
    if (mounted) {
      setState(() {
        _appLockEnabled = enabled;
      });
    }
  }

  // 最終バックアップ表示文字列
  String _lastBackupLabel(AppLocalizations l10n) {
    if (_lastBackupAt == null) return l10n.lastBackupNever;
    return l10n.lastBackup(DateFormat.yMd(
            Localizations.localeOf(context).toString())
        .format(_lastBackupAt!));
  }

  // データをJSON形式でエクスポート
  // バックアップの保存フォルダ（アプリ専用。OSのファイルピッカーは使わない）。
  // 端末のアプリ専用外部領域を優先（USB経由で見え、更新をまたいで残る）。
  Future<Directory> _backupDir() async {
    // getExternalStorageDirectory は Android 専用（iOS は null でなく throw）
    final base = Platform.isAndroid
        ? (await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory())
        : await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/backups');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // 一覧に出す各バックアップの表示ラベル（保存日時）。
  String _backupLabel(File f) {
    final locale = Localizations.localeOf(context).toString();
    final mod = f.statSync().modified;
    return DateFormat.yMMMd(locale).add_Hm().format(mod);
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final entries = await _db.getAllEntries();

      if (entries.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noExportData),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isExporting = false;
          });
        }
        return;
      }

      // v2 形式: プログラムセッションも含める（旧形式=配列も import 側で対応）
      // payload の組み立ては Drive バックアップと共通（backup_payload.dart）
      final sessions = await ProgramService().getAllSessions();
      final jsonString =
          encodeBackupPayload(buildBackupPayload(entries, sessions));
      final fileName = 'diary_export_${DateTime.now().toIso8601String().split('T')[0]}.json';

      if (kIsWeb) {
        // Web環境では非対応（テスト用）
        throw Exception('Export is not supported on web');
      }

      // アプリ専用のバックアップフォルダへ直接書き出す。OSの保存ダイアログを
      // 使わないので必ず既定の場所に残り、インポートの一覧から確実に選べる。
      final dir = await _backupDir();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(jsonString);

      // 最終バックアップ日時を記録（バックアップ促しバナーの基準）
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.prefLastBackupAt, now.toIso8601String());
      if (mounted) {
        setState(() {
          _lastBackupAt = now;
        });
      }

      // 「どこに保存されたか」が分かるよう共有シートも開き、任意で端末の見える場所
      // （ファイル/ダウンロード/Drive 等）へ保存できるようにする。共有をキャンセル
      // してもアプリ内には保存済みなので、復元は「インポート」からいつでも可能。
      if (mounted) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], subject: fileName),
        );
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportSuccess(entries.length)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  // データをJSON形式でインポート
  Future<void> _importData() async {
    setState(() {
      _isImporting = true;
    });

    final l10n = AppLocalizations.of(context)!;

    try {
      // アプリ専用のバックアップフォルダから選ぶ。OSのファイルピッカーを使わない
      // ので写真等が混ざらず（SAF/MIME非依存）、エクスポートしたjsonが必ず出る。
      final dir = await _backupDir();
      final backups = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.json'))
          .toList()
        ..sort((a, b) =>
            b.statSync().modified.compareTo(a.statSync().modified));

      if (backups.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noBackupsFound),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() {
            _isImporting = false;
          });
        }
        return;
      }

      if (!mounted) return;
      final selected = await showDialog<File>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => SimpleDialog(
            title: Text(l10n.importDialogTitle),
            children: [
              // 操作説明。復元=行タップ / 削除=ゴミ箱アイコン
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  l10n.importTapToRestore,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              for (final f in backups)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(dialogContext).pop(f),
                  child: Row(
                    children: [
                      Expanded(child: Text(_backupLabel(f))),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.deleteBackupTitle,
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: dialogContext,
                            builder: (context) => AlertDialog(
                              title: Text(l10n.deleteBackupTitle),
                              content: Text(
                                  l10n.deleteBackupMessage(_backupLabel(f))),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(l10n.cancel),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(l10n.delete),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true) return;
                          // 実ファイルを削除して一覧からも消す。ファイルが既に
                          // 無い場合（外部で消された等）も一覧からは消す。
                          try {
                            f.deleteSync();
                          } catch (_) {}
                          if (!dialogContext.mounted) return;
                          setDialogState(() {
                            backups.remove(f);
                          });
                          if (backups.isEmpty) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );

      if (selected == null) {
        // 選ばずに閉じた
        if (mounted) {
          setState(() {
            _isImporting = false;
          });
        }
        return;
      }

      // 対象はアプリ自身が書いた .json だが、USB 経由で外部から巨大ファイルを
      // 置かれる可能性があるため、防御として全読み込み前にサイズを確認する。
      if (selected.statSync().size > 20 * 1024 * 1024) {
        throw Exception(l10n.fileReadError);
      }
      // v2/旧形式の解析は Drive バックアップと共通（backup_payload.dart）
      final jsonString = await selected.readAsString();
      final parsed = parseBackupPayload(jsonString);
      final entries = parsed.entries;

      if (entries.isEmpty) {
        throw Exception(l10n.noValidData);
      }

      // 重複チェック
      final existingEntries = await _db.getAllEntries();
      final existingIds = existingEntries.map((e) => e.id).toSet();
      final newEntries = entries.where((e) => !existingIds.contains(e.id)).toList();
      final duplicateEntries = entries.where((e) => existingIds.contains(e.id)).toList();

      // 確認ダイアログ
      if (!mounted) return;
      // 重複がない場合はシンプルな確認
      // 重複がある場合はスキップ/上書きを選択
      // importAction: null=キャンセル, 'skip'=重複スキップ, 'overwrite'=上書き
      String? importAction;
      if (duplicateEntries.isEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.importDialogTitle),
            content: Text(l10n.importConfirmMessage(entries.length)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.import),
              ),
            ],
          ),
        );
        importAction = confirmed == true ? 'overwrite' : null;
      } else {
        importAction = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.importDialogTitle),
            content: Text(l10n.importConflictMessage(
              entries.length, newEntries.length, duplicateEntries.length)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(l10n.cancel),
              ),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop('skip'),
                child: Text(l10n.importSkipExisting),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop('overwrite'),
                child: Text(l10n.importOverwrite),
              ),
            ],
          ),
        );
      }

      if (importAction == null) {
        if (mounted) {
          setState(() {
            _isImporting = false;
          });
        }
        return;
      }

      // データをインポート
      final entriesToImport = importAction == 'skip' ? newEntries : entries;
      for (final entry in entriesToImport) {
        await _db.insertEntry(entry);
      }

      // プログラムセッション（v2）は id で上書き復元
      // （1件の失敗で残りを道連れにしない: 旧実装と同じ per-item ガード）
      final programService = ProgramService();
      for (final session in parsed.sessions) {
        try {
          await programService.upsert(session);
        } catch (_) {
          continue;
        }
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importSuccess(entriesToImport.length)),
            backgroundColor: Colors.green,
          ),
        );
        // ホーム画面に戻る
        Navigator.of(context).pop(true); // true = データ変更あり
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  // 全データを削除
  Future<void> _deleteAllData() async {
    final l10n = AppLocalizations.of(context)!;
    // 確認ダイアログ
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _db.deleteAllEntries();
      // 旧バージョンのプログラム記録（筆記開示等）も「全データ」に含める
      await ProgramService().deleteAllSessions();

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteSuccess),
            backgroundColor: Colors.green,
          ),
        );
        // ホーム画面に戻る
        Navigator.of(context).pop(true); // true = データ変更あり
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // ===== Google Drive バックアップ =====

  void _showDriveError(String message) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.driveError(message)),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _driveLastBackupLabel(AppLocalizations l10n) {
    if (_driveBackupFailed) return l10n.driveBackupFailed;
    if (_driveLastBackupAt == null) return l10n.driveBackupNever;
    return l10n.driveLastBackup(DateFormat.yMd(
            Localizations.localeOf(context).toString())
        .add_Hm()
        .format(_driveLastBackupAt!));
  }

  Future<void> _refreshDriveBackupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _driveSignedIn =
          prefs.getBool(AppConstants.prefDriveSignedIn) ?? false;
      _driveEmail = prefs.getString(AppConstants.prefDriveAccountEmail);
      _driveAutoBackup =
          prefs.getBool(AppConstants.prefDriveAutoBackup) ?? false;
      _driveLastBackupAt = DateTime.tryParse(
          prefs.getString(AppConstants.prefDriveLastBackupAt) ?? '');
      _driveBackupFailed =
          prefs.getString(AppConstants.prefDriveLastBackupError) != null;
    });
  }

  Future<void> _driveSignIn() async {
    setState(() => _driveBusy = true);
    try {
      final account = await DriveBackupService().signIn();
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _driveSignedIn = true;
          _driveEmail = account.email;
          _driveAutoBackup =
              prefs.getBool(AppConstants.prefDriveAutoBackup) ?? false;
        });
      }
    } on GoogleSignInException catch (e) {
      // ユーザーによるキャンセルは黙って戻る
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        _showDriveError(e.description ?? e.code.name);
      }
    } catch (e) {
      if (mounted) _showDriveError(e.toString());
    } finally {
      if (mounted) setState(() => _driveBusy = false);
    }
  }

  Future<void> _driveToggleAuto(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDriveAutoBackup, enabled);
    if (mounted) setState(() => _driveAutoBackup = enabled);
  }

  Future<void> _driveBackupNow() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _driveBusy = true);
    try {
      await DriveBackupService().backupNow(interactive: true);
      // single-flight で自動バックアップに相乗りした場合もあるため、
      // 成否は実際の記録状態（エラー有無）で判定する
      final prefs = await SharedPreferences.getInstance();
      final failed =
          prefs.getString(AppConstants.prefDriveLastBackupError) != null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                failed ? l10n.driveBackupFailed : l10n.driveBackupDone),
            backgroundColor: failed ? Colors.orange : Colors.green,
          ),
        );
      }
    } on GoogleSignInException catch (e) {
      // 再サインインのシートをユーザーが閉じた場合は黙って戻る
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        _showDriveError(e.description ?? e.code.name);
      }
    } catch (e) {
      if (mounted) _showDriveError(e.toString());
    } finally {
      await _refreshDriveBackupStatus();
      if (mounted) setState(() => _driveBusy = false);
    }
  }

  Future<void> _driveRestore() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.driveRestoreConfirmTitle),
        content: Text(l10n.driveRestoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.driveRestore),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _driveBusy = true);
    try {
      final result = await DriveBackupService().restore();
      if (mounted) {
        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driveNoBackup),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driveRestoreResult(
                  result.added, result.updated)),
              backgroundColor: Colors.green,
            ),
          );
          if (result.added > 0 || result.updated > 0) {
            // インポートと同様、ホームに「データ変更あり」を伝えて戻る
            Navigator.of(context).pop(true);
            return;
          }
        }
      }
    } on GoogleSignInException catch (e) {
      // 再サインインのシートをユーザーが閉じた場合は黙って戻る
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        _showDriveError(e.description ?? e.code.name);
      }
    } catch (e) {
      if (mounted) _showDriveError(e.toString());
    } finally {
      if (mounted) setState(() => _driveBusy = false);
    }
  }

  Future<void> _driveDeleteBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.driveDeleteBackup),
        content: Text(l10n.driveDeleteBackupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _driveBusy = true);
    try {
      await DriveBackupService().deleteBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.driveDeleteBackupDone),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on GoogleSignInException catch (e) {
      // 再サインインのシートをユーザーが閉じた場合は黙って戻る
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        _showDriveError(e.description ?? e.code.name);
      }
    } catch (e) {
      if (mounted) _showDriveError(e.toString());
    } finally {
      await _refreshDriveBackupStatus();
      if (mounted) setState(() => _driveBusy = false);
    }
  }

  Future<void> _driveSignOut() async {
    setState(() => _driveBusy = true);
    try {
      await DriveBackupService().signOut();
      if (mounted) {
        setState(() {
          _driveSignedIn = false;
          _driveEmail = null;
        });
      }
    } catch (e) {
      if (mounted) _showDriveError(e.toString());
    } finally {
      if (mounted) setState(() => _driveBusy = false);
    }
  }

  // URLを開く
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.urlOpenError,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // テーマ選択ダイアログを表示
  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.themeSelectTitle),
          content: RadioGroup<ThemeMode>(
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeLight),
                  subtitle: Text(l10n.themeLightDesc),
                  value: ThemeMode.light,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeDark),
                  subtitle: Text(l10n.themeDarkDesc),
                  value: ThemeMode.dark,
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeSystem),
                  subtitle: Text(l10n.themeSystemDesc),
                  value: ThemeMode.system,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 手順表示用ウィジェット
  Widget _buildStep(String number, String title, String description, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.green.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFe0e0e0) : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFb0b0b0) : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 言語名を取得（未選択=システム準拠なら実際に解決された言語を表示）
  String _getLanguageName(BuildContext context, Locale? locale) {
    final code =
        locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    return LocaleProvider.localeNames[code] ??
        LocaleProvider.localeNames['en']!;
  }

  // テーマモード名を取得（ローカライズ対応）
  String _getThemeModeName(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
      case ThemeMode.system:
        return l10n.themeSystem;
    }
  }

  // 言語選択ダイアログ
  Future<void> _showLanguageDialog(BuildContext context) =>
      showLanguageSelectDialog(context);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2c3e50), const Color(0xFF34495e)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      tooltip: l10n.a11yBack,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        '⚙️ ${l10n.settings}',
                        semanticsLabel: l10n.settings,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.wb_sunny : Icons.nightlight_round,
                        color: Colors.white,
                      ),
                      tooltip: isDark ? l10n.a11yLightMode : l10n.a11yDarkMode,
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),

              // メインコンテンツ
              Expanded(
                child: ListView(
                  children: [
          // 機種変更の説明カード
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF4a4a4a) : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.green.shade700, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      l10n.deviceMigration,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStep('1', l10n.migrationStep1, l10n.migrationStep1Desc, isDark),
                const SizedBox(height: 12),
                _buildStep('2', l10n.migrationStep2, l10n.migrationStep2Desc, isDark),
                const SizedBox(height: 12),
                _buildStep('3', l10n.migrationStep3, l10n.migrationStep3Desc, isDark),
                if (DriveBackupService.isAvailable) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.migrationDriveNote,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3d2d2d) : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.red.shade700 : Colors.red.shade200,
                    ),
                  ),
                  child: Text(
                    l10n.dataLossWarning,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 表示設定セクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.displaySettings,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // 言語切り替え
          ListTile(
            leading: const Icon(
              Icons.language,
              color: Colors.white,
            ),
            title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
            subtitle: Text(_getLanguageName(context, localeProvider.locale), style: const TextStyle(color: Colors.white70)),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
            onTap: () => _showLanguageDialog(context),
          ),

          // ダークモード切り替え
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: const Icon(
                  Icons.brightness_6,
                  color: Colors.white,
                ),
                title: Text(l10n.theme, style: const TextStyle(color: Colors.white)),
                subtitle: Text(_getThemeModeName(themeProvider.themeMode, l10n), style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
                onTap: () => _showThemeDialog(context, themeProvider),
              );
            },
          ),

          const SizedBox(height: 8),

          // リマインダーセクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.reminderSection,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // 毎日のリマインダー ON/OFF
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined,
                color: Colors.white),
            title: Text(l10n.reminderDaily,
                style: const TextStyle(color: Colors.white)),
            subtitle: Text(l10n.reminderDailyDesc,
                style: const TextStyle(color: Colors.white70)),
            value: _reminderEnabled,
            onChanged: kIsWeb ? null : _toggleReminder,
          ),

          // 通知時刻
          ListTile(
            enabled: _reminderEnabled,
            leading: const Icon(Icons.schedule, color: Colors.white),
            title: Text(l10n.reminderTime,
                style: TextStyle(
                    color: _reminderEnabled ? Colors.white : Colors.white38)),
            subtitle: Text(
              MaterialLocalizations.of(context).formatTimeOfDay(_reminderTime),
              style: TextStyle(
                  color: _reminderEnabled ? Colors.white70 : Colors.white38),
            ),
            trailing: Icon(Icons.chevron_right,
                color: _reminderEnabled ? Colors.white : Colors.white38),
            onTap: _reminderEnabled ? _pickReminderTime : null,
          ),

          const SizedBox(height: 8),

          // セキュリティセクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.securitySection,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // アプリロック ON/OFF
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline, color: Colors.white),
            title:
                Text(l10n.appLock, style: const TextStyle(color: Colors.white)),
            subtitle: Text(l10n.appLockDesc,
                style: const TextStyle(color: Colors.white70)),
            value: _appLockEnabled,
            onChanged: kIsWeb ? null : _toggleAppLock,
          ),

          const SizedBox(height: 8),

          // データ管理セクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.dataManagement,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // データエクスポート
          ListTile(
            leading: const Icon(
              Icons.download,
              color: Colors.white,
            ),
            title: Text(l10n.dataExport, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${l10n.dataExportDesc}\n${_lastBackupLabel(l10n)}',
              style: const TextStyle(color: Colors.white70),
            ),
            isThreeLine: true,
            trailing: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
            onTap: _isExporting ? null : _exportData,
          ),

          const Divider(height: 1),

          // データインポート
          ListTile(
            leading: const Icon(
              Icons.upload,
              color: Colors.white,
            ),
            title: Text(l10n.dataImport, style: const TextStyle(color: Colors.white)),
            subtitle: Text(l10n.dataImportDesc, style: const TextStyle(color: Colors.white70)),
            trailing: _isImporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
            onTap: _isImporting ? null : _importData,
          ),

          const Divider(height: 1),

          // 全データ削除
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              l10n.deleteAllData,
              style: const TextStyle(color: Colors.red),
            ),
            subtitle: Text(
              l10n.deleteAllDataDesc,
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right, color: Colors.red),
            onTap: _isDeleting ? null : _deleteAllData,
          ),

          const SizedBox(height: 16),

          // Google Drive バックアップセクション
          // （OAuth クライアント設定済み＝isAvailable のときだけ表示）
          if (DriveBackupService.isAvailable) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.driveSection,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            if (!_driveSignedIn)
              // 未ログイン: ログイン導線＋プライバシー説明
              ListTile(
                leading: const Icon(Icons.cloud_outlined, color: Colors.white),
                title: Text(l10n.driveSignIn,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(l10n.driveSignInDesc,
                    style: const TextStyle(color: Colors.white70)),
                isThreeLine: true,
                trailing: _driveBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.chevron_right, color: Colors.white),
                onTap: _driveBusy ? null : _driveSignIn,
              )
            else ...[
              // ログイン中アカウント
              ListTile(
                leading:
                    const Icon(Icons.account_circle, color: Colors.white),
                title: Text(_driveEmail ?? 'Google',
                    style: const TextStyle(color: Colors.white)),
              ),
              // 自動バックアップ
              SwitchListTile(
                secondary:
                    const Icon(Icons.cloud_sync_outlined, color: Colors.white),
                title: Text(l10n.driveAutoBackup,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(l10n.driveAutoBackupDesc,
                    style: const TextStyle(color: Colors.white70)),
                value: _driveAutoBackup,
                onChanged: _driveBusy ? null : _driveToggleAuto,
              ),
              const Divider(height: 1),
              // 今すぐバックアップ
              ListTile(
                leading:
                    const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                title: Text(l10n.driveBackupNow,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(_driveLastBackupLabel(l10n),
                    style: const TextStyle(color: Colors.white70)),
                trailing: _driveBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.chevron_right, color: Colors.white),
                onTap: _driveBusy ? null : _driveBackupNow,
              ),
              const Divider(height: 1),
              // 復元
              ListTile(
                leading: const Icon(Icons.cloud_download_outlined,
                    color: Colors.white),
                title: Text(l10n.driveRestore,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(l10n.driveRestoreDesc,
                    style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white),
                onTap: _driveBusy ? null : _driveRestore,
              ),
              const Divider(height: 1),
              // バックアップ削除（アカウントデータ削除導線）
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(l10n.driveDeleteBackup,
                    style: const TextStyle(color: Colors.red)),
                subtitle: Text(l10n.driveDeleteBackupDesc,
                    style: const TextStyle(color: Colors.white70)),
                onTap: _driveBusy ? null : _driveDeleteBackup,
              ),
              const Divider(height: 1),
              // ログアウト
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: Text(l10n.driveSignOut,
                    style: const TextStyle(color: Colors.white)),
                onTap: _driveBusy ? null : _driveSignOut,
              ),
            ],

            const SizedBox(height: 16),
          ],

          // アプリ情報セクション
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.appInfo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // バージョン情報
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: Text(l10n.version, style: const TextStyle(color: Colors.white)),
            subtitle: const Text(AppConstants.appVersion,
                style: TextStyle(color: Colors.white70)),
          ),

          const Divider(height: 1),

          // 使い方をもう一度見る
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: Text(l10n.howToUse, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const OnboardingScreen()),
              );
            },
          ),

          const Divider(height: 1),

          // 読み上げでつかうとき（TalkBack の入り口と、このアプリでの読み方）
          // 目が見えない人が最初に探す場所は設定なので、ここに置く。
          Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: const Icon(Icons.record_voice_over_outlined,
                  color: Colors.white),
              title: Text(l10n.a11yGuideTitle,
                  style: const TextStyle(color: Colors.white)),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Text(l10n.a11yGuideStart,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Text(l10n.a11yGuideNames,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Text(l10n.a11yGuideCalendar,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          const Divider(height: 1),

          // アプリ名
          ListTile(
            leading: const Icon(Icons.book, color: Colors.white),
            title: Text(l10n.appName, style: const TextStyle(color: Colors.white)),
            subtitle: const Text(AppConstants.appName, style: TextStyle(color: Colors.white70)),
          ),

          const Divider(height: 1),

          // こども向け学習サイト（中身が日本語のみなので ja のときだけ出す）
          if (Localizations.localeOf(context).languageCode == 'ja') ...[
            ListTile(
              leading: const Icon(Icons.school_outlined, color: Colors.white),
              title: Text(l10n.kidsSite,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(l10n.kidsSiteDesc,
                  style: const TextStyle(color: Colors.white70)),
              trailing: const Icon(Icons.open_in_new, color: Colors.white),
              onTap: () => _launchURL(AppConstants.kidsSiteUrl),
            ),

            const Divider(height: 1),
          ],

          // プライバシーポリシー
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white),
            title: Text(l10n.privacyPolicy, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.open_in_new, color: Colors.white),
            onTap: () {
              final locale = Localizations.localeOf(context).languageCode;
              final url = locale == 'ja'
                  ? 'https://yasumorishima.github.io/diary-app-flutter-privacy/privacy-policy-ja'
                  : 'https://yasumorishima.github.io/diary-app-flutter-privacy/privacy-policy-en';
              _launchURL(url);
            },
          ),

          const Divider(height: 1),

          // 利用規約
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.white),
            title: Text(l10n.termsOfService, style: const TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.open_in_new, color: Colors.white),
            onTap: () {
              final locale = Localizations.localeOf(context).languageCode;
              final url = locale == 'ja'
                  ? 'https://yasumorishima.github.io/diary-app-flutter-privacy/terms-of-service-ja'
                  : 'https://yasumorishima.github.io/diary-app-flutter-privacy/terms-of-service-en';
              _launchURL(url);
            },
          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
