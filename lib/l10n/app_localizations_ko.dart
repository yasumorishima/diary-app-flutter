// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '📖 매일 일기';

  @override
  String get appSubtitle => '매일의 기록을 남기자';

  @override
  String get previousDay => '이전 날';

  @override
  String get nextDay => '다음 날';

  @override
  String get calendar => '달력';

  @override
  String get writeDiary => '일기 쓰기';

  @override
  String get random => '랜덤';

  @override
  String get search => '검색';

  @override
  String get stats => '통계';

  @override
  String get settings => '설정';

  @override
  String get pastToday => '과거의 오늘';

  @override
  String get export => '내보내기';

  @override
  String get tagView => '태그';

  @override
  String get date => '날짜';

  @override
  String get selectFromCalendar => '달력에서 선택';

  @override
  String get pastFutureDateNote => '과거 또는 미래 날짜도 선택할 수 있습니다';

  @override
  String get todayMood => '오늘의 기분';

  @override
  String get moodHappy => '기쁨';

  @override
  String get moodSad => '슬픔';

  @override
  String get moodAngry => '화남';

  @override
  String get moodSleepy => '졸림';

  @override
  String get moodThinking => '생각 중';

  @override
  String get moodCalm => '평온함';

  @override
  String get moodFun => '즐거움';

  @override
  String get moodAnxious => '불안';

  @override
  String get diary => '일기';

  @override
  String get diaryPlaceholder => '오늘 있었던 일을 써보세요...';

  @override
  String get diaryValidationError => '일기 내용을 입력해주세요';

  @override
  String get tags => '태그';

  @override
  String get tagsPlaceholder => '예: 일, 취미, 가족';

  @override
  String get tagsHelper => '쉼표로 여러 태그를 구분할 수 있습니다';

  @override
  String get save => '저장';

  @override
  String get saving => '저장 중...';

  @override
  String get searching => '검색 중...';

  @override
  String get clear => '지우기';

  @override
  String get keyword => '키워드';

  @override
  String get tag => '태그';

  @override
  String get searchDiaryPlaceholder => '일기 내용 검색...';

  @override
  String get searchTagPlaceholder => '태그 이름 입력 (예: 일)';

  @override
  String get noTagsYet => '아직 태그가 없습니다';

  @override
  String tagSuggestions(int count) {
    return '태그 제안（$count개）';
  }

  @override
  String get searchKeywordOrTag => '키워드 또는 태그로 검색';

  @override
  String get noDiariesFound => '일기를 찾을 수 없습니다';

  @override
  String get tryDifferentKeyword => '다른 키워드로 시도해보세요';

  @override
  String searchResults(int count) {
    return '검색 결과（$count개）';
  }

  @override
  String get searchInputRequired => '키워드 또는 태그를 입력해주세요';

  @override
  String searchError(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get statsTitle => '📊 통계';

  @override
  String get recordStats => '기록 통계';

  @override
  String get totalDiaries => '총 일기 수';

  @override
  String get consecutiveRecords => '연속 기록';

  @override
  String get averageLength => '평균 글자 수';

  @override
  String get recordRate => '기록률';

  @override
  String get recordPeriod => '기록 기간';

  @override
  String get firstDiary => '첫 번째 일기';

  @override
  String get latestDiary => '최근 일기';

  @override
  String get periodLabel => '기록 기간';

  @override
  String get moodRecord => '기분 기록';

  @override
  String get moodUnset => '미설정';

  @override
  String get noDiariesYet => '아직 일기가 없습니다';

  @override
  String get statsWillAppear => '일기를 쓰기 시작하면 통계가 표시됩니다';

  @override
  String statsLoadError(String error) {
    return '통계 로드 실패: $error';
  }

  @override
  String get settingsTitle => '⚙️ 설정';

  @override
  String get displaySettings => '표시 설정';

  @override
  String get theme => '테마';

  @override
  String get themeLight => '라이트 모드';

  @override
  String get themeLightDesc => '항상 밝은 테마 사용';

  @override
  String get themeDark => '다크 모드';

  @override
  String get themeDarkDesc => '항상 어두운 테마 사용';

  @override
  String get themeSystem => '시스템 설정';

  @override
  String get themeSystemDesc => '기기 설정 따르기';

  @override
  String get dataManagement => '데이터 관리';

  @override
  String get dataExport => '데이터 내보내기';

  @override
  String get dataExportDesc => '일기를 파일로 저장 (기기 변경·삭제 전에)';

  @override
  String get dataImport => '데이터 가져오기';

  @override
  String get dataImportDesc => '저장된 파일에서 일기 복원';

  @override
  String get deleteAllData => '모든 데이터 삭제';

  @override
  String get deleteAllDataDesc => '모든 일기를 삭제합니다 (취소할 수 없음)';

  @override
  String get deviceMigration => '백업 및 데이터 이전';

  @override
  String get dataLossWarning => '⚠ 앱을 삭제하면 모든 데이터가 삭제됩니다. 미리 내보내기를 해주세요.';

  @override
  String get migrationStep1 => '기존 기기에서 \'데이터 내보내기\'';

  @override
  String get migrationStep1Desc => '파일이 다운로드됩니다';

  @override
  String get migrationStep2 => '파일을 새 기기로 전송';

  @override
  String get migrationStep2Desc => '이메일, 클라우드 등으로 전송';

  @override
  String get migrationStep3 => '새 기기에서 \'데이터 가져오기\'';

  @override
  String get migrationStep3Desc => '파일을 선택하여 복원 완료';

  @override
  String get appInfo => '앱 정보';

  @override
  String get version => '버전';

  @override
  String get appName => '앱 이름';

  @override
  String get noExportData => '내보낼 일기가 없습니다';

  @override
  String exportError(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String get importDialogTitle => '데이터 가져오기';

  @override
  String importError(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get fileReadError => '파일 읽기 실패';

  @override
  String get noValidData => '유효한 데이터를 찾을 수 없습니다';

  @override
  String get cancel => '취소';

  @override
  String get import => '가져오기';

  @override
  String get deleteConfirmTitle => '모든 데이터 삭제';

  @override
  String get deleteConfirmMessage =>
      '모든 일기가 삭제됩니다. 이 작업은 취소할 수 없습니다.\n\n정말 삭제하시겠습니까?';

  @override
  String get delete => '삭제';

  @override
  String get deleteSuccess => '모든 데이터가 삭제되었습니다';

  @override
  String deleteError(String error) {
    return '삭제 실패: $error';
  }

  @override
  String get themeSelectTitle => '테마 선택';

  @override
  String get selectYear => '연도 선택';

  @override
  String thisMonthDiaries(int count) {
    return '이번 달 ($count개)';
  }

  @override
  String calendarError(String error) {
    return '오류가 발생했습니다\n$error';
  }

  @override
  String get pastTodayNote => '일기를 계속 쓰면 과거의 추억을 볼 수 있습니다';

  @override
  String get edit => '편집';

  @override
  String get randomNoDiary => '아직 일기가 없습니다';

  @override
  String randomError(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get randomTryAgain => '다시 시도';

  @override
  String get backToHome => '홈으로';

  @override
  String get startWritingDiary => '일기를 써보세요';

  @override
  String get saveSaved => '✅ 저장되었습니다!';

  @override
  String saveError(String error) {
    return '❌ 오류가 발생했습니다: $error';
  }

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String pastTodayTitle(String monthDay) {
    return '과거의 오늘（$monthDay）';
  }

  @override
  String pastTodayNoPastEntries(String monthDay) {
    return '$monthDay의 과거 일기가 아직 없습니다';
  }

  @override
  String get pastTodayKeepWriting => '일기를 계속 써서 추억을 남기세요';

  @override
  String get searchEnterKeywordOrTag => '키워드 또는 태그를 입력하세요';

  @override
  String get searchDiaryContent => '일기 내용 검색';

  @override
  String get count => '개';

  @override
  String get searchByKeywordOrTag => '키워드 또는 태그로 검색';

  @override
  String get searchNoResults => '일기를 찾을 수 없습니다';

  @override
  String get searchTryDifferentKeyword => '다른 키워드로 검색해보세요';

  @override
  String get statsRecordStats => '기록 통계';

  @override
  String get statsTotalEntries => '총 일기 수';

  @override
  String get statsCurrentStreak => '연속 기록일 수';

  @override
  String get days => '일';

  @override
  String get statsAvgChars => '평균 글자 수';

  @override
  String get chars => '자';

  @override
  String get statsWriteRate => '기록률';

  @override
  String get statsPeriod => '기록 기간';

  @override
  String get statsRecordingDays => '기록 일수';

  @override
  String get statsFirstEntry => '첫 일기';

  @override
  String get statsLatestEntry => '최신 일기';

  @override
  String get daysCount => '일간';

  @override
  String get statsMoodRecord => '기분 기록';

  @override
  String get notSet => '미설정';

  @override
  String get times => '회';

  @override
  String thisMonthEntries(int count) {
    return '이번 달 일기（$count개）';
  }

  @override
  String exportSuccess(int count) {
    return '$count개의 일기를 내보냈습니다';
  }

  @override
  String importConfirmMessage(int count) {
    return '$count개의 일기를 가져옵니다.\n\n계속하시겠습니까?';
  }

  @override
  String importConflictMessage(int total, int newCount, int duplicateCount) {
    return '파일 내: $total개 (신규: $newCount개, 중복: $duplicateCount개)\n\n중복되는 일기를 어떻게 하시겠습니까?';
  }

  @override
  String get importSkipExisting => '기존 유지';

  @override
  String get importOverwrite => '덮어쓰기';

  @override
  String importSuccess(int count) {
    return '$count개의 일기를 가져왔습니다';
  }

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get termsOfService => '이용약관';

  @override
  String get urlOpenError => 'URL을 열 수 없습니다';

  @override
  String get goToToday => '오늘로 이동';

  @override
  String get reminderSection => '리마인더';

  @override
  String get reminderDaily => '매일 리마인더';

  @override
  String get reminderDailyDesc => '매일 정해진 시간에 알림을 보냅니다';

  @override
  String get reminderTime => '알림 시각';

  @override
  String get reminderNotificationTitle => '오늘의 일기';

  @override
  String get reminderNotificationBody => '오늘 있었던 일을 기록해 보세요';

  @override
  String get reminderPermissionDenied => '알림이 허용되지 않았습니다. 기기 설정에서 알림을 허용해 주세요';

  @override
  String get securitySection => '보안';

  @override
  String get appLock => '앱 잠금';

  @override
  String get appLockDesc => '생체 인증 또는 화면 잠금으로 보호합니다';

  @override
  String get appLockUnavailable => '이 기기에는 생체 인증 또는 화면 잠금이 설정되어 있지 않습니다';

  @override
  String get appLockUnlock => '잠금 해제';

  @override
  String get appLockReason => '일기를 보려면 인증해 주세요';

  @override
  String lastBackup(String date) {
    return '마지막 백업: $date';
  }

  @override
  String get lastBackupNever => '백업 기록이 없습니다';

  @override
  String get backupReminderTitle => '백업 권장';

  @override
  String get backupReminderMessage =>
      '마지막 백업 후 30일이 지났습니다. 데이터를 지키기 위해 내보내기를 해 주세요';

  @override
  String get backupNow => '지금 백업';

  @override
  String get later => '나중에';

  @override
  String get statsEmotionTitle => '마음의 변화';

  @override
  String get statsEmotionSubtitle => '일기 내용을 기기에서 자동 분석 (전송 없음)';

  @override
  String get statsTopWordsTitle => '이번 달 자주 쓴 말';

  @override
  String get emotionPositive => '긍정';

  @override
  String get emotionNegative => '부정';

  @override
  String get yearReview => '한 해 돌아보기';

  @override
  String get yearReviewEntries => '작성한 일기';

  @override
  String get yearReviewChars => '작성한 글자 수';

  @override
  String get yearReviewMaxStreak => '최장 연속 기록';

  @override
  String get yearReviewTopWords => '올해 자주 쓴 말';

  @override
  String get yearReviewMonthlyMood => '월별 마음 변화';

  @override
  String get yearReviewShare => '이미지로 공유';

  @override
  String get yearReviewNoData => '아직 일기가 없습니다';

  @override
  String get statsMeaningTitle => '의미 만들기 단어';

  @override
  String get statsMeaningSubtitle => '100자당 깨달음과 이유 표현의 밀도';

  @override
  String get programs => '프로그램';

  @override
  String get pennebakerTitle => '표현적 글쓰기 (4일 코스)';

  @override
  String get pennebakerDesc =>
      '마음에 걸리는 일에 대해 다듬지 말고 15분간 자유롭게 씁니다. 같은 주제로 4일간 계속합니다';

  @override
  String get pennebakerCitation =>
      'Pennebaker & Beall (1986) 이후 200편 이상의 연구가 있는 방법입니다';

  @override
  String get tgtTitle => '세 가지 좋은 일';

  @override
  String get tgtDesc => '오늘 있었던 좋은 일 세 가지와 그 이유를 적습니다';

  @override
  String get tgtCitation => 'Seligman 등 (2005)의 긍정심리학 연구에 기반한 방법입니다';

  @override
  String get programDisclaimer =>
      '연구에서 효과가 보고된 글쓰기 방법을 실천하기 위한 기능이며, 치료가 아니고 효과를 보장하지 않습니다';

  @override
  String get startWriting => '글쓰기 시작';

  @override
  String get continueWriting => '계속하기';

  @override
  String get newCourse => '새 주제로 시작';

  @override
  String get themeLabel => '4일간 다룰 주제';

  @override
  String get themeHint => '예: 업무 실수, 인간관계 고민';

  @override
  String get timerKeepWriting => '멈추지 말고 떠오르는 대로 써 보세요';

  @override
  String get timerDone => '15분이 지났습니다. 마무리해 주세요';

  @override
  String get finishEarlyTitle => '일찍 마칠까요?';

  @override
  String get finishEarlyMessage => '연구에서는 15분간 계속 쓰기를 권장합니다';

  @override
  String get finishSession => '마치고 저장';

  @override
  String get sessionSaved => '저장했습니다 (일기와 별도로 보관됩니다)';

  @override
  String get goodThingLabel => '좋았던 일';

  @override
  String get whyLabel => '왜 좋았나요? (선택)';

  @override
  String get tgtDoneToday => '오늘은 완료 ✅';

  @override
  String get sessionHistory => '기록';

  @override
  String get tgtValidation => '하나 이상 적어 주세요';

  @override
  String get pennebakerCompleted => '4일 코스 완료!';

  @override
  String get ok => '확인';

  @override
  String get themeValidation => '주제를 입력해 주세요';

  @override
  String homeStreakDays(int count) {
    return '$count일 연속!';
  }

  @override
  String get homePromptLabel => '오늘의 주제';

  @override
  String get homePromptSkip => '안 써도 괜찮아요';

  @override
  String get writeTodayButton => '오늘 쓰기';

  @override
  String get reviewTitle => '돌아보기';

  @override
  String get stampsMenu => '스탬프';

  @override
  String homeCollectedStamps(int count) {
    return '모은 스탬프 $count개';
  }

  @override
  String get moodGood => '괜찮아';

  @override
  String get moodMeh => '보통';

  @override
  String writePromptHint(String prompt) {
    return '주제: $prompt — 안 써도 OK';
  }

  @override
  String get celebrateTitle => '다 썼어요!';

  @override
  String celebrateStreak(int count) {
    return '$count일 연속! 🔥';
  }

  @override
  String celebrateStampGet(String name) {
    return '「$name」스탬프 획득!';
  }

  @override
  String get stampsTitle => '스탬프 모으기';

  @override
  String stampsCount(int count) {
    return '$count개 모음';
  }

  @override
  String get stampLockedHint => '아직 비밀';

  @override
  String get onboardSkip => '건너뛰기';

  @override
  String get onboardNext => '다음';

  @override
  String get onboardStart => '시작!';

  @override
  String get onboard1Title => '환영해요!';

  @override
  String get onboard1Body => '슥슥 적는 가벼운 일기 앱';

  @override
  String get onboard2Title => '기분 탭하고 슥 쓰기';

  @override
  String get onboard2Body => '주제도 있어요. 안 써도 OK';

  @override
  String get onboard3Title => '계속하면 스탬프가 쌓여요🎈';

  @override
  String get onboard3Body => '내 페이스로 느긋하게';

  @override
  String get howToUse => '사용법 다시 보기';

  @override
  String get statsMoodShare => '기분 비율';

  @override
  String get statsTopTags => '자주 쓴 태그';

  @override
  String get promptQuestion1 => '오늘 가장 웃겼던 일은? 😆';

  @override
  String get promptQuestion2 => '오늘 먹은 것 중 제일 맛있던 건? 🍰';

  @override
  String get promptQuestion3 => '요즘 응원하는 건? 📣';

  @override
  String get promptQuestion4 => '오늘 만나서 반가웠던 사람은? 🙌';

  @override
  String get promptQuestion5 => '요즘 빠져 있는 건? 🎮';

  @override
  String get promptQuestion6 => '오늘의 작은 행운은? 🍀';

  @override
  String get promptQuestion7 => '내일 살짝 기대되는 건? ✨';

  @override
  String get promptQuestion8 => '오늘 기분을 한마디로? 💬';

  @override
  String get stampNameFirst => '첫걸음';

  @override
  String get stampNameCount10 => '10개 달성';

  @override
  String get stampNameCount30 => '30개 달성';

  @override
  String get stampNameCount50 => '50개 달성';

  @override
  String get stampNameCount100 => '100개 달성';

  @override
  String get stampNameStreak3 => '3일 연속';

  @override
  String get stampNameStreak7 => '1주 연속';

  @override
  String get stampNameStreak14 => '2주 연속';

  @override
  String get stampNameStreak30 => '1개월 연속';

  @override
  String get statsThisMonth => '이번 달';
}
