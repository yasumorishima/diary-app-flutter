import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../services/drive_backup_service.dart';
import '../services/review_service.dart';
import '../services/streak_service.dart';
import '../providers/theme_provider.dart';
import '../utils/theme.dart';
import '../widgets/celebration.dart';
import '../widgets/mood_button.dart';
import 'stamps_screen.dart';

/// 日記を書く画面（ゆるのり ポップ版・本文フリー入力の日記エディタ）
class WriteScreen extends StatefulWidget {
  final DateTime? targetDate;
  final DiaryEntry? existingEntry;
  final String? initialMood;
  final String? promptText;

  const WriteScreen({
    super.key,
    this.targetDate,
    this.existingEntry,
    this.initialMood,
    this.promptText,
  });

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();

  late DateTime _selectedDate;
  String _selectedMood = '';
  bool _isSaving = false;
  bool _promptDismissed = false;
  // 未保存変更の検出用（読み込み時点のベースライン）
  String _loadedContent = '';
  String _loadedTags = '';
  String _loadedMood = '';

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.targetDate ?? DateTime.now();
    if (widget.existingEntry != null) {
      _contentController.text = widget.existingEntry!.content;
      _tagsController.text = widget.existingEntry!.tags;
      _selectedMood = widget.existingEntry!.mood;
    } else if (widget.initialMood != null) {
      _selectedMood = widget.initialMood!;
    }
    _loadedContent = _contentController.text;
    _loadedTags = _tagsController.text;
    _loadedMood = _selectedMood;
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    if (!await _confirmDiscardIfDirty()) return;
    if (!mounted) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadEntryForDate(picked);
    }
  }

  bool get _isDirty =>
      _contentController.text != _loadedContent ||
      _tagsController.text != _loadedTags ||
      _selectedMood != _loadedMood;

  /// 未保存の変更があれば破棄確認を出す。true = 進んでよい。
  /// （日付移動ワンタップで書きかけが無警告で消えるのを防ぐ）
  Future<bool> _confirmDiscardIfDirty() async {
    if (!_isDirty) return true;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.discardChanges),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _loadEntryForDate(DateTime date) async {
    final db = DatabaseService();
    final entry = await db.getEntryByDate(date);
    if (!mounted) return;
    setState(() {
      _contentController.text = entry?.content ?? '';
      _tagsController.text = entry?.tags ?? '';
      _selectedMood = entry?.mood ?? '';
      _loadedContent = _contentController.text;
      _loadedTags = _tagsController.text;
      _loadedMood = _selectedMood;
    });
  }

  Future<void> _saveDiary() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final l10n = AppLocalizations.of(context)!;
    try {
      final db = DatabaseService();
      // 既存エントリーの編集では createdAt を引き継ぐ（毎回 now に
      // リセットするとバックアップ/エクスポートのメタデータが壊れる）
      final prior = await db.getEntryByDate(_selectedDate);
      final entry = DiaryEntry(
        id: DiaryEntry.generateId(_selectedDate),
        date: _selectedDate,
        content: _contentController.text,
        mood: _selectedMood,
        tags: _tagsController.text.replaceAll(RegExp(r'[、，]'), ','),
        createdAt: prior?.createdAt,
      );
      await db.insertEntry(entry);
      // 保存済み＝もう「書きかけ」ではない。お祝い表示中のシステムバックで
      // 偽の破棄確認が出ないよう、ベースラインを保存内容に更新する
      _loadedContent = _contentController.text;
      _loadedTags = _tagsController.text;
      _loadedMood = _selectedMood;

      // Drive 自動バックアップ（サインイン済み＋ON のときだけ、デバウンスして
      // サイレント実行。保存 UX はブロックしない）
      unawaited(DriveBackupService().onEntrySaved());

      final entries = await db.getAllEntries();
      final streak = StreakService.currentStreak(entries);
      final newStamps = await StampService.sync(entries);
      if (!mounted) return;

      await showCelebration(
        context,
        title: l10n.celebrateTitle,
        streakLine: l10n.celebrateStreak(streak),
        stampLine: newStamps.isEmpty
            ? null
            : l10n.celebrateStampGet(stampLabel(l10n, newStamps.first.id)),
      );

      await ReviewService.onEntrySaved();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.saveError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final l10n = AppLocalizations.of(context)!;
    final dateFormat =
        DateFormat('M/d (E)', Localizations.localeOf(context).toString());
    final showPrompt = widget.promptText != null && !_promptDismissed;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // システムバックでも書きかけの破棄を確認する
        final navigator = Navigator.of(context);
        if (await _confirmDiscardIfDirty()) navigator.pop();
      },
      child: Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Column(
        children: [
          // ヘッダー（グレープ→スカイ）
          Container(
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
                colors: AppTheme.dimForDark(AppTheme.writeGradient, isDark),
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: l10n.a11yBack,
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    if (await _confirmDiscardIfDirty()) navigator.pop();
                  },
                ),
                Expanded(
                  child: Text(
                    '✍️ ${dateFormat.format(_selectedDate)}',
                    semanticsLabel: dateFormat.format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildSavePill(l10n),
              ],
            ),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDateNav(isDark, l10n),
                  const SizedBox(height: 14),
                  _buildMoodRow(isDark, l10n),
                  const SizedBox(height: 14),
                  if (showPrompt) ...[
                    _buildPromptChip(isDark, l10n),
                    const SizedBox(height: 12),
                  ],
                  _buildContentField(isDark, l10n),
                  const SizedBox(height: 14),
                  _buildTagsField(isDark, l10n),
                  const SizedBox(height: 28),
                  _buildBigSave(l10n),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSavePill(AppLocalizations l10n) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _isSaving ? null : _saveDiary,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.popGrape,
                  ),
                )
              : Text(
                  l10n.save,
                  style: const TextStyle(
                    color: AppTheme.popGrape,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDateNav(bool isDark, AppLocalizations l10n) {
    Widget navBtn(IconData icon, VoidCallback onTap, String tip) {
      return IconButton(
        icon: Icon(icon, color: AppTheme.subTextColor(isDark)),
        onPressed: onTap,
        tooltip: tip,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          navBtn(Icons.chevron_left, () async {
            if (!await _confirmDiscardIfDirty()) return;
            setState(() => _selectedDate =
                _selectedDate.subtract(const Duration(days: 1)));
            _loadEntryForDate(_selectedDate);
          }, l10n.previousDay),
          Expanded(
            child: TextButton(
              onPressed: _selectDate,
              child: Text(
                DateFormat('yyyy/M/d').format(_selectedDate),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor(isDark),
                ),
              ),
            ),
          ),
          if (!_isToday(_selectedDate))
            navBtn(Icons.today, () async {
              if (!await _confirmDiscardIfDirty()) return;
              setState(() => _selectedDate = DateTime.now());
              _loadEntryForDate(DateTime.now());
            }, l10n.goToToday),
          navBtn(Icons.chevron_right, () async {
            if (!await _confirmDiscardIfDirty()) return;
            setState(() =>
                _selectedDate = _selectedDate.add(const Duration(days: 1)));
            _loadEntryForDate(_selectedDate);
          }, l10n.nextDay),
        ],
      ),
    );
  }

  Widget _buildMoodRow(bool isDark, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moodOptions(l10n).map((mood) {
        final selected = _selectedMood == mood.emoji;
        return MoodButton(
          mood: mood,
          selected: selected,
          isDark: isDark,
          onTap: () =>
              setState(() => _selectedMood = selected ? '' : mood.emoji),
        );
      }).toList(),
    );
  }

  Widget _buildPromptChip(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF322B3E) : const Color(0xFFF5F1FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '💡 ${l10n.writePromptHint(widget.promptText!)}',
              semanticsLabel: l10n.writePromptHint(widget.promptText!),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? const Color(0xFFC7B8E8)
                    : const Color(0xFF8A5CFF),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l10n.a11yCloseHint,
            excludeSemantics: true,
            onTap: () => setState(() => _promptDismissed = true),
            child: InkWell(
              onTap: () => setState(() => _promptDismissed = true),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.close,
                    size: 18, color: AppTheme.subTextColor(isDark)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentField(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: TextFormField(
        controller: _contentController,
        minLines: 8,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: AppTheme.textColor(isDark),
        ),
        decoration: InputDecoration(
          hintText: l10n.diaryPlaceholder,
          hintStyle: TextStyle(color: AppTheme.subTextColor(isDark)),
          border: InputBorder.none,
          isCollapsed: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.diaryValidationError;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTagsField(bool isDark, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextFormField(
        controller: _tagsController,
        style: TextStyle(color: AppTheme.textColor(isDark)),
        decoration: InputDecoration(
          icon: const ExcludeSemantics(
            child: Text('🏷️', style: TextStyle(fontSize: 18)),
          ),
          hintText: l10n.tagsPlaceholder,
          hintStyle: TextStyle(color: AppTheme.subTextColor(isDark)),
          helperText: l10n.tagsHelper,
          helperStyle: TextStyle(color: AppTheme.subTextColor(isDark)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBigSave(AppLocalizations l10n) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: AppTheme.popGrapeShadow, offset: Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _isSaving ? null : _saveDiary,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppTheme.writeGradient),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                _isSaving ? l10n.saving : '💾 ${l10n.save}',
                semanticsLabel: _isSaving ? l10n.saving : l10n.save,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
