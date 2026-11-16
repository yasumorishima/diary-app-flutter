import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/streak_service.dart';
import '../utils/theme.dart';

/// スタンプID → ローカライズ名。celebration からも使う。
String stampLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'first':
      return l10n.stampNameFirst;
    case 'count10':
      return l10n.stampNameCount10;
    case 'count30':
      return l10n.stampNameCount30;
    case 'count50':
      return l10n.stampNameCount50;
    case 'count100':
      return l10n.stampNameCount100;
    case 'streak3':
      return l10n.stampNameStreak3;
    case 'streak7':
      return l10n.stampNameStreak7;
    case 'streak14':
      return l10n.stampNameStreak14;
    case 'streak30':
      return l10n.stampNameStreak30;
    default:
      return id;
  }
}

/// スタンプ集め画面（獲得済み＋未獲得のポップなグリッド）。
class StampsScreen extends StatefulWidget {
  const StampsScreen({super.key});

  @override
  State<StampsScreen> createState() => _StampsScreenState();
}

class _StampsScreenState extends State<StampsScreen> {
  Set<String> _earned = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final earned = await StampService.earnedIds();
    if (!mounted) return;
    setState(() {
      _earned = earned;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppTheme.pageGradient(isDark),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark, l10n),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildGrid(isDark, l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.dimForDark(
              const [AppTheme.popPink2, AppTheme.popGrape], isDark),
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: l10n.a11yBack,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎁 ${l10n.stampsTitle}',
                  semanticsLabel: l10n.stampsTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.stampsCount(_earned.length),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(bool isDark, AppLocalizations l10n) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 3,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.82,
      children: StampService.all.map((stamp) {
        final got = _earned.contains(stamp.id);
        final card = Container(
          decoration: BoxDecoration(
            color: got
                ? (isDark ? AppTheme.darkCard : const Color(0xFFFFF4FB))
                : (isDark ? const Color(0xFF2A2633) : const Color(0xFFF0F0F3)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: got
                ? [
                    BoxShadow(
                      color: AppTheme.popPink.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Text(
                  got ? stamp.emoji : '❓',
                  style: TextStyle(
                    fontSize: 40,
                    color: got ? null : Colors.grey.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  got ? stampLabel(l10n, stamp.id) : l10n.stampLockedHint,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: got
                        ? AppTheme.textColor(isDark)
                        : AppTheme.subTextColor(isDark),
                  ),
                ),
              ),
            ],
          ),
        );
        // 1 マスを 1 まとまりで読ませる（絵文字と名前が別々に読まれない）
        return MergeSemantics(child: card);
      }).toList(),
    );
  }
}
