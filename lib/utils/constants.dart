
/// アプリ全体で使用する定数
library;

class AppConstants {
  // アプリ情報
  static const String appName = 'Daily Diary';
  static const String appVersion = '1.0.38';

  // こども向け学習サイト（ICP 上の静的サイト）。
  // ホームと設定の 2 箇所から開くので定数に置く。
  static const String kidsSiteUrl =
      'https://iqjbc-7aaaa-aaaaj-qnnsa-cai.icp0.io/';

  // Google Drive バックアップ用 OAuth Web クライアント ID（secret ではない）。
  // 空にすると Drive バックアップ機能そのものが UI から消える（機能ゲート兼用）。
  // GCP プロジェクト daily-diary（fwyasu11）の「ウェブ アプリケーション」型クライアント。
  static const String googleServerClientId =
      '441446918402-qv4lhqlpnv32ihgts6uesohtcurma8h2.apps.googleusercontent.com';

  // 設定キー（SharedPreferences）
  static const String prefAppLockEnabled = 'app_lock_enabled';
  static const String prefLastBackupAt = 'last_backup_at';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefDriveSignedIn = 'drive_signed_in';
  static const String prefDriveAccountEmail = 'drive_account_email';
  static const String prefDriveAutoBackup = 'drive_auto_backup';
  static const String prefDriveLastBackupAt = 'drive_last_backup_at';
  static const String prefDriveLastBackupError = 'drive_last_backup_error';
  static const String prefPromptDismissedDate = 'prompt_dismissed_date';
  static const String prefEarnedStamps = 'earned_stamps';

  // 気分の絵文字（ゆるのり版: 5スタンプ）
  static const List<String> moods = [
    '😆',  // たのしい
    '🙂',  // いいかんじ
    '😐',  // ふつう
    '😢',  // かなしい
    '😠',  // おこり
  ];

  // エクスポート形式
  static const List<String> exportFormats = [
    'JSON',
    'CSV',
    'Markdown',
  ];

  // パディング・マージン
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // ボーダー
  static const double borderRadius = 18.0;
  static const double borderRadiusLarge = 24.0;

  // フォントサイズ
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;

  // アイコンサイズ
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // アニメーション
  static const Duration animationDuration = Duration(milliseconds: 300);

  // 広告。本番の ID はこの公開リポジトリに置かない。リリースは非公開の daily-diary の
  // android-build.yml が --dart-define=ADMOB_BANNER_ANDROID=... で渡す。
  // 渡されていないときは Google のテスト用 ID（debug / profile）で、release ビルドでは広告を出さない。
  static const String _adMobBannerIdAndroidRelease =
      String.fromEnvironment('ADMOB_BANNER_ANDROID');
  static const bool adMobReleaseIdGiven = _adMobBannerIdAndroidRelease != '';
  static const String adMobBannerIdAndroid = adMobReleaseIdGiven
      ? _adMobBannerIdAndroidRelease
      : 'ca-app-pub-3940256099942544/6300978111'; // Google のテスト用
  static const String adMobBannerIdIOS = 'ca-app-pub-3940256099942544/2934735716';  // テスト用
}
