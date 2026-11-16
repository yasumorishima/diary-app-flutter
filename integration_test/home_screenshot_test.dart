import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:diary_app/screens/home_screen.dart';
import 'package:diary_app/utils/constants.dart';

import 'package:diary_app/main.dart' as app;

/// ホーム画面（トップ）の実機レンダリングを撮る。
/// Codespace 退役後、実画面の見た目を自分で確認できる経路がこれ 1 本しかない。
/// 言語とテーマは --dart-define=LOCALE=ja|en / THEME=light|dark で切り替える
/// （main() が Hive のアダプタを登録するので 1 プロセスで 1 回しか起動できない）。
const String kTheme = String.fromEnvironment('THEME', defaultValue: 'light');
const String kLocale = String.fromEnvironment('LOCALE', defaultValue: 'ja');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ホーム（$kLocale / $kTheme）を撮る', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', kLocale);
    await prefs.setString('theme_mode', kTheme);
    await prefs.setBool('onboarding_done', true);

    app.main();

    // 広告やアニメーションで pumpAndSettle が返らないことがあるため固定 pump
    final home = find.byType(HomeScreen);
    final deadline = DateTime.now().add(const Duration(seconds: 90));
    while (DateTime.now().isBefore(deadline) && home.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // 何が出ていても必ず 1 枚撮る。ホームに辿り着けなかったときこそ
    // 画面を見たいので、検査より先に撮る。
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(seconds: 1));
    await binding.takeScreenshot('home_${kLocale}_$kTheme');

    expect(home, findsOneWidget, reason: 'ホームに辿り着けていない');

    if (kLocale == 'ja') {
      expect(find.byKey(const Key('home_kids_site')), findsOneWidget,
          reason: 'ホームに学習サイトへの導線が出ていない');
      expect(find.text('さんすう しょうぎ そら'), findsOneWidget);

      // API 30 以降は AndroidManifest の <queries> が無いと解決先が見えず
      // false になる。タップしても開かない状態で出荷しないための実機検査。
      expect(await canLaunchUrl(Uri.parse(AppConstants.kidsSiteUrl)), isTrue,
          reason: 'canLaunchUrl が false。<queries> の宣言を確認する');
    } else {
      // 中身が日本語のみのサイトなので、日本語以外では出さない
      expect(find.byKey(const Key('home_kids_site')), findsNothing);
      // app_flow_test が最初に探すのと同じ文言。ここで見つかるなら
      // 英語表示そのものは壊れていない。
      expect(find.textContaining('Write today'), findsOneWidget);
    }

    // 撮影用に書いた設定を端末に残さない。
    await prefs.remove('locale');
    await prefs.remove('theme_mode');
  });
}
