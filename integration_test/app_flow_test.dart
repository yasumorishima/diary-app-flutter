import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:integration_test/integration_test.dart';

import 'package:diary_app/main.dart' as app;

/// 指定 Finder が現れるまで pump し続ける（広告等の外部要因で
/// pumpAndSettle が不安定になるのを避けるため、固定 pump 方式）。
/// 時間切れのときは、その時点の画面を撮ってから落とす
/// （何が出ているか分からないまま推測しないため）。
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  String shot = 'flow_stuck',
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) return;
  }
  try {
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(seconds: 1));
    await binding.takeScreenshot(shot);
  } catch (e) {
    debugPrint('画面を撮れなかった: $e');
  }
  fail('widget not found within timeout: $finder');
}

late IntegrationTestWidgetsFlutterBinding binding;

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('起動→（オンボ）→日記保存→お祝い→スタンプ画面 のゆるのりフロー',
      (tester) async {
    // 端末の既定言語や、前に走ったテストが残した設定に左右されないよう
    // この試験が前提にしている英語表示を自分で指定する
    // （同じエミュレータで撮影テストが locale を書くため）。
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', 'en');

    app.main();

    // 実行ごとにアプリのデータが初期化されるので、初回はオンボーディングが出る。
    // 起動に 10 秒前後かかるため「2 秒後に 1 度だけ探す」では取りこぼす
    // （2026-08-19: それで Skip を押せずオンボの前で 60 秒待って落ちていた。
    //  止まった画面を撮って確認済み）。出るまで待ってから押す。
    final skip = find.text('Skip');
    final home = find.textContaining('Write today');
    final onboardEnd = DateTime.now().add(const Duration(seconds: 60));
    while (DateTime.now().isBefore(onboardEnd)) {
      await tester.pump(const Duration(milliseconds: 500));
      if (home.evaluate().isNotEmpty) break;
      if (skip.evaluate().isNotEmpty) {
        await tester.tap(skip);
        await tester.pump(const Duration(seconds: 1));
        break;
      }
    }

    // ホーム表示（大きな「きょうの記録」ボタン）
    await waitFor(tester, find.textContaining('Write today'),
        timeout: const Duration(seconds: 60), shot: 'flow_stuck_home');

    // 書く画面へ
    await tester.tap(find.textContaining('Write today'));
    await waitFor(tester, find.byType(TextField));

    // 本文入力
    await tester.enterText(find.byType(TextField).first,
        '今日は友だちとカラオケに行ってめちゃ笑った。楽しかった。');
    await tester.pump();

    // 気分スタンプを選択
    final mood = find.text('😆');
    await tester.ensureVisible(mood.first);
    await tester.tap(mood.first);
    await tester.pump();

    // キーボードを閉じてから保存（ヘッダーの保存ピル）
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 500));
    final saveButton = find.text('Save');
    await tester.ensureVisible(saveButton.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(saveButton.first, warnIfMissed: false);

    // 保存後: お祝いオーバーレイが出て、約1.8秒で自動的に閉じてホームへ戻る。
    // 一瞬しか出ないものを捉えるのは競争になりやすい（2026-08-19: 保存も
    // お祝いも成功していたのに「見た瞬間」を捉えられず落ちていた。時間切れ
    // の画面を撮ったら、既にホームへ戻って保存結果が反映されていた）ので、
    // 出ていれば拾いつつ、判定は戻り先のホームと保存結果で行う。
    var sawCelebration = false;
    final backHome = find.textContaining('Write today');
    final celebrateEnd = DateTime.now().add(const Duration(seconds: 30));
    while (DateTime.now().isBefore(celebrateEnd)) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('You did it!').evaluate().isNotEmpty) {
        sawCelebration = true;
      }
      if (backHome.evaluate().isNotEmpty) break;
    }
    debugPrint('お祝いを画面で確認できたか: $sawCelebration');
    expect(backHome, findsOneWidget, reason: '保存後にホームへ戻っていない');

    // 保存が実際に効いていること（連続日数がホームに出る）
    expect(find.textContaining('in a row'), findsOneWidget,
        reason: '保存したのに連続日数がホームに反映されていない');

    // スタンプ集め画面を開く（ホームのメニュー）
    // ホームの文字は書く画面が閉じるアニメーションの途中から見えるので、
    // 遅いエミュレータでは 1 回目のタップがその最中に落ちて何も起きないことがある
    // （2026-11-16 run 43795172488: 時間切れの画面はホームのまま・同じ回の
    // 実機監査ではスタンプ画面は開けていた）。開くまで押し直す。
    final stampsTitle = find.textContaining('Stamp collection');
    for (var attempt = 1; attempt <= 4; attempt++) {
      if (stampsTitle.evaluate().isNotEmpty) break;
      if (find.text('Stamps').evaluate().isEmpty) break;
      await tester.ensureVisible(find.text('Stamps'));
      await tester.tap(find.text('Stamps'), warnIfMissed: false);
      final until = DateTime.now().add(const Duration(seconds: 8));
      while (DateTime.now().isBefore(until) && stampsTitle.evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      debugPrint('スタンプを押した回数: $attempt（開いた: ${stampsTitle.evaluate().isNotEmpty}）');
    }
    // 見出しは絵文字つきの '🎁 Stamp collection' なので完全一致では引けない
    await waitFor(tester, find.textContaining('Stamp collection'),
        shot: 'flow_stuck_stamps');
    expect(find.textContaining('Stamp collection'), findsOneWidget);

    // ホームへ戻る
    await tester.tap(find.byIcon(Icons.arrow_back).first, warnIfMissed: false);
    await waitFor(tester, find.textContaining('Write today'));
  });
}
