import 'package:flutter_test/flutter_test.dart';
import 'package:diary_app/utils/a11y_text.dart';

void main() {
  group('spokenText', () {
    test('題名の先頭の絵文字を読み上げに渡さない', () {
      expect(spokenText('📖 Daily Diary'), 'Daily Diary');
      expect(spokenText('📖 連用日記'), '連用日記');
      expect(spokenText('📖 每日日记'), '每日日记');
    });

    test('文の途中や末尾の飾りも落とす', () {
      expect(spokenText('きょう、いちばん笑ったことは？😆'), 'きょう、いちばん笑ったことは？');
      expect(spokenText('Who made your day today? 🙌'), 'Who made your day today?');
    });

    test('飾りが無い文字列はそのまま', () {
      expect(spokenText('Daily Diary'), 'Daily Diary');
      expect(spokenText('連用日記'), '連用日記');
    });

    test('飾りだけの文字列は消さない（名前が無くなるため）', () {
      expect(spokenText('🎉🎊✨'), '🎉🎊✨');
      expect(spokenText('📖'), '📖');
    });

    test('落としたあとの空白は詰める', () {
      expect(spokenText('📖  ✨  Daily   Diary'), 'Daily Diary');
    });
  });
}
