import 'dart:convert';

import '../models/diary_entry.dart';
import '../models/program_session.dart';

/// バックアップ payload（export v2 形式）の生成・解析・マージ。
/// 設定画面のファイルエクスポート/インポートと Google Drive バックアップで共用する
/// 単一ソース（形式が二重実装で食い違うのを防ぐ）。
///
/// v2 形式: {"version": 2, "entries": [...], "programSessions": [...]}
/// 旧形式（エントリー配列のみ）も parse 側で受け付ける。
class ParsedBackup {
  final List<DiaryEntry> entries;
  final List<ProgramSession> sessions;

  const ParsedBackup({required this.entries, required this.sessions});
}

/// マージ結果（復元時の UI 表示用に件数を分けて返す）
class EntryMergeResult {
  /// ローカルに存在しない → 追加
  final List<DiaryEntry> toInsert;

  /// ローカルより updatedAt が新しい → 上書き
  final List<DiaryEntry> toUpdate;

  const EntryMergeResult({required this.toInsert, required this.toUpdate});

  bool get isEmpty => toInsert.isEmpty && toUpdate.isEmpty;
}

Map<String, dynamic> entryToJson(DiaryEntry entry) => {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'content': entry.content,
      'mood': entry.mood,
      'tags': entry.tags,
      // UTC で書く（端末のタイムゾーン差で新旧判定がズレないように）
      'createdAt': entry.createdAt.toUtc().toIso8601String(),
      'updatedAt': entry.updatedAt.toUtc().toIso8601String(),
    };

Map<String, dynamic> sessionToJson(ProgramSession session) => {
      'id': session.id,
      'programType': session.programType,
      'dayIndex': session.dayIndex,
      'date': session.date.toIso8601String(),
      'content': session.content,
      'theme': session.theme,
      'durationSec': session.durationSec,
      'createdAt': session.createdAt.toUtc().toIso8601String(),
    };

/// v2 形式の payload を組み立てる
Map<String, dynamic> buildBackupPayload(
    List<DiaryEntry> entries, List<ProgramSession> sessions) {
  return {
    'version': 2,
    'entries': entries.map(entryToJson).toList(),
    'programSessions': sessions.map(sessionToJson).toList(),
  };
}

/// エクスポートと同一の整形（インデント2）で JSON 文字列化
String encodeBackupPayload(Map<String, dynamic> payload) {
  return const JsonEncoder.withIndent('  ').convert(payload);
}

/// JSON 文字列を解析。v2 形式と旧形式（配列）の両対応。
/// 個々の壊れた要素はスキップする（既存インポートと同じ寛容さ）。
ParsedBackup parseBackupPayload(String jsonString) {
  final decoded = jsonDecode(jsonString);
  final List<dynamic> entriesJson;
  var sessionsJson = const <dynamic>[];
  if (decoded is Map<String, dynamic>) {
    entriesJson = decoded['entries'] as List<dynamic>? ?? <dynamic>[];
    sessionsJson =
        decoded['programSessions'] as List<dynamic>? ?? const <dynamic>[];
  } else {
    entriesJson = decoded as List<dynamic>;
  }

  final entries = <DiaryEntry>[];
  for (final item in entriesJson) {
    try {
      entries.add(DiaryEntry(
        id: item['id'] as String,
        date: DateTime.parse(item['date'] as String),
        content: item['content'] as String,
        mood: item['mood'] as String? ?? '',
        tags: item['tags'] as String? ?? '',
        createdAt: DateTime.parse(item['createdAt'] as String),
        updatedAt: DateTime.parse(item['updatedAt'] as String),
      ));
    } catch (_) {
      continue; // 無効なエントリーはスキップ
    }
  }

  final sessions = <ProgramSession>[];
  for (final item in sessionsJson) {
    try {
      sessions.add(ProgramSession(
        id: item['id'] as String,
        programType: item['programType'] as String,
        dayIndex: item['dayIndex'] as int? ?? 0,
        date: DateTime.parse(item['date'] as String),
        content: item['content'] as String,
        theme: item['theme'] as String? ?? '',
        durationSec: item['durationSec'] as int? ?? 0,
        createdAt: DateTime.parse(item['createdAt'] as String),
      ));
    } catch (_) {
      continue; // 無効なセッションはスキップ
    }
  }

  return ParsedBackup(entries: entries, sessions: sessions);
}

/// リモートをローカルへ取り込む差分を計算する。
/// - ローカルに無い id → toInsert
/// - 両方にあり、リモートの updatedAt が新しい → toUpdate
/// - 同時刻（ms 単位で同値）はローカルを保持（決定的なタイブレーク）
EntryMergeResult mergeEntries({
  required List<DiaryEntry> local,
  required List<DiaryEntry> remote,
}) {
  final localById = {for (final e in local) e.id: e};
  final toInsert = <DiaryEntry>[];
  final toUpdate = <DiaryEntry>[];
  for (final r in remote) {
    final l = localById[r.id];
    if (l == null) {
      toInsert.add(r);
    } else if (r.updatedAt.millisecondsSinceEpoch >
        l.updatedAt.millisecondsSinceEpoch) {
      toUpdate.add(r);
    }
  }
  return EntryMergeResult(toInsert: toInsert, toUpdate: toUpdate);
}

/// アップロード用: ローカルとリモートの和集合（同一 id は updatedAt が新しい方、
/// 同時刻はローカル優先）。丸ごと上書きで他端末の新しいエントリーを
/// 失わないための read-merge-write に使う。
List<DiaryEntry> unionNewestEntries({
  required List<DiaryEntry> local,
  required List<DiaryEntry> remote,
}) {
  final byId = <String, DiaryEntry>{for (final r in remote) r.id: r};
  for (final l in local) {
    final r = byId[l.id];
    if (r == null ||
        l.updatedAt.millisecondsSinceEpoch >=
            r.updatedAt.millisecondsSinceEpoch) {
      byId[l.id] = l;
    }
  }
  final merged = byId.values.toList();
  merged.sort((a, b) => b.date.compareTo(a.date));
  return merged;
}

/// セッションの和集合（id 単位・既存優先で欠けている方を足すだけ）
List<ProgramSession> unionSessions({
  required List<ProgramSession> local,
  required List<ProgramSession> remote,
}) {
  final byId = <String, ProgramSession>{for (final r in remote) r.id: r};
  for (final l in local) {
    byId[l.id] = l;
  }
  return byId.values.toList();
}

/// 復元用: ローカルに無いセッションだけ返す
List<ProgramSession> missingSessions({
  required Set<String> localIds,
  required List<ProgramSession> remote,
}) {
  return remote.where((s) => !localIds.contains(s.id)).toList();
}
