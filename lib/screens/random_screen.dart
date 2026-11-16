import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';
import 'write_screen.dart';
import '../widgets/language_dialog.dart';
import '../widgets/mood_button.dart';

/// ランダム日記表示画面
/// 全ての日記からランダムに1件を表示
class RandomScreen extends StatefulWidget {
  const RandomScreen({super.key});

  @override
  State<RandomScreen> createState() => _RandomScreenState();
}

class _RandomScreenState extends State<RandomScreen> {
  final _db = DatabaseService();
  final _random = Random();
  DiaryEntry? _currentEntry;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRandomEntry();
  }

  // ランダムなエントリーを読み込み
  Future<void> _loadRandomEntry() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allEntries = await _db.getAllEntries();
      if (!mounted) return;

      if (allEntries.isEmpty) {
        setState(() {
          _currentEntry = null;
          _isLoading = false;
          _errorMessage = 'NO_DIARY'; // エラーキー
        });
        return;
      }

      // ランダムに1件選択
      final randomIndex = _random.nextInt(allEntries.length);
      setState(() {
        _currentEntry = allEntries[randomIndex];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'ERROR:$e'; // エラーキー + 詳細
      });
    }
  }

  // 言語選択ダイアログ
  Future<void> _showLanguageDialog() => showLanguageSelectDialog(context);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('yyyy/M/d');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF2c3e50), const Color(0xFF34495e)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                        '🎲 ${l10n.random}',
                        semanticsLabel: l10n.random,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.language,
                        color: Colors.white,
                      ),
                      onPressed: _showLanguageDialog,
                      tooltip: l10n.language,
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.wb_sunny : Icons.nightlight_round,
                        color: Colors.white,
                      ),
                      tooltip: isDark ? l10n.a11yLightMode : l10n.a11yDarkMode,
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle, color: Colors.white),
                      onPressed: _loadRandomEntry,
                      tooltip: l10n.randomTryAgain,
                    ),
                  ],
                ),
              ),

              // メインコンテンツ
              Expanded(
                child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!.startsWith('ERROR:')
                            ? l10n.randomError(_errorMessage!.substring(6))
                            : l10n.randomNoDiary,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.home, color: Colors.white),
                        label: Text(l10n.backToHome),
                      ),
                    ],
                  ),
                )
              : _currentEntry == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.randomNoDiary,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.startWritingDiary,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.home, color: Colors.white),
                            label: Text(l10n.backToHome),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ヘッダーカード（日付・気分）
                          Card(
                            color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  // 日付
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dateFormat.format(_currentEntry!.date),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 気分絵文字
                                  if (_currentEntry!.mood.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      _currentEntry!.mood,
                                      semanticsLabel: moodLabelOf(l10n, _currentEntry!.mood),
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 日記内容
                          Card(
                            color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        size: 20,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.diary,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _currentEntry!.content,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // タグ
                          if (_currentEntry!.tags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Card(
                              color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_offer,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.tags,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _currentEntry!.tagList
                                          .map((tag) => Chip(
                                                label: Text(
                                                  tag,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark ? Colors.white : Colors.black,
                                                  ),
                                                ),
                                                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 0),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize.shrinkWrap,
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // アクションボタン
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _loadRandomEntry,
                                  icon: const Icon(Icons.shuffle, color: Colors.white),
                                  label: Text(l10n.randomTryAgain),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WriteScreen(
                                          targetDate: _currentEntry!.date,
                                          existingEntry: _currentEntry,
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      // 編集後は再読み込み
                                      _loadRandomEntry();
                                    }
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  label: Text(l10n.edit, style: const TextStyle(color: Colors.white)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    side: const BorderSide(color: Colors.white, width: 1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
