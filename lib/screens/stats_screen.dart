import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/diary_entry.dart';
import '../providers/theme_provider.dart';
import '../services/streak_service.dart';
import '../utils/theme.dart';
import '../widgets/mood_button.dart';
import 'year_review_screen.dart';

/// ふりかえり画面（ゆるのり ポップ版・採点や感情分析はなし）
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _db = DatabaseService();
  bool _isLoading = true;

  int _totalEntries = 0;
  int _currentStreak = 0;
  int _thisMonth = 0;
  DateTime? _firstDate;
  DateTime? _lastDate;
  int _avgChars = 0;
  int _recordingDays = 0;
  double _writeRate = 0.0;
  Map<String, int> _moodCounts = {};
  List<MapEntry<String, int>> _topTags = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final entries = await _db.getAllEntries();
      if (entries.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      _totalEntries = entries.length;
      _currentStreak = StreakService.currentStreak(entries);

      final now = DateTime.now();
      _thisMonth = entries
          .where((e) => e.date.year == now.year && e.date.month == now.month)
          .length;

      final sorted = List<DiaryEntry>.from(entries)
        ..sort((a, b) => a.date.compareTo(b.date));
      _firstDate = sorted.first.date;
      _lastDate = sorted.last.date;

      final uniqueDates = <String>{};
      for (final e in entries) {
        uniqueDates.add('${e.date.year}-${e.date.month}-${e.date.day}');
      }
      _recordingDays = uniqueDates.length;

      if (_firstDate != null && _lastDate != null) {
        final span = _lastDate!.difference(_firstDate!).inDays + 1;
        _writeRate = (_recordingDays / span) * 100;
      }

      var totalChars = 0;
      for (final e in entries) {
        totalChars += e.content.length;
      }
      _avgChars = totalChars ~/ _totalEntries;

      _moodCounts = {};
      for (final e in entries) {
        _moodCounts[e.mood] = (_moodCounts[e.mood] ?? 0) + 1;
      }

      final tagCounts = <String, int>{};
      for (final e in entries) {
        for (final t in e.tagList) {
          tagCounts[t] = (tagCounts[t] ?? 0) + 1;
        }
      }
      _topTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _topTags = _topTags.take(12).toList();

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.randomError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Column(
        children: [
          _buildHeader(isDark, l10n),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _totalEntries == 0
                    ? _buildEmpty(isDark, l10n)
                    : _buildBody(isDark, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 4,
        right: 16,
        bottom: 18,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.dimForDark(
              const [AppTheme.popSky2, AppTheme.popMint], isDark),
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
            child: Text(
              '✨ ${l10n.reviewTitle}',
              semanticsLabel: l10n.reviewTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(
              child: Text('📭', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 16),
          Text(
            l10n.randomNoDiary,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor(isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startWritingDiary,
            style: TextStyle(color: AppTheme.subTextColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildYearReviewCard(isDark, l10n),
        const SizedBox(height: 14),
        _buildNumbersCard(isDark, l10n),
        const SizedBox(height: 14),
        _buildPeriodCard(isDark, l10n),
        const SizedBox(height: 14),
        if (_moodCounts.isNotEmpty) _buildMoodCard(isDark, l10n),
        if (_moodCounts.isNotEmpty) const SizedBox(height: 14),
        if (_topTags.isNotEmpty) _buildTagsCard(isDark, l10n),
      ],
    );
  }

  Widget _card(bool isDark, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }

  Widget _buildYearReviewCard(bool isDark, AppLocalizations l10n) {
    return Material(
      color: AppTheme.cardColor(isDark),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YearReviewScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const ExcludeSemantics(
                  child: Text('🎞️', style: TextStyle(fontSize: 26))),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.yearReview,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppTheme.textColor(isDark),
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppTheme.subTextColor(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumbersCard(bool isDark, AppLocalizations l10n) {
    // 絵文字・数字・見出しが 3 つに割れて読まれると意味が取れない。
    // 読み上げには「見出し 数字」の 1 文だけを渡す
    Widget tile(String emoji, String value, String label, Color color) {
      return Expanded(
        child: Semantics(
          label: '$label $value',
          excludeSemantics: true,
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.subTextColor(isDark)),
              ),
            ],
          ),
        ),
      );
    }

    return _card(
      isDark,
      child: Column(
        children: [
          Row(
            children: [
              tile('📖', '$_totalEntries', l10n.statsTotalEntries,
                  AppTheme.popSky),
              tile('🔥', '$_currentStreak', l10n.statsCurrentStreak,
                  AppTheme.popOrange),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              tile('🗓️', '$_thisMonth', l10n.statsThisMonth,
                  AppTheme.popPink2),
              tile('✍️', '$_avgChars', l10n.statsAvgChars, AppTheme.popMint),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(bool isDark, AppLocalizations l10n) {
    // 見出しと値を 1 まとまりで読ませる
    Widget row(String label, String value) {
      return MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(label,
                  style: TextStyle(color: AppTheme.subTextColor(isDark))),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor(isDark)),
              ),
            ],
          ),
        ),
      );
    }

    final fmt = DateFormat('yyyy/M/d');
    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsPeriod,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(isDark)),
          ),
          const SizedBox(height: 10),
          row(l10n.statsFirstEntry, fmt.format(_firstDate!)),
          row(l10n.statsLatestEntry, fmt.format(_lastDate!)),
          row(l10n.statsRecordingDays, '$_recordingDays${l10n.daysCount}'),
          row(l10n.statsWriteRate, '${_writeRate.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildMoodCard(bool isDark, AppLocalizations l10n) {
    final sorted = _moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // 絵文字は読み上げでは「にっこりした顔」等になり、どの気分か分からない。
    // 「書く」画面と同じことばを引くための対応表
    final moodLabels = {for (final m in moodOptions(l10n)) m.emoji: m.label};
    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsMoodShare,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(isDark)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 14,
            children: sorted.take(6).map((e) {
              final name =
                  e.key.isEmpty ? l10n.notSet : (moodLabels[e.key] ?? e.key);
              final count = e.key.isEmpty
                  ? '${e.value}'
                  : '${e.value}${l10n.times}';
              return Semantics(
                label: '$name $count',
                excludeSemantics: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      e.key.isEmpty ? '🫥' : e.key,
                      style: const TextStyle(fontSize: 34),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      e.key.isEmpty
                          ? '${l10n.notSet} ${e.value}'
                          : '${e.value}${l10n.times}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor(isDark),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsCard(bool isDark, AppLocalizations l10n) {
    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.statsTopTags,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(isDark)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _topTags.map((t) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3A2E44)
                      : const Color(0xFFFFE3F4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '🏷️ ${t.key} ×${t.value}',
                  semanticsLabel: '${t.key} ${t.value}${l10n.times}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? const Color(0xFFE6A8D6)
                        : const Color(0xFFC65CB0),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
