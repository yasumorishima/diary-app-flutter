import 'package:hive_flutter/hive_flutter.dart';
import '../models/diary_entry.dart';

/// データベースサービス（Hive使用）
///
/// GASのCode.gsから移植したデータ操作ロジック
/// スプレッドシート → Hive（Web/Android/iOS対応）
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static const String _boxName = 'diaries';
  Box<DiaryEntry>? _box;

  DatabaseService._init();

  // ファクトリーコンストラクタ（外部から DatabaseService() で呼び出せるように）
  factory DatabaseService() {
    return instance;
  }

  /// データベース初期化（明示的に呼び出す用）
  Future<void> initDatabase() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<DiaryEntry>(_boxName);
    }
  }

  /// ボックスを取得
  Future<Box<DiaryEntry>> get box async {
    if (_box == null || !_box!.isOpen) {
      await initDatabase();
    }
    return _box!;
  }

  /// 日記を作成・更新（GAS: saveDiary）
  Future<DiaryEntry> insertEntry(DiaryEntry entry) async {
    final db = await box;
    // 日付ベースのIDで保存（同じ日付なら上書き）
    await db.put(entry.id, entry);
    return entry;
  }

  /// 日記を更新（insertEntryと同じ）
  Future<void> updateEntry(DiaryEntry entry) async {
    entry.updatedAt = DateTime.now();
    await insertEntry(entry);
  }

  /// 日記を1件取得（IDで検索）
  Future<DiaryEntry?> readById(String id) async {
    final db = await box;
    return db.get(id);
  }

  /// 日記を1件取得（日付で検索、GAS: getTodayEntry）
  Future<DiaryEntry?> getEntryByDate(DateTime date) async {
    final id = DiaryEntry.generateId(date);
    return await readById(id);
  }

  /// 全日記を取得（GAS: getDiaries）
  Future<List<DiaryEntry>> getAllEntries() async {
    final db = await box;
    final entries = db.values.toList();
    // 日付の新しい順に並び替え
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// 過去の今日を取得（GAS: getPastToday）
  Future<List<DiaryEntry>> readPastToday() async {
    final db = await box;
    final now = DateTime.now();
    final monthDay = '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final entries = db.values.where((entry) {
      final entryMonthDay =
          '${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
      return entryMonthDay == monthDay && entry.year != now.year;
    }).toList();

    // 日付の新しい順に並び替え
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// 検索（GAS: searchDiaries）
  Future<List<DiaryEntry>> search(String keyword) async {
    final db = await box;
    // 大文字小文字を区別しない部分一致（Tokyo / tokyo / TOKYO を同一視）
    final query = keyword.toLowerCase();
    final entries = db.values.where((entry) {
      return entry.content.toLowerCase().contains(query) ||
          entry.tags.toLowerCase().contains(query);
    }).toList();

    // 日付の新しい順に並び替え
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// タグで検索（GAS: filterByTag）
  Future<List<DiaryEntry>> readByTag(String tag) async {
    final db = await box;
    final entries = db.values.where((entry) {
      return entry.tags.contains(tag);
    }).toList();

    // 日付の新しい順に並び替え
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// 日記を削除
  Future<void> delete(String id) async {
    final db = await box;
    await db.delete(id);
  }

  /// 全ての日記を削除
  Future<void> deleteAllEntries() async {
    final db = await box;
    await db.clear();
  }

  /// ランダムな日記を取得（GAS: getRandomEntry）
  Future<DiaryEntry?> readRandom() async {
    final db = await box;
    if (db.isEmpty) return null;

    final entries = db.values.toList();
    entries.shuffle();
    return entries.first;
  }

  /// 統計：総日記数
  Future<int> getTotalCount() async {
    final db = await box;
    return db.length;
  }

  /// 統計：連続記録日数（ストリーク）
  Future<int> getStreak() async {
    final entries = await getAllEntries();
    if (entries.isEmpty) return 0;

    var streak = 0;
    var expectedDate = DateTime.now();

    for (var entry in entries) {
      final entryDate =
          DateTime(entry.date.year, entry.date.month, entry.date.day);
      final expected =
          DateTime(expectedDate.year, expectedDate.month, expectedDate.day);

      if (entryDate.isAtSameMomentAs(expected) ||
          entryDate.isAtSameMomentAs(
              expected.subtract(const Duration(days: 1)))) {
        streak++;
        expectedDate = entryDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// 全データを削除
  Future<void> clearAll() async {
    final db = await box;
    await db.clear();
  }

  /// データベースを閉じる
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }
}
