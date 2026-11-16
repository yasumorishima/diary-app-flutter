import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:diary_app/models/diary_entry.dart';
import 'package:diary_app/models/program_session.dart';
import 'package:diary_app/services/backup_payload.dart';

DiaryEntry _entry(String id, {String content = 'c', DateTime? updatedAt}) {
  final date = DateTime.parse('${id}T00:00:00');
  return DiaryEntry(
    id: id,
    date: date,
    content: content,
    mood: '🙂',
    tags: 'tag',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: updatedAt ?? DateTime(2026, 1, 1),
  );
}

ProgramSession _session(String id) {
  return ProgramSession(
    id: id,
    programType: 'tgt',
    dayIndex: 0,
    date: DateTime(2026, 1, 1),
    content: 'content',
    theme: '',
    durationSec: 0,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('buildBackupPayload / parseBackupPayload', () {
    test('v2 round-trip preserves entries and sessions', () {
      final entries = [
        _entry('2026-07-01', content: 'こんにちは\n改行あり'),
        _entry('2026-07-02', updatedAt: DateTime(2026, 7, 2, 12, 34, 56)),
      ];
      final sessions = [_session('tgt-2026-07-01')];

      final json =
          encodeBackupPayload(buildBackupPayload(entries, sessions));
      final parsed = parseBackupPayload(json);

      expect(parsed.entries.length, 2);
      expect(parsed.sessions.length, 1);
      final e = parsed.entries.firstWhere((e) => e.id == '2026-07-01');
      expect(e.content, 'こんにちは\n改行あり');
      expect(e.mood, '🙂');
      final e2 = parsed.entries.firstWhere((e) => e.id == '2026-07-02');
      // updatedAt は UTC で書き出されるため、時点（instant）で比較する
      expect(e2.updatedAt.isAtSameMomentAs(DateTime(2026, 7, 2, 12, 34, 56)),
          isTrue);
      expect(parsed.sessions.first.id, 'tgt-2026-07-01');
    });

    test('timestamps are serialized as UTC (timezone-safe merge)', () {
      final local = DateTime(2026, 7, 2, 12, 34, 56);
      final payload =
          buildBackupPayload([_entry('2026-07-02', updatedAt: local)], []);
      final entryJson =
          (payload['entries'] as List<dynamic>).first as Map<String, dynamic>;
      expect(entryJson['updatedAt'], endsWith('Z'));
      expect(
          DateTime.parse(entryJson['updatedAt'] as String)
              .isAtSameMomentAs(local),
          isTrue);
    });

    test('payload has version 2 with entries/programSessions keys', () {
      final payload = buildBackupPayload([_entry('2026-07-01')], []);
      expect(payload['version'], 2);
      expect(payload['entries'], isA<List<dynamic>>());
      expect(payload['programSessions'], isA<List<dynamic>>());
    });

    test('legacy array format is accepted', () {
      const legacy = '''
[
  {
    "id": "2026-06-30",
    "date": "2026-06-30T00:00:00.000",
    "content": "old format",
    "mood": "",
    "tags": "",
    "createdAt": "2026-06-30T10:00:00.000",
    "updatedAt": "2026-06-30T10:00:00.000"
  }
]
''';
      final parsed = parseBackupPayload(legacy);
      expect(parsed.entries.length, 1);
      expect(parsed.entries.first.content, 'old format');
      expect(parsed.sessions, isEmpty);
    });

    test('broken items are skipped, valid ones survive', () {
      const mixed = '''
{
  "version": 2,
  "entries": [
    {"id": "2026-07-01"},
    {
      "id": "2026-07-02",
      "date": "2026-07-02T00:00:00.000",
      "content": "valid",
      "createdAt": "2026-07-02T10:00:00.000",
      "updatedAt": "2026-07-02T10:00:00.000"
    }
  ],
  "programSessions": [{"id": "broken"}]
}
''';
      final parsed = parseBackupPayload(mixed);
      expect(parsed.entries.length, 1);
      expect(parsed.entries.first.id, '2026-07-02');
      expect(parsed.sessions, isEmpty);
    });
  });

  group('mergeEntries (復元: リモート→ローカル差分)', () {
    test('remote-only is inserted, newer remote updates, older remote ignored',
        () {
      final local = [
        _entry('2026-07-01', updatedAt: DateTime(2026, 7, 1, 10)),
        _entry('2026-07-02', updatedAt: DateTime(2026, 7, 2, 10)),
      ];
      final remote = [
        // ローカルより新しい → 上書き
        _entry('2026-07-01',
            content: 'newer', updatedAt: DateTime(2026, 7, 1, 12)),
        // ローカルより古い → 無視
        _entry('2026-07-02',
            content: 'older', updatedAt: DateTime(2026, 7, 2, 9)),
        // ローカルに無い → 追加
        _entry('2026-07-03'),
      ];

      final result = mergeEntries(local: local, remote: remote);
      expect(result.toInsert.map((e) => e.id), ['2026-07-03']);
      expect(result.toUpdate.map((e) => e.id), ['2026-07-01']);
      expect(result.toUpdate.first.content, 'newer');
    });

    test('exact same updatedAt keeps local (no update)', () {
      final t = DateTime(2026, 7, 1, 10);
      final local = [_entry('2026-07-01', content: 'local', updatedAt: t)];
      final remote = [_entry('2026-07-01', content: 'remote', updatedAt: t)];
      final result = mergeEntries(local: local, remote: remote);
      expect(result.isEmpty, true);
    });
  });

  group('unionNewestEntries (バックアップ: read-merge-write 用の和集合)', () {
    test('keeps newer of each id and union of both sides', () {
      final local = [
        _entry('2026-07-01',
            content: 'local-new', updatedAt: DateTime(2026, 7, 1, 12)),
        _entry('2026-07-04', content: 'local-only'),
      ];
      final remote = [
        _entry('2026-07-01',
            content: 'remote-old', updatedAt: DateTime(2026, 7, 1, 10)),
        _entry('2026-07-05', content: 'remote-only'),
      ];

      final merged = unionNewestEntries(local: local, remote: remote);
      expect(merged.length, 3);
      final byId = {for (final e in merged) e.id: e};
      // 同一 id はローカルの方が新しい → ローカルが残る
      expect(byId['2026-07-01']!.content, 'local-new');
      // 他端末だけが持つエントリーは失われない
      expect(byId['2026-07-05']!.content, 'remote-only');
      expect(byId['2026-07-04']!.content, 'local-only');
    });

    test('same updatedAt prefers local', () {
      final t = DateTime(2026, 7, 1, 10);
      final local = [_entry('2026-07-01', content: 'local', updatedAt: t)];
      final remote = [_entry('2026-07-01', content: 'remote', updatedAt: t)];
      final merged = unionNewestEntries(local: local, remote: remote);
      expect(merged.single.content, 'local');
    });
  });

  group('sessions', () {
    test('unionSessions merges by id with local priority', () {
      final local = [_session('a')];
      final remote = [_session('a'), _session('b')];
      final merged = unionSessions(local: local, remote: remote);
      expect(merged.map((s) => s.id).toSet(), {'a', 'b'});
    });

    test('missingSessions returns only sessions absent locally', () {
      final remote = [_session('a'), _session('b')];
      final missing = missingSessions(localIds: {'a'}, remote: remote);
      expect(missing.map((s) => s.id), ['b']);
    });
  });

  group('export/import file round-trip (in-app backup)', () {
    test('written .json file is listed, read, and parsed back', () async {
      final dir = await Directory.systemTemp.createTemp('diary_backup_test');
      addTearDown(() => dir.deleteSync(recursive: true));

      final entries = [
        _entry('2026-07-19', content: '写真は出ない\nテスト'),
        _entry('2026-07-20'),
      ];
      final sessions = [_session('tgt-2026-07-19')];

      // export が書くのと同じ経路: payload を .json として書き出す
      final json = encodeBackupPayload(buildBackupPayload(entries, sessions));
      await File('${dir.path}/diary_export_2026-07-20.json').writeAsString(json);

      // import が読むのと同じ経路: .json を列挙 → 読み込み → parse
      final listed = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.json'))
          .toList();
      expect(listed.length, 1);

      final readBack = parseBackupPayload(await listed.first.readAsString());
      expect(readBack.entries.map((e) => e.id).toSet(),
          {'2026-07-19', '2026-07-20'});
      expect(
          readBack.entries.firstWhere((e) => e.id == '2026-07-19').content,
          '写真は出ない\nテスト');
      expect(readBack.sessions.single.id, 'tgt-2026-07-19');
    });
  });
}
