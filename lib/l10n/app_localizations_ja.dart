// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '📖 連用日記';

  @override
  String get appSubtitle => '毎日の記録を残そう';

  @override
  String get previousDay => '前の日';

  @override
  String get nextDay => '次の日';

  @override
  String get calendar => 'カレンダー';

  @override
  String get writeDiary => '日記を書く';

  @override
  String get random => 'ランダム';

  @override
  String get search => '検索';

  @override
  String get stats => '統計';

  @override
  String get settings => '設定';

  @override
  String get pastToday => '過去の今日';

  @override
  String get export => 'エクスポート';

  @override
  String get tagView => 'タグ別表示';

  @override
  String get date => '日付';

  @override
  String get selectFromCalendar => 'カレンダーから選択';

  @override
  String get pastFutureDateNote => '過去や未来の日付も選択できます';

  @override
  String get todayMood => '今日の気分';

  @override
  String get moodHappy => '嬉しい';

  @override
  String get moodSad => '悲しい';

  @override
  String get moodAngry => '怒り';

  @override
  String get moodSleepy => '眠い';

  @override
  String get moodThinking => '考え中';

  @override
  String get moodCalm => '穏やか';

  @override
  String get moodFun => '楽しい';

  @override
  String get moodAnxious => '不安';

  @override
  String get diary => '日記';

  @override
  String get diaryPlaceholder => '今日あったことを書いてみましょう...';

  @override
  String get diaryValidationError => '日記の内容を入力してください';

  @override
  String get tags => 'タグ';

  @override
  String get tagsPlaceholder => '例: 仕事, 趣味, 家族';

  @override
  String get tagsHelper => 'カンマ区切りで複数入力できます';

  @override
  String get save => '保存する';

  @override
  String get saving => '保存中...';

  @override
  String get searching => '検索中...';

  @override
  String get clear => 'クリア';

  @override
  String get keyword => 'キーワード';

  @override
  String get tag => 'タグ';

  @override
  String get searchDiaryPlaceholder => '日記の内容を検索...';

  @override
  String get searchTagPlaceholder => 'タグ名を入力（例: 仕事）';

  @override
  String get noTagsYet => 'タグがまだありません';

  @override
  String tagSuggestions(int count) {
    return 'タグ候補（$count件）';
  }

  @override
  String get searchKeywordOrTag => 'キーワードまたはタグで検索';

  @override
  String get noDiariesFound => '該当する日記が見つかりませんでした';

  @override
  String get tryDifferentKeyword => '別のキーワードで試してみてください';

  @override
  String searchResults(int count) {
    return '検索結果（$count件）';
  }

  @override
  String get searchInputRequired => 'キーワードまたはタグを入力してください';

  @override
  String searchError(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get statsTitle => '📊 統計';

  @override
  String get recordStats => '記録統計';

  @override
  String get totalDiaries => '総日記数';

  @override
  String get consecutiveRecords => '連続記録';

  @override
  String get averageLength => '平均文字数';

  @override
  String get recordRate => '記録率';

  @override
  String get recordPeriod => '記録期間';

  @override
  String get firstDiary => '最初の日記';

  @override
  String get latestDiary => '最新の日記';

  @override
  String get periodLabel => '記録期間';

  @override
  String get moodRecord => '気分の記録';

  @override
  String get moodUnset => '未設定';

  @override
  String get noDiariesYet => 'まだ日記がありません';

  @override
  String get statsWillAppear => '日記を書き始めると統計が表示されます';

  @override
  String statsLoadError(String error) {
    return '統計の読み込みに失敗しました: $error';
  }

  @override
  String get settingsTitle => '⚙️ 設定';

  @override
  String get displaySettings => '表示設定';

  @override
  String get theme => 'テーマ';

  @override
  String get themeLight => 'ライトモード';

  @override
  String get themeLightDesc => '常に明るいテーマを使用';

  @override
  String get themeDark => 'ダークモード';

  @override
  String get themeDarkDesc => '常に暗いテーマを使用';

  @override
  String get themeSystem => 'システム設定';

  @override
  String get themeSystemDesc => '端末の設定に従う';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get dataExport => 'データエクスポート';

  @override
  String get dataExportDesc => '日記をファイルに保存（機種変更・アンインストール前に）';

  @override
  String get dataImport => 'データインポート';

  @override
  String get dataImportDesc => '保存したファイルから日記を復元';

  @override
  String get deleteAllData => '全データ削除';

  @override
  String get deleteAllDataDesc => '全ての日記を削除します（取り消せません）';

  @override
  String get deviceMigration => 'データのバックアップと移行';

  @override
  String get dataLossWarning =>
      '⚠ アプリをアンインストールするとデータは全て削除されます。事前にエクスポートしてください。';

  @override
  String get migrationStep1 => '旧端末で「データエクスポート」';

  @override
  String get migrationStep1Desc => 'ファイルがダウンロードされます';

  @override
  String get migrationStep2 => 'ファイルを新端末に転送';

  @override
  String get migrationStep2Desc => 'メール、クラウド等で転送';

  @override
  String get migrationStep3 => '新端末で「データインポート」';

  @override
  String get migrationStep3Desc => 'ファイルを選択して復元完了';

  @override
  String get appInfo => 'アプリ情報';

  @override
  String get version => 'バージョン';

  @override
  String get appName => 'アプリ名';

  @override
  String get noExportData => 'エクスポートする日記がありません';

  @override
  String exportError(String error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get importDialogTitle => 'データインポート';

  @override
  String importError(String error) {
    return 'インポートに失敗しました: $error';
  }

  @override
  String get fileReadError => 'ファイルの読み込みに失敗しました';

  @override
  String get noValidData => '有効なデータが見つかりませんでした';

  @override
  String get cancel => 'キャンセル';

  @override
  String get import => 'インポート';

  @override
  String get deleteConfirmTitle => '全データ削除';

  @override
  String get deleteConfirmMessage => '全ての日記を削除します。この操作は取り消せません。\n\n本当に削除しますか？';

  @override
  String get delete => '削除する';

  @override
  String get deleteSuccess => '全てのデータを削除しました';

  @override
  String deleteError(String error) {
    return '削除に失敗しました: $error';
  }

  @override
  String get themeSelectTitle => 'テーマ選択';

  @override
  String get selectYear => '年を選択';

  @override
  String thisMonthDiaries(int count) {
    return '今月の日記 ($count件)';
  }

  @override
  String calendarError(String error) {
    return 'エラーが発生しました\n$error';
  }

  @override
  String get pastTodayNote => '日記を続けていると、過去の思い出が見られます';

  @override
  String get edit => '編集';

  @override
  String get randomNoDiary => 'まだ日記がありません';

  @override
  String randomError(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String get randomTryAgain => 'もう一度';

  @override
  String get backToHome => 'ホームへ';

  @override
  String get startWritingDiary => '日記を書いてみましょう';

  @override
  String get saveSaved => '✅ 保存しました！';

  @override
  String saveError(String error) {
    return '❌ エラーが発生しました: $error';
  }

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String pastTodayTitle(String monthDay) {
    return '過去の今日（$monthDay）';
  }

  @override
  String pastTodayNoPastEntries(String monthDay) {
    return '$monthDayの過去の日記はまだありません';
  }

  @override
  String get pastTodayKeepWriting => '日記を書き続けて、思い出を残しましょう';

  @override
  String get searchEnterKeywordOrTag => 'キーワードまたはタグを入力してください';

  @override
  String get searchDiaryContent => '日記の内容を検索';

  @override
  String get count => '件';

  @override
  String get searchByKeywordOrTag => 'キーワードまたはタグで検索';

  @override
  String get searchNoResults => '該当する日記が見つかりませんでした';

  @override
  String get searchTryDifferentKeyword => '別のキーワードで検索してみてください';

  @override
  String get statsRecordStats => '記録統計';

  @override
  String get statsTotalEntries => '合計日記数';

  @override
  String get statsCurrentStreak => '連続記録日数';

  @override
  String get days => '日';

  @override
  String get statsAvgChars => '平均文字数';

  @override
  String get chars => '文字';

  @override
  String get statsWriteRate => '記録率';

  @override
  String get statsPeriod => '記録期間';

  @override
  String get statsRecordingDays => '記録日数';

  @override
  String get statsFirstEntry => '最初の日記';

  @override
  String get statsLatestEntry => '最新の日記';

  @override
  String get daysCount => '日間';

  @override
  String get statsMoodRecord => '気分の記録';

  @override
  String get notSet => '未設定';

  @override
  String get times => '回';

  @override
  String thisMonthEntries(int count) {
    return '今月の日記（$count件）';
  }

  @override
  String exportSuccess(int count) {
    return '$count件の日記をエクスポートしました';
  }

  @override
  String importConfirmMessage(int count) {
    return '$count件の日記をインポートします。\n\nインポートしますか？';
  }

  @override
  String importConflictMessage(int total, int newCount, int duplicateCount) {
    return 'ファイル内: $total件（新規: $newCount件、重複: $duplicateCount件）\n\n重複する日記をどうしますか？';
  }

  @override
  String get importSkipExisting => '既存を残す';

  @override
  String get importOverwrite => '上書き';

  @override
  String importSuccess(int count) {
    return '$count件の日記をインポートしました';
  }

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get urlOpenError => 'URLを開けませんでした';

  @override
  String get goToToday => '今日に戻る';

  @override
  String get reminderSection => 'リマインダー';

  @override
  String get reminderDaily => '毎日のリマインダー';

  @override
  String get reminderDailyDesc => '毎日決まった時刻に通知します';

  @override
  String get reminderTime => '通知時刻';

  @override
  String get reminderNotificationTitle => '今日の日記';

  @override
  String get reminderNotificationBody => '今日の出来事を書き残しましょう';

  @override
  String get reminderPermissionDenied => '通知が許可されていません。端末の設定から通知を許可してください';

  @override
  String get securitySection => 'セキュリティ';

  @override
  String get appLock => 'アプリロック';

  @override
  String get appLockDesc => '起動時に生体認証または画面ロックで保護します';

  @override
  String get appLockUnavailable => 'この端末では生体認証または画面ロックが設定されていません';

  @override
  String get appLockUnlock => 'ロック解除';

  @override
  String get appLockReason => '日記を表示するには認証してください';

  @override
  String lastBackup(String date) {
    return '最終バックアップ: $date';
  }

  @override
  String get lastBackupNever => 'バックアップ履歴がありません';

  @override
  String get backupReminderTitle => 'バックアップのおすすめ';

  @override
  String get backupReminderMessage =>
      '最後のバックアップから30日以上経過しています。データを守るためにエクスポートしましょう';

  @override
  String get backupNow => '今すぐバックアップ';

  @override
  String get later => 'あとで';

  @override
  String get statsEmotionTitle => 'こころの動き';

  @override
  String get statsEmotionSubtitle => '日記の言葉から端末内で自動分析（送信なし）';

  @override
  String get statsTopWordsTitle => '今月よく使った言葉';

  @override
  String get emotionPositive => 'ポジティブ';

  @override
  String get emotionNegative => 'ネガティブ';

  @override
  String get yearReview => '1年の振り返り';

  @override
  String get yearReviewEntries => '書いた日記';

  @override
  String get yearReviewChars => '書いた文字数';

  @override
  String get yearReviewMaxStreak => '最長連続記録';

  @override
  String get yearReviewTopWords => '今年よく使った言葉';

  @override
  String get yearReviewMonthlyMood => '月ごとのこころの動き';

  @override
  String get yearReviewShare => '画像でシェア';

  @override
  String get yearReviewNoData => '日記がまだありません';

  @override
  String get statsMeaningTitle => '意味づけのことば';

  @override
  String get statsMeaningSubtitle => '「気づいた」「だから」など、気づきと理由づけの言葉の密度（100文字あたり）';

  @override
  String get programs => 'プログラム';

  @override
  String get pennebakerTitle => '筆記開示（4日間コース）';

  @override
  String get pennebakerDesc =>
      '心に引っかかっている出来事について、うまく書こうとせず思うまま15分書きます。同じテーマで4日間続けます';

  @override
  String get pennebakerCitation =>
      'Pennebaker & Beall (1986) 以降、200本以上の研究がある書き方です';

  @override
  String get tgtTitle => '3つの良いこと';

  @override
  String get tgtDesc => '今日あった良いことを3つと、その理由を書きます';

  @override
  String get tgtCitation => 'Seligman ら (2005) のポジティブ心理学研究に基づく書き方です';

  @override
  String get programDisclaimer =>
      'これらは研究で効果が報告されている書き方を実践するための機能であり、治療や効果を保証するものではありません';

  @override
  String get startWriting => '書きはじめる';

  @override
  String get continueWriting => 'つづける';

  @override
  String get newCourse => '新しいテーマで始める';

  @override
  String get themeLabel => '書くテーマ（4日間向き合うこと）';

  @override
  String get themeHint => '例: 仕事の失敗、人間関係のもやもや';

  @override
  String get timerKeepWriting => '手を止めずに、思うまま書き続けましょう';

  @override
  String get timerDone => '15分経ちました。区切りのいいところまで書いて終えましょう';

  @override
  String get finishEarlyTitle => '早めに終わりますか？';

  @override
  String get finishEarlyMessage => '研究では15分書き続けることが推奨されています';

  @override
  String get finishSession => '終了して保存';

  @override
  String get sessionSaved => '保存しました（日記本体とは別に保存されます）';

  @override
  String get goodThingLabel => '良かったこと';

  @override
  String get whyLabel => 'なぜ良かった？（任意）';

  @override
  String get tgtDoneToday => '今日は記入済み ✅';

  @override
  String get sessionHistory => 'これまでの記録';

  @override
  String get tgtValidation => '少なくとも1つ書いてください';

  @override
  String get pennebakerCompleted => '4日間コース完了！おつかれさまでした';

  @override
  String get ok => 'OK';

  @override
  String get themeValidation => 'テーマを入力してください';

  @override
  String homeStreakDays(int count) {
    return '$count日つづいてる！';
  }

  @override
  String get homePromptLabel => 'きょうのお題';

  @override
  String get homePromptSkip => '使わなくてもOK';

  @override
  String get writeTodayButton => 'きょうの記録';

  @override
  String get reviewTitle => 'ふりかえり';

  @override
  String get stampsMenu => 'スタンプ';

  @override
  String homeCollectedStamps(int count) {
    return 'あつめたスタンプ $countこ';
  }

  @override
  String get moodGood => 'いいかんじ';

  @override
  String get moodMeh => 'ふつう';

  @override
  String writePromptHint(String prompt) {
    return 'お題「$prompt」— 使わなくてもOK';
  }

  @override
  String get celebrateTitle => 'かけた！やったね';

  @override
  String celebrateStreak(int count) {
    return '$count日れんぞく！🔥';
  }

  @override
  String celebrateStampGet(String name) {
    return 'スタンプ「$name」ゲット！';
  }

  @override
  String get stampsTitle => 'スタンプ集め';

  @override
  String stampsCount(int count) {
    return '$countこ集めた';
  }

  @override
  String get stampLockedHint => 'まだ ひみつ';

  @override
  String get onboardSkip => 'スキップ';

  @override
  String get onboardNext => 'つぎへ';

  @override
  String get onboardStart => 'はじめる！';

  @override
  String get onboard1Title => 'ようこそ！';

  @override
  String get onboard1Body => 'サクッと書ける、ゆるい日記アプリ';

  @override
  String get onboard2Title => '気分タップ→パッと書くだけ';

  @override
  String get onboard2Body => 'お題もあるよ。使わなくてもOK';

  @override
  String get onboard3Title => 'つづけるとスタンプがたまる🎈';

  @override
  String get onboard3Body => '自分のペースでゆるっと続けよう';

  @override
  String get howToUse => '使い方をもう一度見る';

  @override
  String get statsMoodShare => 'きぶんのわりあい';

  @override
  String get statsTopTags => 'よく使ったタグ';

  @override
  String get promptQuestion1 => 'きょう、いちばん笑ったことは？😆';

  @override
  String get promptQuestion2 => 'きょう食べておいしかったものは？🍰';

  @override
  String get promptQuestion3 => 'いま応援してることは？📣';

  @override
  String get promptQuestion4 => 'きょう会えてうれしかった人は？🙌';

  @override
  String get promptQuestion5 => '最近ハマってることは？🎮';

  @override
  String get promptQuestion6 => 'きょうの小さなラッキーは？🍀';

  @override
  String get promptQuestion7 => 'あした楽しみなことは？✨';

  @override
  String get promptQuestion8 => 'きょうの気分を一言で言うと？💬';

  @override
  String get stampNameFirst => 'はじめの一歩';

  @override
  String get stampNameCount10 => '10コ達成';

  @override
  String get stampNameCount30 => '30コ達成';

  @override
  String get stampNameCount50 => '50コ達成';

  @override
  String get stampNameCount100 => '100コ達成';

  @override
  String get stampNameStreak3 => '3日れんぞく';

  @override
  String get stampNameStreak7 => '1週間れんぞく';

  @override
  String get stampNameStreak14 => '2週間れんぞく';

  @override
  String get stampNameStreak30 => '1ヶ月れんぞく';

  @override
  String get statsThisMonth => '今月';
}
