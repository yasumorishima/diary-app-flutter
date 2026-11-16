import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../providers/theme_provider.dart';
import 'write_screen.dart';
import '../widgets/language_dialog.dart';
import '../widgets/mood_button.dart';

/// 過去の今日画面
/// 同じ月日の過去の日記を表示
class PastTodayScreen extends StatefulWidget {
  const PastTodayScreen({super.key});

  @override
  State<PastTodayScreen> createState() => _PastTodayScreenState();
}

class _PastTodayScreenState extends State<PastTodayScreen> {
  final _db = DatabaseService();

  // 言語選択ダイアログ
  Future<void> _showLanguageDialog() => showLanguageSelectDialog(context);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final monthDay = DateFormat('M/d').format(now);

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
                        l10n.pastTodayTitle(monthDay),
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
                  ],
                ),
              ),

              // メインコンテンツ
              Expanded(
                child: FutureBuilder<List<DiaryEntry>>(
                  future: _db.readPastToday(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              l10n.randomError(snapshot.error.toString()),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }

                    final entries = snapshot.data ?? [];

                    if (entries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.pastTodayNoPastEntries(monthDay),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.pastTodayKeepWriting,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final dateFormat = DateFormat('yyyy/M/d');

                        return Card(
                          color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 年とアクション
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      dateFormat.format(entry.date),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const Spacer(),
                                    // 気分絵文字
                                    if (entry.mood.isNotEmpty) ...[
                                      Text(
                                        entry.mood,
                                        semanticsLabel: moodLabelOf(l10n, entry.mood),
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    // 編集ボタン
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => WriteScreen(
                                              targetDate: entry.date,
                                              existingEntry: entry,
                                            ),
                                          ),
                                        );
                                        if (result == true && mounted) {
                                          setState(() {});
                                        }
                                      },
                                      tooltip: l10n.edit,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // 日記内容
                                Text(
                                  entry.content,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),

                                // タグ
                                if (entry.tags.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: entry.tagList
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
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
