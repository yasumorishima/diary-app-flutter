import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:diary_app/models/diary_entry.dart';
import 'package:diary_app/services/database_service.dart';

void main() {
  late Directory tempDir;
  final db = DatabaseService();

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(DiaryEntryAdapter());
    await db.initDatabase();
  });

  setUp(() async {
    await db.deleteAllEntries();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  DiaryEntry entry(DateTime date, {String content = 'content', String tags = ''}) =>
      DiaryEntry(
        id: DiaryEntry.generateId(date),
        date: date,
        content: content,
        tags: tags,
      );

  test('insert and read back by date', () async {
    await db.insertEntry(entry(DateTime(2026, 1, 1), content: 'hello'));
    final got = await db.getEntryByDate(DateTime(2026, 1, 1));
    expect(got, isNotNull);
    expect(got!.content, 'hello');
  });

  test('same date overwrites instead of duplicating', () async {
    await db.insertEntry(entry(DateTime(2026, 1, 1), content: 'first'));
    await db.insertEntry(entry(DateTime(2026, 1, 1), content: 'second'));
    final all = await db.getAllEntries();
    expect(all.length, 1);
    expect(all.first.content, 'second');
  });

  test('search is case-insensitive for content and tags', () async {
    await db.insertEntry(entry(DateTime(2026, 1, 1), content: 'Visited Tokyo Tower'));
    await db.insertEntry(entry(DateTime(2026, 1, 2), content: 'rainy day', tags: 'Weather'));

    expect((await db.search('tokyo')).length, 1);
    expect((await db.search('TOKYO')).length, 1);
    expect((await db.search('Tokyo')).length, 1);
    expect((await db.search('weather')).length, 1);
    expect((await db.search('sunny')).length, 0);
  });

  test('getAllEntries sorts newest first', () async {
    await db.insertEntry(entry(DateTime(2026, 1, 1)));
    await db.insertEntry(entry(DateTime(2026, 3, 1)));
    await db.insertEntry(entry(DateTime(2026, 2, 1)));
    final all = await db.getAllEntries();
    expect(all.map((e) => e.id).toList(),
        ['2026-03-01', '2026-02-01', '2026-01-01']);
  });

  test('search matches content and tags', () async {
    await db.insertEntry(entry(DateTime(2026, 1, 1), content: 'baseball practice'));
    await db.insertEntry(entry(DateTime(2026, 1, 2), content: 'rest day', tags: 'baseball,rest'));
    await db.insertEntry(entry(DateTime(2026, 1, 3), content: 'unrelated'));
    final hits = await db.search('baseball');
    expect(hits.length, 2);
  });

  test('delete removes a single entry', () async {
    await db.insertEntry(entry(DateTime(2026, 1, 1)));
    await db.insertEntry(entry(DateTime(2026, 1, 2)));
    await db.delete('2026-01-01');
    final all = await db.getAllEntries();
    expect(all.length, 1);
    expect(all.first.id, '2026-01-02');
  });

  test('readPastToday returns same month-day from past years only', () async {
    final now = DateTime.now();
    if (now.month == 2 && now.day == 29) {
      // 2/29 is absent in non-leap years; DateTime(year-1, 2, 29) rolls over.
      markTestSkipped('skipped on leap day');
      return;
    }
    await db.insertEntry(
        entry(DateTime(now.year - 1, now.month, now.day), content: 'last year'));
    await db.insertEntry(
        entry(DateTime(now.year, now.month, now.day), content: 'this year'));
    final past = await db.readPastToday();
    expect(past.length, 1);
    expect(past.first.content, 'last year');
  });
}
