import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:diary_app/models/program_session.dart';
import 'package:diary_app/services/program_service.dart';

void main() {
  late Directory tempDir;
  final service = ProgramService();

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_program_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(ProgramSessionAdapter());
  });

  setUp(() async {
    final box = await service.box;
    await box.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  ProgramSession session(String type, DateTime date,
          {int day = 1, String theme = ''}) =>
      ProgramSession(
        id: ProgramSession.generateId(type, date),
        programType: type,
        dayIndex: day,
        date: date,
        content: 'content',
        theme: theme,
      );

  test('generateId は日付ベースの ID を作る', () {
    expect(
      ProgramSession.generateId(
          ProgramSession.typePennebaker, DateTime(2026, 7, 5)),
      'pennebaker-2026-07-05',
    );
  });

  test('upsert は同 ID を上書きする', () async {
    final date = DateTime(2026, 7, 1);
    await service.upsert(session(ProgramSession.typePennebaker, date));
    await service.upsert(session(ProgramSession.typePennebaker, date));
    final sessions = await service.byType(ProgramSession.typePennebaker);
    expect(sessions.length, 1);
  });

  test('byType は種別で絞り日付昇順で返す', () async {
    await service.upsert(
        session(ProgramSession.typePennebaker, DateTime(2026, 7, 2)));
    await service.upsert(
        session(ProgramSession.typePennebaker, DateTime(2026, 7, 1)));
    await service.upsert(
        session(ProgramSession.typeThreeGoodThings, DateTime(2026, 7, 1)));
    final sessions = await service.byType(ProgramSession.typePennebaker);
    expect(sessions.length, 2);
    expect(sessions.first.date.day, 1);
  });

  test('pennebakerState はコース進行を返す', () async {
    var state = await service.pennebakerState();
    expect(state.completedDays, 0);
    expect(state.theme, isNull);

    await service.upsert(session(
        ProgramSession.typePennebaker, DateTime(2026, 7, 1),
        day: 1, theme: 'A'));
    await service.upsert(session(
        ProgramSession.typePennebaker, DateTime(2026, 7, 2),
        day: 2, theme: 'A'));
    state = await service.pennebakerState();
    expect(state.theme, 'A');
    expect(state.completedDays, 2);
    expect(state.nextDay, 3);
    expect(state.completed, isFalse);
  });

  test('新しいテーマで書くとコースがリセットされる', () async {
    for (var d = 1; d <= 4; d++) {
      await service.upsert(session(
          ProgramSession.typePennebaker, DateTime(2026, 6, d),
          day: d, theme: 'A'));
    }
    var state = await service.pennebakerState();
    expect(state.completed, isTrue);

    await service.upsert(session(
        ProgramSession.typePennebaker, DateTime(2026, 7, 1),
        day: 1, theme: 'B'));
    state = await service.pennebakerState();
    expect(state.theme, 'B');
    expect(state.completedDays, 1);
    expect(state.completed, isFalse);
  });

  test('threeGoodThingsDoneToday は今日のセッション有無を返す', () async {
    expect(await service.threeGoodThingsDoneToday(), isFalse);
    await service.upsert(
        session(ProgramSession.typeThreeGoodThings, DateTime.now()));
    expect(await service.threeGoodThingsDoneToday(), isTrue);
  });
}
