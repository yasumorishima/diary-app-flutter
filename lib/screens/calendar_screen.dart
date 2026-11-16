import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import 'write_screen.dart';
import '../widgets/language_dialog.dart';
import '../widgets/mood_button.dart';
import '../widgets/legacy_material_host.dart';

/// カレンダー画面
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _db = DatabaseService();
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _refreshData() {
    setState(() {
      _refreshKey++;
    });
  }

  // 今日かどうかをチェック
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // 今日に戻る
  void _goToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  bool _hasDiary(DateTime day, List<DiaryEntry> entries) {
    return entries.any((entry) =>
        entry.date.year == day.year &&
        entry.date.month == day.month &&
        entry.date.day == day.day);
  }

  List<DiaryEntry> _getThisMonthEntries(List<DiaryEntry> allEntries) {
    return allEntries
        .where((entry) =>
            entry.date.year == _focusedDay.year &&
            entry.date.month == _focusedDay.month)
        .toList();
  }

  Future<void> _selectYear() async {
    final currentYear = _focusedDay.year;
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectYear),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              // 現在年が見える位置まで初期スクロール（101件に広げたため）
              controller: ScrollController(
                  initialScrollOffset:
                      ((currentYear - 2000) * 56.0 - 172).clamp(0.0, 5400.0)),
              itemCount: 101,
              itemBuilder: (context, index) {
                final year = 2000 + index;
                final isSelected = year == currentYear;
                final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
                return ListTile(
                  title: Text(
                    '$year',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _focusedDay = DateTime(year, _focusedDay.month, 1);
                      _selectedDay = _focusedDay;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  // 言語選択ダイアログ
  Future<void> _showLanguageDialog() => showLanguageSelectDialog(context);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

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
                        '📆 ${l10n.calendar}',
                        semanticsLabel: l10n.calendar,
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
                  key: ValueKey(_refreshKey),
                  future: _db.getAllEntries(),
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
                            const Icon(Icons.error_outline,
                                size: 60, color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              l10n.randomError(snapshot.error.toString()),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }

                    final allEntries = snapshot.data ?? [];
                    final thisMonthEntries = _getThisMonthEntries(allEntries);

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // カレンダーカード
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF2d2d2d) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // カスタムヘッダー（年をタップ可能に）
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      tooltip: l10n.a11yPrevMonth,
                                      icon: Icon(
                                        Icons.chevron_left,
                                        color: isDark
                                            ? const Color(0xFFe0e0e0)
                                            : const Color(0xFF202124),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month - 1,
                                            1,
                                          );
                                        });
                                      },
                                    ),
                                    InkWell(
                                      onTap: _selectYear,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          '${_focusedDay.year}/${_focusedDay.month}',
                                          semanticsLabel:
                                              '${l10n.a11yPickYearMonth}: ${_focusedDay.year}/${_focusedDay.month}',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? const Color(0xFFe0e0e0)
                                                : const Color(0xFF202124),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: l10n.a11yNextMonth,
                                      icon: Icon(
                                        Icons.chevron_right,
                                        color: isDark
                                            ? const Color(0xFFe0e0e0)
                                            : const Color(0xFF202124),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month + 1,
                                            1,
                                          );
                                        });
                                      },
                                    ),
                                    // 今日に戻るボタン（今日と異なる月を表示している場合のみ）
                                    if (!_isToday(_focusedDay) || (_selectedDay != null && !_isToday(_selectedDay!)))
                                      IconButton(
                                        icon: Icon(
                                          Icons.today,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        onPressed: _goToToday,
                                        tooltip: l10n.goToToday,
                                      ),
                                  ],
                                ),
                              ),
                              // table_calendar は旧 material ライブラリの InkWell を使う（理由は legacy_material_host.dart）
                              LegacyMaterialHost(
                                child: TableCalendar(
                                  firstDay: DateTime.utc(2000, 1, 1),
                                  lastDay: DateTime.utc(2100, 12, 31),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(_selectedDay, day),
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                  onPageChanged: (focusedDay) {
                                    setState(() {
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                  calendarStyle: CalendarStyle(
                                    markerDecoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    todayDecoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.purple[700]
                                          : Colors.purple[200],
                                      shape: BoxShape.circle,
                                    ),
                                    selectedDecoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    // ダークモード対応：日付の数字の色
                                    defaultTextStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFe0e0e0)
                                          : const Color(0xFF202124),
                                    ),
                                    weekendTextStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFe0e0e0)
                                          : const Color(0xFF202124),
                                    ),
                                    outsideTextStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF4a4a4a)
                                          : Colors.grey[400],
                                    ),
                                  ),
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFb0b0b0)
                                          : const Color(0xFF5f6368),
                                    ),
                                    weekendStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFb0b0b0)
                                          : const Color(0xFF5f6368),
                                    ),
                                  ),
                                  headerVisible: false,
                                  eventLoader: (day) {
                                    return _hasDiary(day, allEntries)
                                        ? ['diary']
                                        : [];
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 今月の日記セクション
                        Text(
                          l10n.thisMonthEntries(thisMonthEntries.length),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 今月の日記一覧
                        if (thisMonthEntries.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2d2d2d)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 60,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.randomNoDiary,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? const Color(0xFFb0b0b0)
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...thisMonthEntries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2d2d2d)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
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
                                        _refreshData();
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 気分または日付のアイコン
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFF667eea),
                                                  Color(0xFF764ba2)
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: entry.mood.isNotEmpty
                                                  ? Text(
                                                      entry.mood,
                                                      semanticsLabel: moodLabelOf(l10n, entry.mood),
                                                      style: const TextStyle(
                                                          fontSize: 28),
                                                    )
                                                  : Text(
                                                      '${entry.date.day}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // 日記内容
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${entry.date.year}/${entry.date.month}/${entry.date.day}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    color: isDark
                                                        ? const Color(0xFFe0e0e0)
                                                        : const Color(0xFF202124),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  entry.content,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark
                                                        ? const Color(0xFFb0b0b0)
                                                        : Colors.grey[700],
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: isDark
                                                ? const Color(0xFF4a4a4a)
                                                : Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
