import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

/// 初回オンボーディング（ポップな3枚）。
///
/// [onFinish] が指定されていればそれを呼ぶ（初回起動ゲート用）。
/// null の場合は自身を pop する（設定からの再表示用）。
class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onFinish;
  const OnboardingScreen({super.key, this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    if (!mounted) return;
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (_page >= 2) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      _OnboardPage(
        emoji: '📔',
        bg: const [AppTheme.popPink, AppTheme.popYellow],
        title: l10n.onboard1Title,
        body: l10n.onboard1Body,
      ),
      _OnboardPage(
        emoji: '😆',
        bg: const [AppTheme.popSky2, AppTheme.popMint],
        title: l10n.onboard2Title,
        body: l10n.onboard2Body,
      ),
      _OnboardPage(
        emoji: '🎈',
        bg: const [AppTheme.popGrape, AppTheme.popPink2],
        title: l10n.onboard3Title,
        body: l10n.onboard3Body,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            children: pages,
          ),
          // スキップ
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: TextButton(
              onPressed: _finish,
              child: Text(
                l10n.onboardSkip,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // 下部: ドット + ボタン
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final on = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: on ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withValues(alpha: on ? 1 : 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33000000), offset: Offset(0, 6)),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.popGrape,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        _page >= 2 ? l10n.onboardStart : l10n.onboardNext,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String body;
  final List<Color> bg;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bg,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 140),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                  child: Text(emoji, style: const TextStyle(fontSize: 96))),
              const SizedBox(height: 32),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
