// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '📖 Daily Diary';

  @override
  String get appSubtitle => 'Record your daily life';

  @override
  String get previousDay => 'Previous';

  @override
  String get nextDay => 'Next';

  @override
  String get calendar => 'Calendar';

  @override
  String get writeDiary => 'Write';

  @override
  String get random => 'Random';

  @override
  String get search => 'Search';

  @override
  String get stats => 'Stats';

  @override
  String get settings => 'Settings';

  @override
  String get pastToday => 'Past Today';

  @override
  String get export => 'Export';

  @override
  String get tagView => 'Tags';

  @override
  String get date => 'Date';

  @override
  String get selectFromCalendar => 'Select from calendar';

  @override
  String get pastFutureDateNote => 'You can select past or future dates';

  @override
  String get todayMood => 'Today\'s Mood';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAngry => 'Angry';

  @override
  String get moodSleepy => 'Sleepy';

  @override
  String get moodThinking => 'Thinking';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodFun => 'Fun';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get diary => 'Diary';

  @override
  String get diaryPlaceholder => 'Write about your day...';

  @override
  String get diaryValidationError => 'Please enter diary content';

  @override
  String get tags => 'Tags';

  @override
  String get tagsPlaceholder => 'e.g. work, hobby, family';

  @override
  String get tagsHelper => 'Separate multiple tags with commas';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving...';

  @override
  String get searching => 'Searching...';

  @override
  String get clear => 'Clear';

  @override
  String get keyword => 'Keyword';

  @override
  String get tag => 'Tag';

  @override
  String get searchDiaryPlaceholder => 'Search diary content...';

  @override
  String get searchTagPlaceholder => 'Enter tag name (e.g. work)';

  @override
  String get noTagsYet => 'No tags yet';

  @override
  String tagSuggestions(int count) {
    return 'Tag Suggestions ($count)';
  }

  @override
  String get searchKeywordOrTag => 'Search by keyword or tag';

  @override
  String get noDiariesFound => 'No diaries found';

  @override
  String get tryDifferentKeyword => 'Try a different keyword';

  @override
  String searchResults(int count) {
    return 'Search Results ($count)';
  }

  @override
  String get searchInputRequired => 'Please enter a keyword or tag';

  @override
  String searchError(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get statsTitle => '📊 Statistics';

  @override
  String get recordStats => 'Record Statistics';

  @override
  String get totalDiaries => 'Total Diaries';

  @override
  String get consecutiveRecords => 'Streak';

  @override
  String get averageLength => 'Avg. Length';

  @override
  String get recordRate => 'Record Rate';

  @override
  String get recordPeriod => 'Period';

  @override
  String get firstDiary => 'First Entry';

  @override
  String get latestDiary => 'Latest Entry';

  @override
  String get periodLabel => 'Period';

  @override
  String get moodRecord => 'Mood Record';

  @override
  String get moodUnset => 'Not set';

  @override
  String get noDiariesYet => 'No diaries yet';

  @override
  String get statsWillAppear => 'Statistics will appear once you start writing';

  @override
  String statsLoadError(String error) {
    return 'Failed to load statistics: $error';
  }

  @override
  String get settingsTitle => '⚙️ Settings';

  @override
  String get displaySettings => 'Display';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeLightDesc => 'Always use light theme';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get themeDarkDesc => 'Always use dark theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDesc => 'Follow device settings';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get dataExport => 'Export Data';

  @override
  String get dataExportDesc =>
      'Save diaries to file (before migration or uninstall)';

  @override
  String get dataImport => 'Import Data';

  @override
  String get dataImportDesc => 'Restore diaries from saved file';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteAllDataDesc => 'Delete all diaries (cannot be undone)';

  @override
  String get deviceMigration => 'Backup & Migration Guide';

  @override
  String get dataLossWarning =>
      '⚠ Uninstalling the app will delete all data. Please export your data beforehand.';

  @override
  String get migrationStep1 => 'Export data on old device';

  @override
  String get migrationStep1Desc => 'File will be downloaded';

  @override
  String get migrationStep2 => 'Transfer file to new device';

  @override
  String get migrationStep2Desc => 'Via email, cloud storage, etc.';

  @override
  String get migrationStep3 => 'Import data on new device';

  @override
  String get migrationStep3Desc => 'Select file to complete restoration';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get appName => 'App Name';

  @override
  String get noExportData => 'No diaries to export';

  @override
  String exportError(String error) {
    return 'Export failed: $error';
  }

  @override
  String get importDialogTitle => 'Import Data';

  @override
  String importError(String error) {
    return 'Import failed: $error';
  }

  @override
  String get fileReadError => 'Failed to read file';

  @override
  String get noValidData => 'No valid data found';

  @override
  String get cancel => 'Cancel';

  @override
  String get import => 'Import';

  @override
  String get deleteConfirmTitle => 'Delete All Data';

  @override
  String get deleteConfirmMessage =>
      'All diaries will be deleted. This cannot be undone.\n\nAre you sure?';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSuccess => 'All data has been deleted';

  @override
  String deleteError(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get themeSelectTitle => 'Select Theme';

  @override
  String get selectYear => 'Select Year';

  @override
  String thisMonthDiaries(int count) {
    return 'This Month ($count)';
  }

  @override
  String calendarError(String error) {
    return 'An error occurred\n$error';
  }

  @override
  String get pastTodayNote => 'Keep writing to see past memories';

  @override
  String get edit => 'Edit';

  @override
  String get randomNoDiary => 'No diaries yet';

  @override
  String randomError(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get randomTryAgain => 'Try Again';

  @override
  String get backToHome => 'Home';

  @override
  String get startWritingDiary => 'Start writing your diary';

  @override
  String get saveSaved => '✅ Saved!';

  @override
  String saveError(String error) {
    return '❌ An error occurred: $error';
  }

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String pastTodayTitle(String monthDay) {
    return 'Past Today ($monthDay)';
  }

  @override
  String pastTodayNoPastEntries(String monthDay) {
    return 'No past entries on $monthDay';
  }

  @override
  String get pastTodayKeepWriting => 'Keep writing to build memories';

  @override
  String get searchEnterKeywordOrTag => 'Enter keyword or tag';

  @override
  String get searchDiaryContent => 'Search diary content';

  @override
  String get count => ' entries';

  @override
  String get searchByKeywordOrTag => 'Search by keyword or tag';

  @override
  String get searchNoResults => 'No diaries found';

  @override
  String get searchTryDifferentKeyword => 'Try a different keyword';

  @override
  String get statsRecordStats => 'Record Statistics';

  @override
  String get statsTotalEntries => 'Total Entries';

  @override
  String get statsCurrentStreak => 'Current Streak';

  @override
  String get days => ' days';

  @override
  String get statsAvgChars => 'Average Length';

  @override
  String get chars => ' chars';

  @override
  String get statsWriteRate => 'Record Rate';

  @override
  String get statsPeriod => 'Period';

  @override
  String get statsRecordingDays => 'Days Recorded';

  @override
  String get statsFirstEntry => 'First Entry';

  @override
  String get statsLatestEntry => 'Latest Entry';

  @override
  String get daysCount => ' days';

  @override
  String get statsMoodRecord => 'Mood Record';

  @override
  String get notSet => 'Not Set';

  @override
  String get times => ' times';

  @override
  String thisMonthEntries(int count) {
    return 'This Month\'s Entries ($count)';
  }

  @override
  String exportSuccess(int count) {
    return 'Exported $count diaries';
  }

  @override
  String importConfirmMessage(int count) {
    return '$count diaries will be imported.\n\nProceed?';
  }

  @override
  String importConflictMessage(int total, int newCount, int duplicateCount) {
    return 'File contains: $total entries (New: $newCount, Duplicates: $duplicateCount)\n\nWhat would you like to do with duplicate entries?';
  }

  @override
  String get importSkipExisting => 'Keep existing';

  @override
  String get importOverwrite => 'Overwrite';

  @override
  String importSuccess(int count) {
    return 'Imported $count diaries';
  }

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get urlOpenError => 'Could not open URL';

  @override
  String get goToToday => 'Go to Today';

  @override
  String get reminderSection => 'Reminder';

  @override
  String get reminderDaily => 'Daily reminder';

  @override
  String get reminderDailyDesc => 'Get a notification at a set time every day';

  @override
  String get reminderTime => 'Notification time';

  @override
  String get reminderNotificationTitle => 'Today\'s diary';

  @override
  String get reminderNotificationBody =>
      'Take a moment to write about your day';

  @override
  String get reminderPermissionDenied =>
      'Notifications are not allowed. Please enable them in system settings';

  @override
  String get securitySection => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockDesc =>
      'Protect the app with biometrics or your screen lock';

  @override
  String get appLockUnavailable =>
      'Biometrics or screen lock is not set up on this device';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockReason => 'Authenticate to view your diary';

  @override
  String lastBackup(String date) {
    return 'Last backup: $date';
  }

  @override
  String get lastBackupNever => 'No backup yet';

  @override
  String get backupReminderTitle => 'Backup recommended';

  @override
  String get backupReminderMessage =>
      'It\'s been over 30 days since your last backup. Export your diary to keep it safe';

  @override
  String get backupNow => 'Back up now';

  @override
  String get later => 'Later';

  @override
  String get statsEmotionTitle => 'Mood insights';

  @override
  String get statsEmotionSubtitle =>
      'Analyzed on your device from your words (nothing is sent)';

  @override
  String get statsTopWordsTitle => 'Frequent words this month';

  @override
  String get emotionPositive => 'Positive';

  @override
  String get emotionNegative => 'Negative';

  @override
  String get yearReview => 'Year in Review';

  @override
  String get yearReviewEntries => 'Entries written';

  @override
  String get yearReviewChars => 'Characters written';

  @override
  String get yearReviewMaxStreak => 'Longest streak';

  @override
  String get yearReviewTopWords => 'Frequent words this year';

  @override
  String get yearReviewMonthlyMood => 'Monthly mood';

  @override
  String get yearReviewShare => 'Share as image';

  @override
  String get yearReviewNoData => 'No diary entries yet';

  @override
  String get statsMeaningTitle => 'Meaning-making words';

  @override
  String get statsMeaningSubtitle =>
      'Density of insight and reasoning words per 100 characters';

  @override
  String get programs => 'Programs';

  @override
  String get pennebakerTitle => 'Expressive Writing (4-day course)';

  @override
  String get pennebakerDesc =>
      'Write for 15 minutes about something weighing on your mind, without editing. Continue the same topic for 4 days';

  @override
  String get pennebakerCitation =>
      'Based on Pennebaker & Beall (1986) and 200+ subsequent studies';

  @override
  String get tgtTitle => 'Three Good Things';

  @override
  String get tgtDesc => 'Write three things that went well today, and why';

  @override
  String get tgtCitation =>
      'Based on positive psychology research by Seligman et al. (2005)';

  @override
  String get programDisclaimer =>
      'These features help you practice writing methods studied in research. They are not medical treatment and no effects are guaranteed';

  @override
  String get startWriting => 'Start writing';

  @override
  String get continueWriting => 'Continue';

  @override
  String get newCourse => 'Start a new topic';

  @override
  String get themeLabel => 'Your topic for these 4 days';

  @override
  String get themeHint => 'e.g. a conflict, a loss, something on your mind';

  @override
  String get timerKeepWriting => 'Keep writing without stopping to edit';

  @override
  String get timerDone => '15 minutes are up — finish your thought and wrap up';

  @override
  String get finishEarlyTitle => 'Finish early?';

  @override
  String get finishEarlyMessage =>
      'Research protocols recommend writing for the full 15 minutes';

  @override
  String get finishSession => 'Finish and save';

  @override
  String get sessionSaved => 'Saved (kept separate from your diary entries)';

  @override
  String get goodThingLabel => 'Good thing';

  @override
  String get whyLabel => 'Why was it good? (optional)';

  @override
  String get tgtDoneToday => 'Done for today ✅';

  @override
  String get sessionHistory => 'History';

  @override
  String get tgtValidation => 'Write at least one';

  @override
  String get pennebakerCompleted => '4-day course complete — well done!';

  @override
  String get ok => 'OK';

  @override
  String get themeValidation => 'Please enter your topic';

  @override
  String homeStreakDays(int count) {
    return '$count days in a row!';
  }

  @override
  String get homePromptLabel => 'Today\'s prompt';

  @override
  String get homePromptSkip => 'Skip if you like';

  @override
  String get writeTodayButton => 'Write today';

  @override
  String get reviewTitle => 'Look back';

  @override
  String get stampsMenu => 'Stamps';

  @override
  String homeCollectedStamps(int count) {
    return '$count stamps collected';
  }

  @override
  String get moodGood => 'Good';

  @override
  String get moodMeh => 'Meh';

  @override
  String writePromptHint(String prompt) {
    return 'Prompt: $prompt — skip if you like';
  }

  @override
  String get celebrateTitle => 'You did it!';

  @override
  String celebrateStreak(int count) {
    return '$count-day streak! 🔥';
  }

  @override
  String celebrateStampGet(String name) {
    return 'Got the $name stamp!';
  }

  @override
  String get stampsTitle => 'Stamp collection';

  @override
  String stampsCount(int count) {
    return '$count collected';
  }

  @override
  String get stampLockedHint => 'Still a secret';

  @override
  String get onboardSkip => 'Skip';

  @override
  String get onboardNext => 'Next';

  @override
  String get onboardStart => 'Start!';

  @override
  String get onboard1Title => 'Welcome!';

  @override
  String get onboard1Body => 'A laid-back diary you can jot in a snap';

  @override
  String get onboard2Title => 'Tap a mood, then jot it down';

  @override
  String get onboard2Body => 'There are prompts too — skip if you like';

  @override
  String get onboard3Title => 'Keep it up to collect stamps 🎈';

  @override
  String get onboard3Body => 'Go at your own easy pace';

  @override
  String get howToUse => 'See how it works again';

  @override
  String get statsMoodShare => 'Mood mix';

  @override
  String get statsTopTags => 'Top tags';

  @override
  String get promptQuestion1 => 'What made you laugh most today? 😆';

  @override
  String get promptQuestion2 => 'Best thing you ate today? 🍰';

  @override
  String get promptQuestion3 => 'What are you rooting for right now? 📣';

  @override
  String get promptQuestion4 => 'Who made your day today? 🙌';

  @override
  String get promptQuestion5 => 'What are you into lately? 🎮';

  @override
  String get promptQuestion6 => 'Any small luck today? 🍀';

  @override
  String get promptQuestion7 => 'Anything you look forward to tomorrow? ✨';

  @override
  String get promptQuestion8 => 'Sum up today in one word? 💬';

  @override
  String get stampNameFirst => 'First step';

  @override
  String get stampNameCount10 => '10 entries';

  @override
  String get stampNameCount30 => '30 entries';

  @override
  String get stampNameCount50 => '50 entries';

  @override
  String get stampNameCount100 => '100 entries';

  @override
  String get stampNameStreak3 => '3-day streak';

  @override
  String get stampNameStreak7 => '1-week streak';

  @override
  String get stampNameStreak14 => '2-week streak';

  @override
  String get stampNameStreak30 => '1-month streak';

  @override
  String get statsThisMonth => 'This month';
}
