import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../utils/constants.dart';

/// 連続記録日数の算出（純粋関数、テスト可能）。
class StreakService {
  StreakService._();

  // 日付は UTC の深夜0時に正規化して扱う（ローカル DateTime の日数演算は
  // DST のある地域で 23/25 時間の日をまたぐと 1 日ズレるため）
  static Set<DateTime> _uniqueDays(List<DiaryEntry> entries) {
    return entries
        .map((e) => DateTime.utc(e.date.year, e.date.month, e.date.day))
        .toSet();
  }

  /// 現在の連続日数。今日（未記入なら昨日）から遡って連続する日数を数える。
  static int currentStreak(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 0;
    final days = _uniqueDays(entries);
    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    DateTime cursor;
    if (days.contains(today)) {
      cursor = today;
    } else if (days.contains(yesterday)) {
      cursor = yesterday;
    } else {
      return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// 過去最長の連続日数。
  static int longestStreak(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 0;
    final days = _uniqueDays(entries).toList()..sort();
    var longest = 1;
    var current = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}

/// 集めるスタンプ（絵文字＋ID）。名前はUI側でローカライズする。
class Stamp {
  final String id;
  final String emoji;
  const Stamp(this.id, this.emoji);
}

/// スタンプ（ごほうび）の付与・永続化。
///
/// エントリー総数と最長連続日数のマイルストーンでスタンプを付与し、
/// SharedPreferences に獲得済みIDを保存する。臨床要素・採点は一切なし。
class StampService {
  StampService._();

  /// 表示順のスタンプ定義。
  static const List<Stamp> all = [
    Stamp('first', '🌱'),
    Stamp('count10', '🍰'),
    Stamp('count30', '🎈'),
    Stamp('count50', '🐧'),
    Stamp('count100', '🏆'),
    Stamp('streak3', '🔥'),
    Stamp('streak7', '⭐'),
    Stamp('streak14', '🌈'),
    Stamp('streak30', '👑'),
  ];

  static Set<String> _evaluate(int total, int bestStreak) {
    final earned = <String>{};
    if (total >= 1) earned.add('first');
    if (total >= 10) earned.add('count10');
    if (total >= 30) earned.add('count30');
    if (total >= 50) earned.add('count50');
    if (total >= 100) earned.add('count100');
    if (bestStreak >= 3) earned.add('streak3');
    if (bestStreak >= 7) earned.add('streak7');
    if (bestStreak >= 14) earned.add('streak14');
    if (bestStreak >= 30) earned.add('streak30');
    return earned;
  }

  /// 保存済みの獲得スタンプID。
  static Future<Set<String>> earnedIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(AppConstants.prefEarnedStamps) ?? const [])
        .toSet();
  }

  /// 全エントリーから再評価して保存し、今回新しく獲得したスタンプを返す。
  static Future<List<Stamp>> sync(List<DiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final prev =
        (prefs.getStringList(AppConstants.prefEarnedStamps) ?? const [])
            .toSet();
    final total = entries.length;
    final best = StreakService.longestStreak(entries);
    final now = _evaluate(total, best);
    final newlyIds = now.difference(prev);
    if (newlyIds.isNotEmpty || now.length != prev.length) {
      // 保存順は定義順にそろえる
      await prefs.setStringList(
        AppConstants.prefEarnedStamps,
        all.where((s) => now.contains(s.id)).map((s) => s.id).toList(),
      );
    }
    return all.where((s) => newlyIds.contains(s.id)).toList();
  }
}
