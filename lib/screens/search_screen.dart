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

/// 検索画面
/// キーワードとタグで日記を検索
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _db = DatabaseService();
  final _searchController = TextEditingController();
  final _tagController = TextEditingController();

  List<DiaryEntry> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String _searchType = 'keyword'; // 'keyword' or 'tag'
  Map<String, int> _tagSuggestions = {}; // タグ名 → 件数
  bool _isLoadingTags = false;

  @override
  void initState() {
    super.initState();
    _loadTagSuggestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  // タグ候補を読み込み
  Future<void> _loadTagSuggestions() async {
    setState(() {
      _isLoadingTags = true;
    });

    try {
      final allEntries = await _db.getAllEntries();
      final Map<String, int> tagCounts = {};

      // 全エントリーからタグを抽出してカウント
      for (final entry in allEntries) {
        for (final tag in entry.tagList) {
          final trimmedTag = tag.trim();
          if (trimmedTag.isNotEmpty) {
            tagCounts[trimmedTag] = (tagCounts[trimmedTag] ?? 0) + 1;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _tagSuggestions = tagCounts;
        _isLoadingTags = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTags = false;
      });
    }
  }

  // 検索実行
  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    final tag = _tagController.text.trim();

    if (keyword.isEmpty && tag.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.searchEnterKeywordOrTag),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });

    try {
      final allEntries = await _db.getAllEntries();
      List<DiaryEntry> results = [];

      if (_searchType == 'keyword' && keyword.isNotEmpty) {
        // キーワード検索（大文字小文字区別なし）
        results = allEntries.where((entry) {
          final contentLower = entry.content.toLowerCase();
          final keywordLower = keyword.toLowerCase();
          return contentLower.contains(keywordLower);
        }).toList();
      } else if (_searchType == 'tag' && tag.isNotEmpty) {
        // タグ検索（完全一致）
        results = allEntries.where((entry) {
          return entry.tagList.any((t) =>
              t.trim().toLowerCase() == tag.trim().toLowerCase());
        }).toList();
      }

      // 日付の新しい順にソート
      results.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _hasSearched = true;
      });
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
  }

  // 検索をクリア
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _tagController.clear();
      _searchResults = [];
      _hasSearched = false;
    });
  }

  // タグをタップして検索
  Future<void> _searchByTag(String tag) async {
    _tagController.text = tag;
    await _performSearch();
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
                        '🔍 ${l10n.search}',
                        semanticsLabel: l10n.search,
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
                    if (_hasSearched)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: _clearSearch,
                        tooltip: l10n.clear,
                      ),
                  ],
                ),
              ),

              // メインコンテンツ
              Expanded(
                child: Column(
        children: [
          // 検索フォーム
          Card(
            color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 検索タイプ選択
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'keyword',
                        label: Text(
                          l10n.keyword,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        icon: Icon(
                          Icons.search,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                      ButtonSegment(
                        value: 'tag',
                        label: Text(
                          l10n.tags,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        icon: Icon(
                          Icons.local_offer,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                    selected: {_searchType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _searchType = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // キーワード検索フィールド
                  if (_searchType == 'keyword')
                    TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchDiaryContent,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                tooltip: l10n.clear,
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {}); // suffixIconの表示更新
                      },
                      onSubmitted: (_) => _performSearch(),
                    ),

                  // タグ検索フィールド
                  if (_searchType == 'tag')
                    TextField(
                      controller: _tagController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchTagPlaceholder,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        prefixIcon: Icon(
                          Icons.local_offer,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                        suffixIcon: _tagController.text.isNotEmpty
                            ? IconButton(
                                tooltip: l10n.clear,
                                icon: Icon(
                                  Icons.clear,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                                onPressed: () {
                                  _tagController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {}); // suffixIconの表示更新
                      },
                      onSubmitted: (_) => _performSearch(),
                    ),

                  // タグ候補リスト（タグ検索モードのみ・検索前のみ）
                  if (_searchType == 'tag' && !_hasSearched) ...[
                    const SizedBox(height: 16),
                    if (_isLoadingTags)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_tagSuggestions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          l10n.noTagsYet,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                            child: Text(
                              l10n.tagSuggestions(_tagSuggestions.length),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[300] : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 160),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: () {
                                  final sortedTags = _tagSuggestions.entries.toList()
                                    ..sort((a, b) => b.value.compareTo(a.value)); // 件数の多い順
                                  return sortedTags
                                      .map((entry) => ActionChip(
                                            label: Text(
                                              '${entry.key} (${entry.value}${l10n.count})',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                                            onPressed: () => _searchByTag(entry.key),
                                            avatar: Icon(
                                              Icons.local_offer,
                                              size: 16,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ))
                                      .toList();
                                }(),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],

                  const SizedBox(height: 16),

                  // 検索ボタン
                  FilledButton.icon(
                    onPressed: _isSearching ? null : _performSearch,
                    icon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isSearching ? l10n.searching : l10n.search),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),

                  // リセットボタン（検索後に表示）
                  if (_hasSearched) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.clear),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 検索結果
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.searchByKeywordOrTag,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.searchNoResults,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.searchTryDifferentKeyword,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 検索結果ヘッダー
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.searchResults(_searchResults.length),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 検索結果リスト
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, bottom: 16),
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final entry = _searchResults[index];
                                    return Card(
                                      color: isDark ? const Color(0xFF2d2d2d) : Colors.white,
                                      margin: const EdgeInsets.only(
                                          left: 8, right: 8, bottom: 8),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.2),
                                          child: entry.mood.isNotEmpty
                                              ? Text(
                                                  entry.mood,
                                                  semanticsLabel: moodLabelOf(l10n, entry.mood),
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                )
                                              : Text(
                                                  '${entry.date.day}',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                        title: Text(
                                          dateFormat.format(entry.date),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              entry.content,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isDark ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            if (entry.tags.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 4,
                                                runSpacing: 4,
                                                children: entry.tagList
                                                    .take(3)
                                                    .map((tag) => Chip(
                                                          label: Text(
                                                            tag,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: isDark ? Colors.white : Colors.black,
                                                            ),
                                                          ),
                                                          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 4,
                                                                  vertical: 0),
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                        ))
                                                    .toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                        trailing: Icon(
                                          Icons.chevron_right,
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                        ),
                                        onTap: () async {
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
                                            // 編集後は再検索
                                            _performSearch();
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
          ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
