import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diary_app/models/diary_entry.dart';
import 'package:diary_app/services/streak_service.dart';

DiaryEntry entryOn(DateTime date) => DiaryEntry(
      id: DiaryEntry.generateId(date),
      date: date,
      content: 'content',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime.now();
  DateTime dayAgo(int n) => DateTime(today.year, today.month, today.day)
      .subtract(Duration(days: n));

  group('StreakService.currentStreak', () {
    test('empty entries -> 0', () {
      expect(StreakService.currentStreak([]), 0);
    });

    test('today only -> 1', () {
      expect(StreakService.currentStreak([entryOn(dayAgo(0))]), 1);
    });

    test('today + yesterday -> 2', () {
      expect(
        StreakService.currentStreak([entryOn(dayAgo(0)), entryOn(dayAgo(1))]),
        2,
      );
    });

    test('yesterday only (not today) -> 1', () {
      expect(StreakService.currentStreak([entryOn(dayAgo(1))]), 1);
    });

    test('gap breaks the streak', () {
      // today, yesterday, then a gap, then older days
      final entries = [
        entryOn(dayAgo(0)),
        entryOn(dayAgo(1)),
        entryOn(dayAgo(3)),
        entryOn(dayAgo(4)),
      ];
      expect(StreakService.currentStreak(entries), 2);
    });

    test('only two days ago (no today/yesterday) -> 0', () {
      expect(StreakService.currentStreak([entryOn(dayAgo(2))]), 0);
    });

    test('duplicate same-day entries count once', () {
      expect(
        StreakService.currentStreak([entryOn(dayAgo(0)), entryOn(dayAgo(0))]),
        1,
      );
    });
  });

  group('StreakService.longestStreak', () {
    test('empty -> 0', () {
      expect(StreakService.longestStreak([]), 0);
    });

    test('finds the longest consecutive run', () {
      final entries = [
        entryOn(DateTime(2026, 1, 1)),
        entryOn(DateTime(2026, 1, 2)),
        entryOn(DateTime(2026, 1, 3)),
        entryOn(DateTime(2026, 1, 5)),
        entryOn(DateTime(2026, 1, 6)),
      ];
      expect(StreakService.longestStreak(entries), 3);
    });
  });

  group('StampService.sync', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('first entry earns the first-step stamp once', () async {
      final entries = [entryOn(DateTime(2026, 3, 1))];
      final first = await StampService.sync(entries);
      expect(first.map((s) => s.id), contains('first'));

      // second sync with same data earns nothing new
      final second = await StampService.sync(entries);
      expect(second, isEmpty);

      final earned = await StampService.earnedIds();
      expect(earned, contains('first'));
    });

    test('reaching 10 spread-out entries earns count10 (no streak stamp)',
        () async {
      final entries = List.generate(
        10,
        (i) => entryOn(DateTime(2026, 1, 1 + i * 3)),
      );
      final earned = await StampService.sync(entries);
      final ids = earned.map((s) => s.id).toSet();
      expect(ids, contains('first'));
      expect(ids, contains('count10'));
      expect(ids.contains('streak3'), isFalse);
    });

    test('a 3-day run earns the streak3 stamp', () async {
      final entries = [
        entryOn(DateTime(2026, 2, 1)),
        entryOn(DateTime(2026, 2, 2)),
        entryOn(DateTime(2026, 2, 3)),
      ];
      final earned = await StampService.sync(entries);
      expect(earned.map((s) => s.id), contains('streak3'));
    });
  });
}
