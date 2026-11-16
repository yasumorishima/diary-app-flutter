import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:diary_app/widgets/celebration.dart';
import 'package:diary_app/widgets/mood_button.dart';

/// 目が見えない人向け（TalkBack / VoiceOver）の読み上げに関するテスト。
/// 実機の読み上げは自動では確かめられないので、
/// アプリが読み上げへ渡している中身（セマンティクス）を固定する。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MoodButton', () {
    testWidgets('絵文字ではなく ことば と 選んだかどうか を渡す', (tester) async {
      final handle = tester.ensureSemantics();
      var tapped = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MoodButton(
            mood: const MoodOption('😆', 'たのしい'),
            selected: true,
            isDark: false,
            onTap: () => tapped++,
          ),
        ),
      ));

      expect(
        tester.getSemantics(find.byType(MoodButton)),
        isSemantics(
          label: 'たのしい',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      // 絵文字は読み上げに出さない（「にっこりした顔」と読まれてしまうため）
      expect(find.bySemanticsLabel('😆'), findsNothing);

      await tester.tap(find.byType(MoodButton));
      expect(tapped, 1);
      handle.dispose();
    });

    testWidgets('選んでいないときは isSelected が false', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MoodButton(
            mood: const MoodOption('😢', 'かなしい'),
            selected: false,
            isDark: true,
            onTap: () {},
          ),
        ),
      ));

      expect(
        tester.getSemantics(find.byType(MoodButton)),
        isSemantics(label: 'かなしい', isSelected: false),
      );
      handle.dispose();
    });

    test('ホームと「書く」画面で 同じ 5 つ・同じ並び', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('ja'));
      final options = moodOptions(l10n);
      expect(options.map((m) => m.emoji).toList(),
          <String>['😆', '🙂', '😐', '😢', '😠']);
      expect(options.every((m) => m.label.isNotEmpty), isTrue);
    });
  });

  group('showCelebration', () {
    testWidgets('お祝いの中身を読み上げへ渡し、紙吹雪は読ませない', (tester) async {
      final handle = tester.ensureSemantics();
      final announced = <String>[];
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
        SystemChannels.accessibility,
        (Object? message) async {
          final data = message! as Map<Object?, Object?>;
          if (data['type'] == 'announce') {
            final body = data['data']! as Map<Object?, Object?>;
            announced.add(body['message']! as String);
          }
          return null;
        },
      );

      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          // 明示の読み上げに対応している OS（iOS 等）のふるまいを再現する
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(supportsAnnounce: true),
            child: Builder(builder: (inner) {
              ctx = inner;
              return const Scaffold(body: SizedBox());
            }),
          );
        }),
      ));

      final done = showCelebration(
        ctx,
        title: 'かけました！',
        streakLine: '3日 つづいています',
        stampLine: 'スタンプを もらいました',
      );
      await tester.pump();

      const spoken = 'かけました！ 3日 つづいています スタンプを もらいました';

      // 1.8 秒で消えるので、出たことを読み上げへ伝える印（liveRegion）が要る。
      // Android は明示の読み上げを無視することがあるので、こちらが主。
      expect(find.bySemanticsLabel(spoken), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel(spoken)),
        isSemantics(label: spoken, isLiveRegion: true),
      );

      // 対応している OS には明示の読み上げも送る
      expect(announced, <String>[spoken]);

      // 飾りの絵文字は読み上げに出さない
      expect(find.bySemanticsLabel('🎉🎊✨'), findsNothing);
      expect(find.bySemanticsLabel('🎈'), findsNothing);

      await tester.pumpAndSettle(const Duration(seconds: 3));
      await done;
      tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
              SystemChannels.accessibility, null);
      handle.dispose();
    });
  });
}
