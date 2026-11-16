import 'package:hive/hive.dart';

part 'diary_entry.g.dart';

/// 日記エントリーのデータモデル
///
/// GASのスプレッドシート構造から移植：
/// A列: 日付 → date
/// B列: 内容 → content
/// C列: 気分 → mood
/// D列: タグ → tags
@HiveType(typeId: 0)
class DiaryEntry extends HiveObject {
  @HiveField(0)
  String id;  // 一意のID（日付ベース: YYYY-MM-DD）

  @HiveField(1)
  DateTime date;  // 日記の日付

  @HiveField(2)
  String content;  // 日記の本文

  @HiveField(3)
  String mood;  // 気分（絵文字）

  @HiveField(4)
  String tags;  // タグ（カンマ区切り）

  @HiveField(5)
  DateTime createdAt;  // 作成日時

  @HiveField(6)
  DateTime updatedAt;  // 更新日時

  DiaryEntry({
    required this.id,
    required this.date,
    required this.content,
    this.mood = '',
    this.tags = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// タグのリストを取得（カンマ区切りから配列に変換）
  /// `,`（半角）、`、`（読点）、`，`（全角）すべて対応
  List<String> get tagList {
    if (tags.isEmpty) return [];
    return tags.split(RegExp(r'[,、，]')).map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
  }

  /// 月日を取得（MM/dd形式）
  String get monthDay {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// 年を取得
  int get year {
    return date.year;
  }

  /// 日付からIDを生成
  static String generateId(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'DiaryEntry(id: $id, date: $date, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}..., mood: $mood, tags: $tags)';
  }
}
