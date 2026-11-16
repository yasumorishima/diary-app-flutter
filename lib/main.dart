import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:diary_app/l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'screens/home_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/onboarding_screen.dart';
import 'models/diary_entry.dart';
import 'models/program_session.dart';
import 'services/app_lock_service.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

void main() async {
  // Flutter初期化
  WidgetsFlutterBinding.ensureInitialized();

  // 日本語ロケール初期化
  await initializeDateFormatting('ja_JP', null);

  // Hive初期化
  await Hive.initFlutter();

  // アダプター登録（program_session は既存データ互換のため残す）
  Hive.registerAdapter(DiaryEntryAdapter());
  Hive.registerAdapter(ProgramSessionAdapter());

  // Google Mobile Ads初期化（Web版ではスキップ）
  if (!kIsWeb) {
    if (!kReleaseMode || AppConstants.adMobReleaseIdGiven) {
      await MobileAds.instance.initialize();
    }
  }

  // 通知プラグイン初期化（Web版ではスキップ、権限要求はしない）
  await NotificationService.instance.init();

  // LocaleProvider初期化
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const DiaryApp(),
    ),
  );
}

class DiaryApp extends StatefulWidget {
  const DiaryApp({super.key});

  @override
  State<DiaryApp> createState() => _DiaryAppState();
}

class _DiaryAppState extends State<DiaryApp> with WidgetsBindingObserver {
  // アプリロック状態
  bool _locked = false;
  bool _authInProgress = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  // 初回オンボーディング表示判定（null = 読み込み中）
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAppLock();
    _initOnboarding();
    // 初期化時にプラットフォームの明るさを設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      context.read<ThemeProvider>().updatePlatformBrightness(brightness);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 初回オンボーディング表示済みフラグを読み込む
  Future<void> _initOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(AppConstants.prefOnboardingDone) ?? false;
    if (mounted) setState(() => _onboardingDone = done);
  }

  /// 起動時: ロック有効状態をキャッシュし、有効ならロック状態で開始
  Future<void> _initAppLock() async {
    if (kIsWeb) return;
    await AppLockService.instance.load();
    if (AppLockService.instance.enabled && mounted) {
      setState(() {
        _locked = true;
      });
    }
  }

  /// 認証を実行してロック解除（LockScreen から呼ばれる）
  Future<void> _unlock(String reason) async {
    if (_authInProgress) return;
    _authInProgress = true;
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
      if (ok && mounted) {
        setState(() {
          _locked = false;
        });
      }
    } on PlatformException catch (e) {
      // 端末側の生体認証・画面ロックが後から削除された場合は、
      // 締め出し防止のためアプリロックを自動解除する
      if (e.code == 'NotEnrolled' ||
          e.code == 'NotAvailable' ||
          e.code == 'PasscodeNotSet') {
        await AppLockService.instance.setEnabled(false);
        if (mounted) {
          setState(() {
            _locked = false;
          });
        }
      }
      // それ以外（LockedOut 等）はロック画面のボタンから再試行
    } catch (_) {
      // 想定外の失敗では解除しない（ボタンから再試行可能）
    } finally {
      _authInProgress = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    if (state == AppLifecycleState.paused &&
        AppLockService.instance.enabled &&
        !_authInProgress &&
        !_locked) {
      setState(() {
        _locked = true;
      });
    }
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    context.read<ThemeProvider>().updatePlatformBrightness(brightness);
  }

  Widget _buildHome() {
    if (_onboardingDone == null) {
      return const Scaffold(
        backgroundColor: AppTheme.lightBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_onboardingDone == false) {
      return OnboardingScreen(
        onFinish: () => setState(() => _onboardingDone = true),
      );
    }
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,

          // 多言語対応
          locale: localeProvider.locale,
          // material_ui の delegates は Material・Cupertino・Widgets の 3 つを含む
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: LocaleProvider.supportedLocales,
          // 未対応言語の端末が supportedLocales 先頭の日本語に落ちないよう、
          // 言語コード一致がなければ英語へフォールバックする
          localeListResolutionCallback: (locales, supported) {
            for (final device in locales ?? const <Locale>[]) {
              for (final s in supported) {
                if (s.languageCode == device.languageCode) return s;
              }
            }
            return const Locale('en');
          },

          home: _buildHome(),
          // アプリロック: Navigator 全体の手前にロック画面を重ねる
          builder: (context, child) {
            if (!_locked) return child ?? const SizedBox.shrink();
            return Stack(
              children: [
                if (child != null) child,
                LockScreen(onUnlock: _unlock),
              ],
            );
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
