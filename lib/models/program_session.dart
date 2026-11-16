import 'package:hive/hive.dart';

part 'program_session.g.dart';

/// ガイド付きプログラム（筆記開示・3つの良いこと）の1セッション
///
/// 筆記開示の内容はセンシティブになり得るため、日記本体（diaries box）
/// とは別の box に保存し、検索・統計・連続記録には含めない。
@HiveType(typeId: 1)
class ProgramSession extends HiveObject {
  @HiveField(0)
  String id; // '<programType>-YYYY-MM-DD'

  @HiveField(1)
  String programType; // typePennebaker | typeThreeGoodThings

  @HiveField(2)
  int dayIndex; // 筆記開示: 1〜4 / 3つの良いこと: 0（未使用）

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String content;

  @HiveField(5)
  String theme; // 筆記開示のテーマ（3つの良いことは ''）

  @HiveField(6)
  int durationSec; // 書いていた時間（秒）

  @HiveField(7)
  DateTime createdAt;

  ProgramSession({
    required this.id,
    required this.programType,
    required this.dayIndex,
    required this.date,
    required this.content,
    this.theme = '',
    this.durationSec = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  static const String typePennebaker = 'pennebaker';
  static const String typeThreeGoodThings = 'threeGoodThings';

  /// 日付ベースの ID。3つの良いことは 1日1件（同日は上書き）。
  /// 筆記開示は呼び出し側でこれに `-d<dayIndex>` を付け、同日・同 Day の
  /// 書き直しのみ上書きになる
  static String generateId(String programType, DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$programType-${date.year}-$m-$d';
  }
}
