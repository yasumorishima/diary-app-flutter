import 'package:hive/hive.dart';
import '../models/program_session.dart';

/// 筆記開示コースの進行状態
class PennebakerState {
  final String? theme; // 現行コースのテーマ（未開始なら null）
  final int completedDays; // 現行テーマで完了したセッション数（0〜4）

  const PennebakerState({required this.theme, required this.completedDays});

  bool get completed => completedDays >= 4;
  int get nextDay => completedDays + 1;
}

/// ガイド付きプログラムのセッション保存・取得
class ProgramService {
  static final ProgramService instance = ProgramService._init();
  static const String boxName = 'program_sessions';
  Box<ProgramSession>? _box;

  ProgramService._init();

  factory ProgramService() {
    return instance;
  }

  Future<Box<ProgramSession>> get box async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<ProgramSession>(boxName);
    }
    return _box!;
  }

  /// セッションを保存（同 ID は上書き）
  Future<void> upsert(ProgramSession session) async {
    final b = await box;
    await b.put(session.id, session);
  }

  Future<ProgramSession?> byId(String id) async {
    final b = await box;
    return b.get(id);
  }

  /// プログラム種別のセッション一覧（日付昇順）
  Future<List<ProgramSession>> byType(String programType) async {
    final b = await box;
    final sessions =
        b.values.where((s) => s.programType == programType).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return sessions;
  }

  /// 全セッション（日付昇順、エクスポート用）
  Future<List<ProgramSession>> getAllSessions() async {
    final b = await box;
    final sessions = b.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return sessions;
  }

  /// 筆記開示コースの進行状態。
  /// 最後に書いたセッションのテーマを現行コースとみなし、
  /// 同じテーマのセッション数を進行日数とする。
  /// 全セッション削除（設定の「全データ削除」から。旧バージョンで
  /// 作成されたセンシティブな記録を端末に残さない）
  Future<void> deleteAllSessions() async {
    final b = await box;
    await b.clear();
  }

  Future<PennebakerState> pennebakerState() async {
    final sessions = await byType(ProgramSession.typePennebaker);
    if (sessions.isEmpty) {
      return const PennebakerState(theme: null, completedDays: 0);
    }
    final theme = sessions.last.theme;
    final count = sessions.where((s) => s.theme == theme).length;
    return PennebakerState(
      theme: theme,
      completedDays: count > 4 ? 4 : count,
    );
  }

  /// 今日の「3つの良いこと」が記入済みか
  Future<bool> threeGoodThingsDoneToday() async {
    final id = ProgramSession.generateId(
        ProgramSession.typeThreeGoodThings, DateTime.now());
    return await byId(id) != null;
  }
}
