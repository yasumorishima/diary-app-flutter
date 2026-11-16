import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/diary_entry.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../services/word_stats.dart';
import '../utils/theme.dart';

/// 1年の振り返り画面（Year in Review・ゆるのり ポップ版）
///
/// その年の記録をまとめた1枚のカードを表示し、画像としてシェアできる。
/// 感情スコアや臨床的な要素は含めない（件数・文字数・最長連続・頻出語など）。
class YearReviewScreen extends StatefulWidget {
  const YearReviewScreen({super.key});

  @override
  State<YearReviewScreen> createState() => _YearReviewScreenState();
}

class _YearReviewScreenState extends State<YearReviewScreen> {
  final _db = DatabaseService();
  final _cardKey = GlobalKey();

  bool _isLoading = true;
  bool _isSharing = false;
  List<DiaryEntry> _allEntries = [];
  List<int> _years = [];
  int? _selectedYear;

  int _entryCount = 0;
  int _totalChars = 0;
  int _maxStreak = 0;
  List<MapEntry<String, int>> _topWords = [];
  List<MapEntry<String, int>> _topMoods = [];

  static const _sectionStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final entries = await _db.getAllEntries();
      final years = entries.map((e) => e.date.year).toSet().toList()
        ..sort((a, b) => b.compareTo(a));
      _allEntries = entries;
      _years = years;
      if (years.isNotEmpty) {
        final now = DateTime.now().year;
        _selectedYear = years.contains(now) ? now : years.first;
        _computeFor(_selectedYear!);
      }
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
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _computeFor(int year) {
    final entries = _allEntries.where((e) => e.date.year == year).toList();
    _entryCount = entries.length;
    _totalChars = entries.fold(0, (sum, e) => sum + e.content.length);
    _maxStreak = _longestStreak(entries);
    _topWords = WordStats.topWords(entries, limit: 5);

    final moodCounts = <String, int>{};
    for (final entry in entries) {
      if (entry.mood.isEmpty) continue;
      moodCounts[entry.mood] = (moodCounts[entry.mood] ?? 0) + 1;
    }
    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _topMoods = sortedMoods.take(3).toList();
  }

  int _longestStreak(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 0;
    // UTC 正規化（StreakService と同じ DST 対策）
    final days = entries
        .map((e) => DateTime.utc(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort();
    var longest = 1;
    var current = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  Future<void> _shareAsImage() async {
    if (kIsWeb || _isSharing) return;
    setState(() => _isSharing = true);
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/daily_diary_$_selectedYear.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
      try {
        await file.delete();
      } catch (_) {
        // 削除失敗は無視
      }
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
    } finally {
      if (mounted) setState(() => _isSharing = false);
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
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 4,
              right: 12,
              bottom: 18,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.dimForDark(
                    const [AppTheme.popPink2, AppTheme.popGrape], isDark),
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
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
                    '🎞️ ${l10n.yearReview}',
                    semanticsLabel: l10n.yearReview,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_years.length > 1)
                  DropdownButton<int>(
                    value: _selectedYear,
                    underline: const SizedBox.shrink(),
                    iconEnabledColor: Colors.white,
                    dropdownColor:
                        isDark ? AppTheme.darkCard : Colors.white,
                    selectedItemBuilder: (context) => _years
                        .map((y) => Center(
                              child: Text(
                                '$y',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ))
                        .toList(),
                    items: _years
                        .map((y) => DropdownMenuItem<int>(
                              value: y,
                              child: Text(
                                '$y',
                                style: TextStyle(
                                  color: AppTheme.textColor(isDark),
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (year) {
                      if (year == null) return;
                      setState(() {
                        _selectedYear = year;
                        _computeFor(year);
                      });
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedYear == null
                    ? _buildEmptyState(isDark, l10n)
                    : _buildReview(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ExcludeSemantics(
              child: Text('🎞️', style: TextStyle(fontSize: 64))),
          const SizedBox(height: 16),
          Text(
            l10n.yearReviewNoData,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildShareCard(l10n),
        const SizedBox(height: 16),
        if (!kIsWeb) _buildShareButton(l10n),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildShareCard(AppLocalizations l10n) {
    return RepaintBoundary(
      key: _cardKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.popPink2, AppTheme.popGrape],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    '📔 Daily Diary',
                    semanticsLabel: 'Daily Diary',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(height: 2, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildNumberItem(
                    '📖', l10n.yearReviewEntries, '$_entryCount${l10n.count}'),
                _buildNumberItem('✍️', l10n.yearReviewChars,
                    '${NumberFormat('#,##0').format(_totalChars)}${l10n.chars}'),
                _buildNumberItem(
                    '🔥', l10n.yearReviewMaxStreak, '$_maxStreak${l10n.days}'),
              ],
            ),
            const SizedBox(height: 20),
            if (_topWords.isNotEmpty) ...[
              Text(l10n.yearReviewTopWords, style: _sectionStyle),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _topWords
                    .map((word) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${word.key} ×${word.value}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
            if (_topMoods.isNotEmpty)
              Row(
                children: _topMoods
                    .map((mood) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Text(
                            '${mood.key} ×${mood.value}',
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // ふりかえりと同じ理由で「見出し 数字」の 1 文にまとめて読ませる
  Widget _buildNumberItem(String emoji, String label, String value) {
    return Expanded(
      child: Semantics(
        label: '$label $value',
        excludeSemantics: true,
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSharing ? null : _shareAsImage,
        icon: _isSharing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.share),
        label: Text(l10n.yearReviewShare),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.popGrape,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
