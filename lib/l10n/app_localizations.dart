import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// アプリのタイトル
  ///
  /// In ja, this message translates to:
  /// **'📖 連用日記'**
  String get appTitle;

  /// アプリのサブタイトル
  ///
  /// In ja, this message translates to:
  /// **'毎日の記録を残そう'**
  String get appSubtitle;

  /// 前の日ボタン
  ///
  /// In ja, this message translates to:
  /// **'前の日'**
  String get previousDay;

  /// 次の日ボタン
  ///
  /// In ja, this message translates to:
  /// **'次の日'**
  String get nextDay;

  /// カレンダーメニュー
  ///
  /// In ja, this message translates to:
  /// **'カレンダー'**
  String get calendar;

  /// 日記を書くメニュー
  ///
  /// In ja, this message translates to:
  /// **'日記を書く'**
  String get writeDiary;

  /// ランダムメニュー
  ///
  /// In ja, this message translates to:
  /// **'ランダム'**
  String get random;

  /// 検索メニュー
  ///
  /// In ja, this message translates to:
  /// **'検索'**
  String get search;

  /// 統計メニュー
  ///
  /// In ja, this message translates to:
  /// **'統計'**
  String get stats;

  /// 設定メニュー
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings;

  /// 過去の今日メニュー
  ///
  /// In ja, this message translates to:
  /// **'過去の今日'**
  String get pastToday;

  /// エクスポートメニュー
  ///
  /// In ja, this message translates to:
  /// **'エクスポート'**
  String get export;

  /// タグ別表示メニュー
  ///
  /// In ja, this message translates to:
  /// **'タグ別表示'**
  String get tagView;

  /// 日付ラベル
  ///
  /// In ja, this message translates to:
  /// **'日付'**
  String get date;

  /// カレンダー選択ツールチップ
  ///
  /// In ja, this message translates to:
  /// **'カレンダーから選択'**
  String get selectFromCalendar;

  /// 日付選択の補足説明
  ///
  /// In ja, this message translates to:
  /// **'過去や未来の日付も選択できます'**
  String get pastFutureDateNote;

  /// 気分選択ラベル
  ///
  /// In ja, this message translates to:
  /// **'今日の気分'**
  String get todayMood;

  /// 気分: 嬉しい
  ///
  /// In ja, this message translates to:
  /// **'嬉しい'**
  String get moodHappy;

  /// 気分: 悲しい
  ///
  /// In ja, this message translates to:
  /// **'悲しい'**
  String get moodSad;

  /// 気分: 怒り
  ///
  /// In ja, this message translates to:
  /// **'怒り'**
  String get moodAngry;

  /// 気分: 眠い
  ///
  /// In ja, this message translates to:
  /// **'眠い'**
  String get moodSleepy;

  /// 気分: 考え中
  ///
  /// In ja, this message translates to:
  /// **'考え中'**
  String get moodThinking;

  /// 気分: 穏やか
  ///
  /// In ja, this message translates to:
  /// **'穏やか'**
  String get moodCalm;

  /// 気分: 楽しい
  ///
  /// In ja, this message translates to:
  /// **'楽しい'**
  String get moodFun;

  /// 気分: 不安
  ///
  /// In ja, this message translates to:
  /// **'不安'**
  String get moodAnxious;

  /// 日記ラベル
  ///
  /// In ja, this message translates to:
  /// **'日記'**
  String get diary;

  /// 日記入力プレースホルダー
  ///
  /// In ja, this message translates to:
  /// **'今日あったことを書いてみましょう...'**
  String get diaryPlaceholder;

  /// 日記入力バリデーションエラー
  ///
  /// In ja, this message translates to:
  /// **'日記の内容を入力してください'**
  String get diaryValidationError;

  /// タグラベル
  ///
  /// In ja, this message translates to:
  /// **'タグ'**
  String get tags;

  /// タグ入力プレースホルダー
  ///
  /// In ja, this message translates to:
  /// **'例: 仕事, 趣味, 家族'**
  String get tagsPlaceholder;

  /// タグ入力ヘルパーテキスト
  ///
  /// In ja, this message translates to:
  /// **'カンマ区切りで複数入力できます'**
  String get tagsHelper;

  /// 保存ボタン
  ///
  /// In ja, this message translates to:
  /// **'保存する'**
  String get save;

  /// 保存中の表示
  ///
  /// In ja, this message translates to:
  /// **'保存中...'**
  String get saving;

  /// 検索中の表示
  ///
  /// In ja, this message translates to:
  /// **'検索中...'**
  String get searching;

  /// クリアボタン
  ///
  /// In ja, this message translates to:
  /// **'クリア'**
  String get clear;

  /// キーワードタブ
  ///
  /// In ja, this message translates to:
  /// **'キーワード'**
  String get keyword;

  /// タグタブ
  ///
  /// In ja, this message translates to:
  /// **'タグ'**
  String get tag;

  /// 日記検索プレースホルダー
  ///
  /// In ja, this message translates to:
  /// **'日記の内容を検索...'**
  String get searchDiaryPlaceholder;

  /// タグ検索プレースホルダー
  ///
  /// In ja, this message translates to:
  /// **'タグ名を入力（例: 仕事）'**
  String get searchTagPlaceholder;

  /// タグが未登録の表示
  ///
  /// In ja, this message translates to:
  /// **'タグがまだありません'**
  String get noTagsYet;

  /// タグ候補件数
  ///
  /// In ja, this message translates to:
  /// **'タグ候補（{count}件）'**
  String tagSuggestions(int count);

  /// 検索ガイド
  ///
  /// In ja, this message translates to:
  /// **'キーワードまたはタグで検索'**
  String get searchKeywordOrTag;

  /// 検索結果なし
  ///
  /// In ja, this message translates to:
  /// **'該当する日記が見つかりませんでした'**
  String get noDiariesFound;

  /// 検索結果なしの補足
  ///
  /// In ja, this message translates to:
  /// **'別のキーワードで試してみてください'**
  String get tryDifferentKeyword;

  /// 検索結果件数
  ///
  /// In ja, this message translates to:
  /// **'検索結果（{count}件）'**
  String searchResults(int count);

  /// 検索入力必須エラー
  ///
  /// In ja, this message translates to:
  /// **'キーワードまたはタグを入力してください'**
  String get searchInputRequired;

  /// 検索エラー表示
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました: {error}'**
  String searchError(String error);

  /// 統計画面タイトル
  ///
  /// In ja, this message translates to:
  /// **'📊 統計'**
  String get statsTitle;

  /// 記録統計セクション
  ///
  /// In ja, this message translates to:
  /// **'記録統計'**
  String get recordStats;

  /// 総日記数ラベル
  ///
  /// In ja, this message translates to:
  /// **'総日記数'**
  String get totalDiaries;

  /// 連続記録ラベル
  ///
  /// In ja, this message translates to:
  /// **'連続記録'**
  String get consecutiveRecords;

  /// 平均文字数ラベル
  ///
  /// In ja, this message translates to:
  /// **'平均文字数'**
  String get averageLength;

  /// 記録率ラベル
  ///
  /// In ja, this message translates to:
  /// **'記録率'**
  String get recordRate;

  /// 記録期間セクション
  ///
  /// In ja, this message translates to:
  /// **'記録期間'**
  String get recordPeriod;

  /// 最初の日記ラベル
  ///
  /// In ja, this message translates to:
  /// **'最初の日記'**
  String get firstDiary;

  /// 最新の日記ラベル
  ///
  /// In ja, this message translates to:
  /// **'最新の日記'**
  String get latestDiary;

  /// 期間ラベル
  ///
  /// In ja, this message translates to:
  /// **'記録期間'**
  String get periodLabel;

  /// 気分記録セクション
  ///
  /// In ja, this message translates to:
  /// **'気分の記録'**
  String get moodRecord;

  /// 気分未設定
  ///
  /// In ja, this message translates to:
  /// **'未設定'**
  String get moodUnset;

  /// 日記が未登録
  ///
  /// In ja, this message translates to:
  /// **'まだ日記がありません'**
  String get noDiariesYet;

  /// 統計未表示の説明
  ///
  /// In ja, this message translates to:
  /// **'日記を書き始めると統計が表示されます'**
  String get statsWillAppear;

  /// 統計読み込みエラー
  ///
  /// In ja, this message translates to:
  /// **'統計の読み込みに失敗しました: {error}'**
  String statsLoadError(String error);

  /// 設定画面タイトル
  ///
  /// In ja, this message translates to:
  /// **'⚙️ 設定'**
  String get settingsTitle;

  /// 表示設定セクション
  ///
  /// In ja, this message translates to:
  /// **'表示設定'**
  String get displaySettings;

  /// テーマラベル
  ///
  /// In ja, this message translates to:
  /// **'テーマ'**
  String get theme;

  /// ライトモード
  ///
  /// In ja, this message translates to:
  /// **'ライトモード'**
  String get themeLight;

  /// ライトモード説明
  ///
  /// In ja, this message translates to:
  /// **'常に明るいテーマを使用'**
  String get themeLightDesc;

  /// ダークモード
  ///
  /// In ja, this message translates to:
  /// **'ダークモード'**
  String get themeDark;

  /// ダークモード説明
  ///
  /// In ja, this message translates to:
  /// **'常に暗いテーマを使用'**
  String get themeDarkDesc;

  /// システム設定
  ///
  /// In ja, this message translates to:
  /// **'システム設定'**
  String get themeSystem;

  /// システム設定説明
  ///
  /// In ja, this message translates to:
  /// **'端末の設定に従う'**
  String get themeSystemDesc;

  /// データ管理セクション
  ///
  /// In ja, this message translates to:
  /// **'データ管理'**
  String get dataManagement;

  /// データエクスポート
  ///
  /// In ja, this message translates to:
  /// **'データエクスポート'**
  String get dataExport;

  /// エクスポート説明
  ///
  /// In ja, this message translates to:
  /// **'日記をファイルに保存（機種変更・アンインストール前に）'**
  String get dataExportDesc;

  /// データインポート
  ///
  /// In ja, this message translates to:
  /// **'データインポート'**
  String get dataImport;

  /// インポート説明
  ///
  /// In ja, this message translates to:
  /// **'保存したファイルから日記を復元'**
  String get dataImportDesc;

  /// 全データ削除
  ///
  /// In ja, this message translates to:
  /// **'全データ削除'**
  String get deleteAllData;

  /// 全データ削除説明
  ///
  /// In ja, this message translates to:
  /// **'全ての日記を削除します（取り消せません）'**
  String get deleteAllDataDesc;

  /// バックアップ・移行説明タイトル
  ///
  /// In ja, this message translates to:
  /// **'データのバックアップと移行'**
  String get deviceMigration;

  /// アンインストール時のデータ消失警告
  ///
  /// In ja, this message translates to:
  /// **'⚠ アプリをアンインストールするとデータは全て削除されます。事前にエクスポートしてください。'**
  String get dataLossWarning;

  /// 移行手順1
  ///
  /// In ja, this message translates to:
  /// **'旧端末で「データエクスポート」'**
  String get migrationStep1;

  /// 移行手順1説明
  ///
  /// In ja, this message translates to:
  /// **'ファイルがダウンロードされます'**
  String get migrationStep1Desc;

  /// 移行手順2
  ///
  /// In ja, this message translates to:
  /// **'ファイルを新端末に転送'**
  String get migrationStep2;

  /// 移行手順2説明
  ///
  /// In ja, this message translates to:
  /// **'メール、クラウド等で転送'**
  String get migrationStep2Desc;

  /// 移行手順3
  ///
  /// In ja, this message translates to:
  /// **'新端末で「データインポート」'**
  String get migrationStep3;

  /// 移行手順3説明
  ///
  /// In ja, this message translates to:
  /// **'ファイルを選択して復元完了'**
  String get migrationStep3Desc;

  /// アプリ情報セクション
  ///
  /// In ja, this message translates to:
  /// **'アプリ情報'**
  String get appInfo;

  /// バージョンラベル
  ///
  /// In ja, this message translates to:
  /// **'バージョン'**
  String get version;

  /// アプリ名ラベル
  ///
  /// In ja, this message translates to:
  /// **'アプリ名'**
  String get appName;

  /// エクスポートデータなしエラー
  ///
  /// In ja, this message translates to:
  /// **'エクスポートする日記がありません'**
  String get noExportData;

  /// エクスポートエラー
  ///
  /// In ja, this message translates to:
  /// **'エクスポートに失敗しました: {error}'**
  String exportError(String error);

  /// インポートダイアログタイトル
  ///
  /// In ja, this message translates to:
  /// **'データインポート'**
  String get importDialogTitle;

  /// インポートエラー
  ///
  /// In ja, this message translates to:
  /// **'インポートに失敗しました: {error}'**
  String importError(String error);

  /// ファイル読み込みエラー
  ///
  /// In ja, this message translates to:
  /// **'ファイルの読み込みに失敗しました'**
  String get fileReadError;

  /// 有効データなしエラー
  ///
  /// In ja, this message translates to:
  /// **'有効なデータが見つかりませんでした'**
  String get noValidData;

  /// キャンセルボタン
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// インポートボタン
  ///
  /// In ja, this message translates to:
  /// **'インポート'**
  String get import;

  /// 削除確認タイトル
  ///
  /// In ja, this message translates to:
  /// **'全データ削除'**
  String get deleteConfirmTitle;

  /// 削除確認メッセージ
  ///
  /// In ja, this message translates to:
  /// **'全ての日記を削除します。この操作は取り消せません。\n\n本当に削除しますか？'**
  String get deleteConfirmMessage;

  /// 削除ボタン
  ///
  /// In ja, this message translates to:
  /// **'削除する'**
  String get delete;

  /// 削除成功メッセージ
  ///
  /// In ja, this message translates to:
  /// **'全てのデータを削除しました'**
  String get deleteSuccess;

  /// 削除エラー
  ///
  /// In ja, this message translates to:
  /// **'削除に失敗しました: {error}'**
  String deleteError(String error);

  /// テーマ選択ダイアログタイトル
  ///
  /// In ja, this message translates to:
  /// **'テーマ選択'**
  String get themeSelectTitle;

  /// 年選択ダイアログタイトル
  ///
  /// In ja, this message translates to:
  /// **'年を選択'**
  String get selectYear;

  /// 今月の日記数
  ///
  /// In ja, this message translates to:
  /// **'今月の日記 ({count}件)'**
  String thisMonthDiaries(int count);

  /// カレンダーエラー表示
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました\n{error}'**
  String calendarError(String error);

  /// 過去の今日説明
  ///
  /// In ja, this message translates to:
  /// **'日記を続けていると、過去の思い出が見られます'**
  String get pastTodayNote;

  /// 編集ボタン
  ///
  /// In ja, this message translates to:
  /// **'編集'**
  String get edit;

  /// ランダム画面で日記なし
  ///
  /// In ja, this message translates to:
  /// **'まだ日記がありません'**
  String get randomNoDiary;

  /// ランダムエラー
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました: {error}'**
  String randomError(String error);

  /// もう一度ボタン
  ///
  /// In ja, this message translates to:
  /// **'もう一度'**
  String get randomTryAgain;

  /// ホームへ戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'ホームへ'**
  String get backToHome;

  /// 日記を書き始める誘導
  ///
  /// In ja, this message translates to:
  /// **'日記を書いてみましょう'**
  String get startWritingDiary;

  /// 保存成功メッセージ
  ///
  /// In ja, this message translates to:
  /// **'✅ 保存しました！'**
  String get saveSaved;

  /// 保存時のエラーメッセージ
  ///
  /// In ja, this message translates to:
  /// **'❌ エラーが発生しました: {error}'**
  String saveError(String error);

  /// 言語設定項目
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get language;

  /// 言語選択ダイアログタイトル
  ///
  /// In ja, this message translates to:
  /// **'言語を選択'**
  String get selectLanguage;

  /// 過去の今日画面タイトル
  ///
  /// In ja, this message translates to:
  /// **'過去の今日（{monthDay}）'**
  String pastTodayTitle(String monthDay);

  /// 過去の今日 - 日記なしメッセージ
  ///
  /// In ja, this message translates to:
  /// **'{monthDay}の過去の日記はまだありません'**
  String pastTodayNoPastEntries(String monthDay);

  /// 過去の今日 - 継続メッセージ
  ///
  /// In ja, this message translates to:
  /// **'日記を書き続けて、思い出を残しましょう'**
  String get pastTodayKeepWriting;

  /// 検索 - 入力促進メッセージ
  ///
  /// In ja, this message translates to:
  /// **'キーワードまたはタグを入力してください'**
  String get searchEnterKeywordOrTag;

  /// 検索 - プレースホルダー
  ///
  /// In ja, this message translates to:
  /// **'日記の内容を検索'**
  String get searchDiaryContent;

  /// 件数の単位
  ///
  /// In ja, this message translates to:
  /// **'件'**
  String get count;

  /// 検索 - 空状態メッセージ
  ///
  /// In ja, this message translates to:
  /// **'キーワードまたはタグで検索'**
  String get searchByKeywordOrTag;

  /// 検索 - 結果なしメッセージ
  ///
  /// In ja, this message translates to:
  /// **'該当する日記が見つかりませんでした'**
  String get searchNoResults;

  /// 検索 - 再試行メッセージ
  ///
  /// In ja, this message translates to:
  /// **'別のキーワードで検索してみてください'**
  String get searchTryDifferentKeyword;

  /// 統計 - 記録統計セクション
  ///
  /// In ja, this message translates to:
  /// **'記録統計'**
  String get statsRecordStats;

  /// 統計 - 合計日記数
  ///
  /// In ja, this message translates to:
  /// **'合計日記数'**
  String get statsTotalEntries;

  /// 統計 - 連続記録日数
  ///
  /// In ja, this message translates to:
  /// **'連続記録日数'**
  String get statsCurrentStreak;

  /// 日数の単位
  ///
  /// In ja, this message translates to:
  /// **'日'**
  String get days;

  /// 統計 - 平均文字数
  ///
  /// In ja, this message translates to:
  /// **'平均文字数'**
  String get statsAvgChars;

  /// 文字数の単位
  ///
  /// In ja, this message translates to:
  /// **'文字'**
  String get chars;

  /// 統計 - 記録率
  ///
  /// In ja, this message translates to:
  /// **'記録率'**
  String get statsWriteRate;

  /// 統計 - 記録期間
  ///
  /// In ja, this message translates to:
  /// **'記録期間'**
  String get statsPeriod;

  /// 統計 - 実際に記録した日数
  ///
  /// In ja, this message translates to:
  /// **'記録日数'**
  String get statsRecordingDays;

  /// 統計 - 最初の日記
  ///
  /// In ja, this message translates to:
  /// **'最初の日記'**
  String get statsFirstEntry;

  /// 統計 - 最新の日記
  ///
  /// In ja, this message translates to:
  /// **'最新の日記'**
  String get statsLatestEntry;

  /// 日数（期間）の単位
  ///
  /// In ja, this message translates to:
  /// **'日間'**
  String get daysCount;

  /// 統計 - 気分の記録セクション
  ///
  /// In ja, this message translates to:
  /// **'気分の記録'**
  String get statsMoodRecord;

  /// 気分未設定
  ///
  /// In ja, this message translates to:
  /// **'未設定'**
  String get notSet;

  /// 回数の単位
  ///
  /// In ja, this message translates to:
  /// **'回'**
  String get times;

  /// カレンダー - 今月の日記件数
  ///
  /// In ja, this message translates to:
  /// **'今月の日記（{count}件）'**
  String thisMonthEntries(int count);

  /// エクスポート成功メッセージ
  ///
  /// In ja, this message translates to:
  /// **'{count}件の日記をエクスポートしました'**
  String exportSuccess(int count);

  /// インポート確認メッセージ
  ///
  /// In ja, this message translates to:
  /// **'{count}件の日記をインポートします。\n\nインポートしますか？'**
  String importConfirmMessage(int count);

  /// インポート重複確認メッセージ
  ///
  /// In ja, this message translates to:
  /// **'ファイル内: {total}件（新規: {newCount}件、重複: {duplicateCount}件）\n\n重複する日記をどうしますか？'**
  String importConflictMessage(int total, int newCount, int duplicateCount);

  /// 重複スキップボタン
  ///
  /// In ja, this message translates to:
  /// **'既存を残す'**
  String get importSkipExisting;

  /// 重複上書きボタン
  ///
  /// In ja, this message translates to:
  /// **'上書き'**
  String get importOverwrite;

  /// インポート成功メッセージ
  ///
  /// In ja, this message translates to:
  /// **'{count}件の日記をインポートしました'**
  String importSuccess(int count);

  /// プライバシーポリシー
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacyPolicy;

  /// 利用規約
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get termsOfService;

  /// URL起動エラーメッセージ
  ///
  /// In ja, this message translates to:
  /// **'URLを開けませんでした'**
  String get urlOpenError;

  /// 今日に戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'今日に戻る'**
  String get goToToday;

  /// 設定: リマインダーセクション見出し
  ///
  /// In ja, this message translates to:
  /// **'リマインダー'**
  String get reminderSection;

  /// 毎日のリマインダー設定
  ///
  /// In ja, this message translates to:
  /// **'毎日のリマインダー'**
  String get reminderDaily;

  /// 毎日のリマインダー説明
  ///
  /// In ja, this message translates to:
  /// **'毎日決まった時刻に通知します'**
  String get reminderDailyDesc;

  /// 通知時刻設定
  ///
  /// In ja, this message translates to:
  /// **'通知時刻'**
  String get reminderTime;

  /// リマインダー通知タイトル
  ///
  /// In ja, this message translates to:
  /// **'今日の日記'**
  String get reminderNotificationTitle;

  /// リマインダー通知本文
  ///
  /// In ja, this message translates to:
  /// **'今日の出来事を書き残しましょう'**
  String get reminderNotificationBody;

  /// 通知権限拒否メッセージ
  ///
  /// In ja, this message translates to:
  /// **'通知が許可されていません。端末の設定から通知を許可してください'**
  String get reminderPermissionDenied;

  /// 設定: セキュリティセクション見出し
  ///
  /// In ja, this message translates to:
  /// **'セキュリティ'**
  String get securitySection;

  /// アプリロック設定
  ///
  /// In ja, this message translates to:
  /// **'アプリロック'**
  String get appLock;

  /// アプリロック説明
  ///
  /// In ja, this message translates to:
  /// **'起動時に生体認証または画面ロックで保護します'**
  String get appLockDesc;

  /// アプリロック利用不可メッセージ
  ///
  /// In ja, this message translates to:
  /// **'この端末では生体認証または画面ロックが設定されていません'**
  String get appLockUnavailable;

  /// ロック解除ボタン
  ///
  /// In ja, this message translates to:
  /// **'ロック解除'**
  String get appLockUnlock;

  /// 認証ダイアログの理由文
  ///
  /// In ja, this message translates to:
  /// **'日記を表示するには認証してください'**
  String get appLockReason;

  /// 最終バックアップ日時
  ///
  /// In ja, this message translates to:
  /// **'最終バックアップ: {date}'**
  String lastBackup(String date);

  /// バックアップ未実施
  ///
  /// In ja, this message translates to:
  /// **'バックアップ履歴がありません'**
  String get lastBackupNever;

  /// バックアップ促しバナータイトル
  ///
  /// In ja, this message translates to:
  /// **'バックアップのおすすめ'**
  String get backupReminderTitle;

  /// バックアップ促しバナー本文
  ///
  /// In ja, this message translates to:
  /// **'最後のバックアップから30日以上経過しています。データを守るためにエクスポートしましょう'**
  String get backupReminderMessage;

  /// 今すぐバックアップボタン
  ///
  /// In ja, this message translates to:
  /// **'今すぐバックアップ'**
  String get backupNow;

  /// あとでボタン
  ///
  /// In ja, this message translates to:
  /// **'あとで'**
  String get later;

  /// 感情トレンドカードのタイトル
  ///
  /// In ja, this message translates to:
  /// **'こころの動き'**
  String get statsEmotionTitle;

  /// 感情トレンドの説明（端末内分析）
  ///
  /// In ja, this message translates to:
  /// **'日記の言葉から端末内で自動分析（送信なし）'**
  String get statsEmotionSubtitle;

  /// 今月の頻出語カードのタイトル
  ///
  /// In ja, this message translates to:
  /// **'今月よく使った言葉'**
  String get statsTopWordsTitle;

  /// 感情バーの凡例（ポジティブ側）
  ///
  /// In ja, this message translates to:
  /// **'ポジティブ'**
  String get emotionPositive;

  /// 感情バーの凡例（ネガティブ側）
  ///
  /// In ja, this message translates to:
  /// **'ネガティブ'**
  String get emotionNegative;

  /// 1年の振り返り画面のタイトル
  ///
  /// In ja, this message translates to:
  /// **'1年の振り返り'**
  String get yearReview;

  /// 振り返り: 書いた日記数のラベル
  ///
  /// In ja, this message translates to:
  /// **'書いた日記'**
  String get yearReviewEntries;

  /// 振り返り: 書いた文字数のラベル
  ///
  /// In ja, this message translates to:
  /// **'書いた文字数'**
  String get yearReviewChars;

  /// 振り返り: 最長連続記録のラベル
  ///
  /// In ja, this message translates to:
  /// **'最長連続記録'**
  String get yearReviewMaxStreak;

  /// 振り返り: 今年の頻出語のラベル
  ///
  /// In ja, this message translates to:
  /// **'今年よく使った言葉'**
  String get yearReviewTopWords;

  /// 振り返り: 月別感情のラベル
  ///
  /// In ja, this message translates to:
  /// **'月ごとのこころの動き'**
  String get yearReviewMonthlyMood;

  /// 振り返り画像のシェアボタン
  ///
  /// In ja, this message translates to:
  /// **'画像でシェア'**
  String get yearReviewShare;

  /// 振り返り: 日記なしの表示
  ///
  /// In ja, this message translates to:
  /// **'日記がまだありません'**
  String get yearReviewNoData;

  /// 意味づけ度カードのタイトル
  ///
  /// In ja, this message translates to:
  /// **'意味づけのことば'**
  String get statsMeaningTitle;

  /// 意味づけ度の説明
  ///
  /// In ja, this message translates to:
  /// **'「気づいた」「だから」など、気づきと理由づけの言葉の密度（100文字あたり）'**
  String get statsMeaningSubtitle;

  /// ガイド付きプログラム: programs
  ///
  /// In ja, this message translates to:
  /// **'プログラム'**
  String get programs;

  /// ガイド付きプログラム: pennebakerTitle
  ///
  /// In ja, this message translates to:
  /// **'筆記開示（4日間コース）'**
  String get pennebakerTitle;

  /// ガイド付きプログラム: pennebakerDesc
  ///
  /// In ja, this message translates to:
  /// **'心に引っかかっている出来事について、うまく書こうとせず思うまま15分書きます。同じテーマで4日間続けます'**
  String get pennebakerDesc;

  /// ガイド付きプログラム: pennebakerCitation
  ///
  /// In ja, this message translates to:
  /// **'Pennebaker & Beall (1986) 以降、200本以上の研究がある書き方です'**
  String get pennebakerCitation;

  /// ガイド付きプログラム: tgtTitle
  ///
  /// In ja, this message translates to:
  /// **'3つの良いこと'**
  String get tgtTitle;

  /// ガイド付きプログラム: tgtDesc
  ///
  /// In ja, this message translates to:
  /// **'今日あった良いことを3つと、その理由を書きます'**
  String get tgtDesc;

  /// ガイド付きプログラム: tgtCitation
  ///
  /// In ja, this message translates to:
  /// **'Seligman ら (2005) のポジティブ心理学研究に基づく書き方です'**
  String get tgtCitation;

  /// ガイド付きプログラム: programDisclaimer
  ///
  /// In ja, this message translates to:
  /// **'これらは研究で効果が報告されている書き方を実践するための機能であり、治療や効果を保証するものではありません'**
  String get programDisclaimer;

  /// ガイド付きプログラム: startWriting
  ///
  /// In ja, this message translates to:
  /// **'書きはじめる'**
  String get startWriting;

  /// ガイド付きプログラム: continueWriting
  ///
  /// In ja, this message translates to:
  /// **'つづける'**
  String get continueWriting;

  /// ガイド付きプログラム: newCourse
  ///
  /// In ja, this message translates to:
  /// **'新しいテーマで始める'**
  String get newCourse;

  /// ガイド付きプログラム: themeLabel
  ///
  /// In ja, this message translates to:
  /// **'書くテーマ（4日間向き合うこと）'**
  String get themeLabel;

  /// ガイド付きプログラム: themeHint
  ///
  /// In ja, this message translates to:
  /// **'例: 仕事の失敗、人間関係のもやもや'**
  String get themeHint;

  /// ガイド付きプログラム: timerKeepWriting
  ///
  /// In ja, this message translates to:
  /// **'手を止めずに、思うまま書き続けましょう'**
  String get timerKeepWriting;

  /// ガイド付きプログラム: timerDone
  ///
  /// In ja, this message translates to:
  /// **'15分経ちました。区切りのいいところまで書いて終えましょう'**
  String get timerDone;

  /// ガイド付きプログラム: finishEarlyTitle
  ///
  /// In ja, this message translates to:
  /// **'早めに終わりますか？'**
  String get finishEarlyTitle;

  /// ガイド付きプログラム: finishEarlyMessage
  ///
  /// In ja, this message translates to:
  /// **'研究では15分書き続けることが推奨されています'**
  String get finishEarlyMessage;

  /// ガイド付きプログラム: finishSession
  ///
  /// In ja, this message translates to:
  /// **'終了して保存'**
  String get finishSession;

  /// ガイド付きプログラム: sessionSaved
  ///
  /// In ja, this message translates to:
  /// **'保存しました（日記本体とは別に保存されます）'**
  String get sessionSaved;

  /// ガイド付きプログラム: goodThingLabel
  ///
  /// In ja, this message translates to:
  /// **'良かったこと'**
  String get goodThingLabel;

  /// ガイド付きプログラム: whyLabel
  ///
  /// In ja, this message translates to:
  /// **'なぜ良かった？（任意）'**
  String get whyLabel;

  /// ガイド付きプログラム: tgtDoneToday
  ///
  /// In ja, this message translates to:
  /// **'今日は記入済み ✅'**
  String get tgtDoneToday;

  /// ガイド付きプログラム: sessionHistory
  ///
  /// In ja, this message translates to:
  /// **'これまでの記録'**
  String get sessionHistory;

  /// ガイド付きプログラム: tgtValidation
  ///
  /// In ja, this message translates to:
  /// **'少なくとも1つ書いてください'**
  String get tgtValidation;

  /// ガイド付きプログラム: pennebakerCompleted
  ///
  /// In ja, this message translates to:
  /// **'4日間コース完了！おつかれさまでした'**
  String get pennebakerCompleted;

  /// 汎用OKボタン
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// 筆記開示テーマ未入力の検証文言
  ///
  /// In ja, this message translates to:
  /// **'テーマを入力してください'**
  String get themeValidation;

  /// homeStreakDays
  ///
  /// In ja, this message translates to:
  /// **'{count}日つづいてる！'**
  String homeStreakDays(int count);

  /// No description provided for @homePromptLabel.
  ///
  /// In ja, this message translates to:
  /// **'きょうのお題'**
  String get homePromptLabel;

  /// No description provided for @homePromptSkip.
  ///
  /// In ja, this message translates to:
  /// **'使わなくてもOK'**
  String get homePromptSkip;

  /// No description provided for @writeTodayButton.
  ///
  /// In ja, this message translates to:
  /// **'きょうの記録'**
  String get writeTodayButton;

  /// No description provided for @reviewTitle.
  ///
  /// In ja, this message translates to:
  /// **'ふりかえり'**
  String get reviewTitle;

  /// No description provided for @stampsMenu.
  ///
  /// In ja, this message translates to:
  /// **'スタンプ'**
  String get stampsMenu;

  /// homeCollectedStamps
  ///
  /// In ja, this message translates to:
  /// **'あつめたスタンプ {count}こ'**
  String homeCollectedStamps(int count);

  /// No description provided for @moodGood.
  ///
  /// In ja, this message translates to:
  /// **'いいかんじ'**
  String get moodGood;

  /// No description provided for @moodMeh.
  ///
  /// In ja, this message translates to:
  /// **'ふつう'**
  String get moodMeh;

  /// writePromptHint
  ///
  /// In ja, this message translates to:
  /// **'お題「{prompt}」— 使わなくてもOK'**
  String writePromptHint(String prompt);

  /// No description provided for @celebrateTitle.
  ///
  /// In ja, this message translates to:
  /// **'かけた！やったね'**
  String get celebrateTitle;

  /// celebrateStreak
  ///
  /// In ja, this message translates to:
  /// **'{count}日れんぞく！🔥'**
  String celebrateStreak(int count);

  /// celebrateStampGet
  ///
  /// In ja, this message translates to:
  /// **'スタンプ「{name}」ゲット！'**
  String celebrateStampGet(String name);

  /// No description provided for @stampsTitle.
  ///
  /// In ja, this message translates to:
  /// **'スタンプ集め'**
  String get stampsTitle;

  /// stampsCount
  ///
  /// In ja, this message translates to:
  /// **'{count}こ集めた'**
  String stampsCount(int count);

  /// No description provided for @stampLockedHint.
  ///
  /// In ja, this message translates to:
  /// **'まだ ひみつ'**
  String get stampLockedHint;

  /// No description provided for @onboardSkip.
  ///
  /// In ja, this message translates to:
  /// **'スキップ'**
  String get onboardSkip;

  /// No description provided for @onboardNext.
  ///
  /// In ja, this message translates to:
  /// **'つぎへ'**
  String get onboardNext;

  /// No description provided for @onboardStart.
  ///
  /// In ja, this message translates to:
  /// **'はじめる！'**
  String get onboardStart;

  /// No description provided for @onboard1Title.
  ///
  /// In ja, this message translates to:
  /// **'ようこそ！'**
  String get onboard1Title;

  /// No description provided for @onboard1Body.
  ///
  /// In ja, this message translates to:
  /// **'サクッと書ける、ゆるい日記アプリ'**
  String get onboard1Body;

  /// No description provided for @onboard2Title.
  ///
  /// In ja, this message translates to:
  /// **'気分タップ→パッと書くだけ'**
  String get onboard2Title;

  /// No description provided for @onboard2Body.
  ///
  /// In ja, this message translates to:
  /// **'お題もあるよ。使わなくてもOK'**
  String get onboard2Body;

  /// No description provided for @onboard3Title.
  ///
  /// In ja, this message translates to:
  /// **'つづけるとスタンプがたまる🎈'**
  String get onboard3Title;

  /// No description provided for @onboard3Body.
  ///
  /// In ja, this message translates to:
  /// **'自分のペースでゆるっと続けよう'**
  String get onboard3Body;

  /// No description provided for @howToUse.
  ///
  /// In ja, this message translates to:
  /// **'使い方をもう一度見る'**
  String get howToUse;

  /// No description provided for @statsMoodShare.
  ///
  /// In ja, this message translates to:
  /// **'きぶんのわりあい'**
  String get statsMoodShare;

  /// No description provided for @statsTopTags.
  ///
  /// In ja, this message translates to:
  /// **'よく使ったタグ'**
  String get statsTopTags;

  /// No description provided for @promptQuestion1.
  ///
  /// In ja, this message translates to:
  /// **'きょう、いちばん笑ったことは？😆'**
  String get promptQuestion1;

  /// No description provided for @promptQuestion2.
  ///
  /// In ja, this message translates to:
  /// **'きょう食べておいしかったものは？🍰'**
  String get promptQuestion2;

  /// No description provided for @promptQuestion3.
  ///
  /// In ja, this message translates to:
  /// **'いま応援してることは？📣'**
  String get promptQuestion3;

  /// No description provided for @promptQuestion4.
  ///
  /// In ja, this message translates to:
  /// **'きょう会えてうれしかった人は？🙌'**
  String get promptQuestion4;

  /// No description provided for @promptQuestion5.
  ///
  /// In ja, this message translates to:
  /// **'最近ハマってることは？🎮'**
  String get promptQuestion5;

  /// No description provided for @promptQuestion6.
  ///
  /// In ja, this message translates to:
  /// **'きょうの小さなラッキーは？🍀'**
  String get promptQuestion6;

  /// No description provided for @promptQuestion7.
  ///
  /// In ja, this message translates to:
  /// **'あした楽しみなことは？✨'**
  String get promptQuestion7;

  /// No description provided for @promptQuestion8.
  ///
  /// In ja, this message translates to:
  /// **'きょうの気分を一言で言うと？💬'**
  String get promptQuestion8;

  /// No description provided for @stampNameFirst.
  ///
  /// In ja, this message translates to:
  /// **'はじめの一歩'**
  String get stampNameFirst;

  /// No description provided for @stampNameCount10.
  ///
  /// In ja, this message translates to:
  /// **'10コ達成'**
  String get stampNameCount10;

  /// No description provided for @stampNameCount30.
  ///
  /// In ja, this message translates to:
  /// **'30コ達成'**
  String get stampNameCount30;

  /// No description provided for @stampNameCount50.
  ///
  /// In ja, this message translates to:
  /// **'50コ達成'**
  String get stampNameCount50;

  /// No description provided for @stampNameCount100.
  ///
  /// In ja, this message translates to:
  /// **'100コ達成'**
  String get stampNameCount100;

  /// No description provided for @stampNameStreak3.
  ///
  /// In ja, this message translates to:
  /// **'3日れんぞく'**
  String get stampNameStreak3;

  /// No description provided for @stampNameStreak7.
  ///
  /// In ja, this message translates to:
  /// **'1週間れんぞく'**
  String get stampNameStreak7;

  /// No description provided for @stampNameStreak14.
  ///
  /// In ja, this message translates to:
  /// **'2週間れんぞく'**
  String get stampNameStreak14;

  /// No description provided for @stampNameStreak30.
  ///
  /// In ja, this message translates to:
  /// **'1ヶ月れんぞく'**
  String get stampNameStreak30;

  /// statsThisMonth
  ///
  /// In ja, this message translates to:
  /// **'今月'**
  String get statsThisMonth;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
