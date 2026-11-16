import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import '../utils/theme.dart';

/// 気分の選択肢。絵文字と、読み上げ用のことばを 1 組で持つ。
class MoodOption {
  final String emoji;
  final String label;
  const MoodOption(this.emoji, this.label);
}

/// ホームと「書く」画面で同じ並び・同じことばを使う。
/// 片方だけ直して食い違うことがないよう、定義はここ 1 箇所だけ。
List<MoodOption> moodOptions(AppLocalizations l10n) => [
      MoodOption('😆', l10n.moodFun),
      MoodOption('🙂', l10n.moodGood),
      MoodOption('😐', l10n.moodMeh),
      MoodOption('😢', l10n.moodSad),
      MoodOption('😠', l10n.moodAngry),
    ];

/// 絵文字から読み上げ用のことばを引く。
///
/// 一覧のカードは気分を絵文字のまま出しているので、そのままだと
/// 「にっこりした顔」等と読まれて どの気分か 分からない。
String moodLabelOf(AppLocalizations l10n, String emoji) {
  for (final m in moodOptions(l10n)) {
    if (m.emoji == emoji) return m.label;
  }
  return emoji;
}

/// 絵文字だけの気分ボタン。
///
/// 見た目は絵文字のままだが、スクリーンリーダーには
/// 絵文字の名前ではなく [MoodOption.label] と「選択中かどうか」を渡す。
/// （絵文字のままだと「にっこりした顔」等と読まれ、どれを選んだのかが分からない）
class MoodButton extends StatelessWidget {
  const MoodButton({
    super.key,
    required this.mood,
    required this.selected,
    required this.isDark,
    required this.onTap,
    this.size = 58,
    this.radius = 18,
    this.emojiSize = 28,
  });

  final MoodOption mood;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  final double size;
  final double radius;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: mood.label,
      // 中の絵文字 Text を読ませない（ラベルと二重に読まれるのを防ぐ）
      excludeSemantics: true,
      // 読み上げ操作からのタップは Semantics 側で受ける
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: size,
          height: size,
          transform: selected
              ? Matrix4.translationValues(0, -4, 0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.popYellow
                : (isDark ? const Color(0xFF352E40) : const Color(0xFFF4F0FF)),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppTheme.popYellow2
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : const Color(0xFFE2D8FF)),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(mood.emoji, style: TextStyle(fontSize: emojiSize)),
        ),
      ),
    );
  }
}
