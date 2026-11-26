import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';
import '../utils/a11y_text.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../models/diary_entry.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/streak_service.dart';
import '../services/age_signals_service.dart';
import 'write_screen.dart';
import 'past_today_screen.dart';
import 'random_screen.dart';
import 'search_screen.dart';
import 'stats_screen.dart';
import 'stamps_screen.dart';
import '../widgets/mood_button.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../widgets/language_dialog.dart';

/// ホーム画面（ゆるのり ポップ版）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  int _streak = 0;
  Set<String> _earnedStamps = {};
  String _selectedMood = '';
  bool _promptDismissed = false;
  bool _pressWrite = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadHomeData();
    _loadPromptState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        NotificationService.instance.rescheduleFromPrefs(
          title: l10n.reminderNotificationTitle,
          body: l10n.reminderNotificationBody,
        );
      }
    });
  }

  Locale? _notifLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 言語変更をリマインダー通知の文言に即反映する（従来はホーム再生成まで
    // 旧言語のまま通知されていた）
    final locale = Localizations.localeOf(context);
    if (_notifLocale != null && _notifLocale != locale) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) {
        NotificationService.instance.rescheduleFromPrefs(
          title: l10n.reminderNotificationTitle,
          body: l10n.reminderNotificationBody,
        );
      }
    }
    _notifLocale = locale;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  String _todayKey() => DiaryEntry.generateId(DateTime.now());

  Future<void> _loadHomeData() async {
    final entries = await DatabaseService().getAllEntries();
    final streak = StreakService.currentStreak(entries);
    await StampService.sync(entries);
    final earned = await StampService.earnedIds();
    if (!mounted) return;
    setState(() {
      _streak = streak;
      _earnedStamps = earned;
    });
  }

  Future<void> _loadPromptState() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed =
        prefs.getString(AppConstants.prefPromptDismissedDate) == _todayKey();
    if (!mounted) return;
    setState(() => _promptDismissed = dismissed);
  }

  Future<void> _dismissPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefPromptDismissedDate, _todayKey());
    if (mounted) setState(() => _promptDismissed = true);
  }

  List<String> _prompts(AppLocalizations l10n) => [
        l10n.promptQuestion1,
        l10n.promptQuestion2,
        l10n.promptQuestion3,
        l10n.promptQuestion4,
        l10n.promptQuestion5,
        l10n.promptQuestion6,
        l10n.promptQuestion7,
        l10n.promptQuestion8,
      ];

  String _todayPrompt(AppLocalizations l10n) {
    final now = DateTime.now();
    final doy = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(now.year, 1, 1))
        .inDays;
    final prompts = _prompts(l10n);
    return prompts[doy % prompts.length];
  }

  Future<void> _loadBannerAd() async {
    if (kIsWeb) return;
    // 本番の広告 ID を渡さずに作った release ビルドは広告を出さない（テスト用 ID で出さない）
    if (kReleaseMode && !AppConstants.adMobReleaseIdGiven) return;
    // 年齢シグナルで未成年と分かったら、広告を読み込む前に AdMob の設定を変える
    await AgeSignalsService.instance.applyToAds();
    if (!mounted) return;
    final adUnitId = defaultTargetPlatform == TargetPlatform.android
        ? AppConstants.adMobBannerIdAndroid
        : AppConstants.adMobBannerIdIOS;
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(nonPersonalizedAds: true),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    _bannerAd?.load();
  }

  Future<void> _openWrite() async {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();
    final db = DatabaseService();
    final existing = await db.getEntryByDate(today);
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WriteScreen(
          targetDate: today,
          existingEntry: existing,
          initialMood: _selectedMood.isEmpty ? null : _selectedMood,
          promptText: _promptDismissed ? null : _todayPrompt(l10n),
        ),
      ),
    );
    if (!mounted) return;
    if (result == true) setState(() => _selectedMood = '');
    // お祝い中のシステムバック等、result なしで戻っても保存済みのことが
    // あるため常に再読込する
    _loadHomeData();
  }

  Future<void> _pushScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    // 遷移先のさらに奥（カレンダー→記録 等）で保存されても result は
    // 伝搬されないため、戻ってきたら常に再読込する（ローカル読みで安価）
    if (mounted) _loadHomeData();
  }

  Future<void> _showLanguageDialog() => showLanguageSelectDialog(context);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: Column(
        children: [
          _buildHeader(themeProvider, isDark, l10n),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!_promptDismissed) ...[
                  _buildPromptBubble(isDark, l10n),
                  const SizedBox(height: 16),
                ],
                _buildMoodRow(isDark, l10n),
                const SizedBox(height: 18),
                _buildWriteButton(l10n),
                const SizedBox(height: 18),
                _buildPrimaryMenu(isDark, l10n),
                const SizedBox(height: 14),
                // 中身が日本語のみのサイトなので ja のときだけ出す
                if (Localizations.localeOf(context).languageCode ==
                    'ja') ...[
                  _buildKidsSiteCard(l10n),
                  const SizedBox(height: 14),
                ],
                _buildSecondaryMenu(isDark, l10n),
                const SizedBox(height: 16),
                _buildStampsPeek(isDark, l10n),
              ],
            ),
          ),
          if (_isAdLoaded && _bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
      ThemeProvider themeProvider, bool isDark, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 18,
        right: 12,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppTheme.dimForDark(AppTheme.headerGradient, isDark),
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.appTitle,
                  // 題名の先頭の絵文字は飾り。そのままだと読み上げが
                  // 「本 連用日記」のように読む（2026-09-01 に実機で確認）。
                  semanticsLabel: spokenText(l10n.appTitle),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              _circleBtn(Icons.language, _showLanguageDialog, l10n.language),
              _circleBtn(
                isDark ? Icons.wb_sunny : Icons.nightlight_round,
                themeProvider.toggleTheme,
                isDark ? l10n.a11yLightMode : l10n.a11yDarkMode,
              ),
            ],
          ),
          if (_streak > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFFD0E5), offset: Offset(0, 4)),
                ],
              ),
              child: Text(
                '🔥 ${l10n.homeStreakDays(_streak)}',
                semanticsLabel: l10n.homeStreakDays(_streak),
                style: const TextStyle(
                  color: AppTheme.popPinkText,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap, String label) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
        tooltip: label,
      ),
    );
  }

  Widget _buildPromptBubble(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F3A2C) : const Color(0xFFEAFFF2),
        border: Border.all(
            color: const Color(0xFF4AD991), width: 3, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            // 自分の意味ノードを持たせる。持たせないと周りの文字が親に吸われ、
            // 見出し・質問文・閉じるボタンが 1 個の押せる要素として
            // 続けて読まれる（2026-09-01 に実機で確認）。
            child: Semantics(
              container: true,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.homePromptLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF37B06F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${l10n.homePromptSkip}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6FC79B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _todayPrompt(l10n),
                  semanticsLabel: spokenText(_todayPrompt(l10n)),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C9D5E),
                  ),
                ),
              ],
              ),
            ),
          ),
          Semantics(
            button: true,
            label: l10n.a11yCloseHint,
            excludeSemantics: true,
            onTap: _dismissPrompt,
            child: InkWell(
              onTap: _dismissPrompt,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, size: 18, color: Color(0xFF37B06F)),
              ),
            ),
          ),
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
          size: 56,
          radius: 16,
          emojiSize: 26,
          onTap: () =>
              setState(() => _selectedMood = selected ? '' : mood.emoji),
        );
      }).toList(),
    );
  }

  Widget _buildWriteButton(AppLocalizations l10n) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressWrite = true),
      onTapCancel: () => setState(() => _pressWrite = false),
      onTapUp: (_) => setState(() => _pressWrite = false),
      onTap: _openWrite,
      child: AnimatedScale(
        scale: _pressWrite ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppTheme.writeGradient),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(color: AppTheme.popGrapeShadow, offset: Offset(0, 7)),
            ],
          ),
          child: Text(
            '＋ ${l10n.writeTodayButton}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryMenu(bool isDark, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: [
        _menuChip('📅', l10n.calendar, const Color(0xFFFF7B9C),
            () => _pushScreen(const CalendarScreen())),
        _menuChip('✨', l10n.reviewTitle, const Color(0xFF4DC9FF),
            () => _pushScreen(const StatsScreen())),
        _menuChip('🔍', l10n.search, const Color(0xFFFFB03B),
            () => _pushScreen(const SearchScreen())),
        _menuChip('🎁', l10n.stampsMenu, const Color(0xFF43D19E),
            () => _pushScreen(const StampsScreen())),
      ],
    );
  }

  Widget _menuChip(
      String emoji, String label, Color color, VoidCallback onTap) {
    final chip = Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              ExcludeSemantics(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return MergeSemantics(child: chip);
  }

  // こども向け学習サイト（外部）。設定→アプリ情報にも同じ導線がある
  Widget _buildKidsSiteCard(AppLocalizations l10n) {
    final card = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B2A5B), Color(0xFF5B3A8E)],
          ),
        ),
        child: InkWell(
          key: const Key('home_kids_site'),
          onTap: _openKidsSite,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const ExcludeSemantics(
                    child:
                        Text('\u{1F30C}', style: TextStyle(fontSize: 22))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.kidsSite,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.kidsSiteDesc,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDCD4F2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.open_in_new, size: 18, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
    return MergeSemantics(
        child: Semantics(link: true, child: card));
  }

  Future<void> _openKidsSite() async {
    final uri = Uri.parse(AppConstants.kidsSiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.urlOpenError,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildSecondaryMenu(bool isDark, AppLocalizations l10n) {
    Widget pill(String emoji, String label, VoidCallback onTap) {
      final chip = Material(
        color: AppTheme.cardColor(isDark),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                    child: Text(emoji, style: const TextStyle(fontSize: 16))),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return MergeSemantics(child: chip);
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        pill('📆', l10n.pastToday, () => _pushScreen(const PastTodayScreen())),
        pill('🎲', l10n.random, () => _pushScreen(const RandomScreen())),
        pill('📦', l10n.export, () => _pushScreen(const SettingsScreen())),
        pill('⚙️', l10n.settings, () => _pushScreen(const SettingsScreen())),
      ],
    );
  }

  Widget _buildStampsPeek(bool isDark, AppLocalizations l10n) {
    final earnedList = StampService.all
        .where((s) => _earnedStamps.contains(s.id))
        .toList();
    final card = Material(
      color: isDark ? const Color(0xFF2E2836) : const Color(0xFFFFF4FB),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _pushScreen(const StampsScreen()),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeCollectedStamps(_earnedStamps.length),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? const Color(0xFFE6A8D6)
                      : const Color(0xFFC65CB0),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ...earnedList.take(6).map((s) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFE3F4),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: ExcludeSemantics(
                            child: Text(s.emoji,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      )),
                  if (earnedList.length < StampService.all.length)
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const ExcludeSemantics(
                          child: Text('❓', style: TextStyle(fontSize: 18))),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return MergeSemantics(child: card);
  }
}
