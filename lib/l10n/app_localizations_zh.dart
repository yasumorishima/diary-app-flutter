// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '📖 每日日记';

  @override
  String get appSubtitle => '记录每一天';

  @override
  String get previousDay => '前一天';

  @override
  String get nextDay => '后一天';

  @override
  String get calendar => '日历';

  @override
  String get writeDiary => '写日记';

  @override
  String get random => '随机';

  @override
  String get search => '搜索';

  @override
  String get stats => '统计';

  @override
  String get settings => '设置';

  @override
  String get pastToday => '往年今日';

  @override
  String get export => '导出';

  @override
  String get tagView => '标签';

  @override
  String get date => '日期';

  @override
  String get selectFromCalendar => '从日历选择';

  @override
  String get pastFutureDateNote => '可以选择过去或未来的日期';

  @override
  String get todayMood => '今天的心情';

  @override
  String get moodHappy => '开心';

  @override
  String get moodSad => '难过';

  @override
  String get moodAngry => '生气';

  @override
  String get moodSleepy => '困倦';

  @override
  String get moodThinking => '思考中';

  @override
  String get moodCalm => '平静';

  @override
  String get moodFun => '快乐';

  @override
  String get moodAnxious => '焦虑';

  @override
  String get diary => '日记';

  @override
  String get diaryPlaceholder => '写下今天发生的事...';

  @override
  String get diaryValidationError => '请输入日记内容';

  @override
  String get tags => '标签';

  @override
  String get tagsPlaceholder => '例如：工作，爱好，家人';

  @override
  String get tagsHelper => '用逗号分隔多个标签';

  @override
  String get save => '保存';

  @override
  String get saving => '保存中...';

  @override
  String get searching => '搜索中...';

  @override
  String get clear => '清除';

  @override
  String get keyword => '关键词';

  @override
  String get tag => '标签';

  @override
  String get searchDiaryPlaceholder => '搜索日记内容...';

  @override
  String get searchTagPlaceholder => '输入标签名（例如：工作）';

  @override
  String get noTagsYet => '还没有标签';

  @override
  String tagSuggestions(int count) {
    return '标签建议（$count条）';
  }

  @override
  String get searchKeywordOrTag => '按关键词或标签搜索';

  @override
  String get noDiariesFound => '未找到日记';

  @override
  String get tryDifferentKeyword => '尝试其他关键词';

  @override
  String searchResults(int count) {
    return '搜索结果（$count条）';
  }

  @override
  String get searchInputRequired => '请输入关键词或标签';

  @override
  String searchError(String error) {
    return '发生错误：$error';
  }

  @override
  String get statsTitle => '📊 统计';

  @override
  String get recordStats => '记录统计';

  @override
  String get totalDiaries => '总日记数';

  @override
  String get consecutiveRecords => '连续记录';

  @override
  String get averageLength => '平均字数';

  @override
  String get recordRate => '记录率';

  @override
  String get recordPeriod => '记录期间';

  @override
  String get firstDiary => '第一篇日记';

  @override
  String get latestDiary => '最新日记';

  @override
  String get periodLabel => '记录期间';

  @override
  String get moodRecord => '心情记录';

  @override
  String get moodUnset => '未设置';

  @override
  String get noDiariesYet => '还没有日记';

  @override
  String get statsWillAppear => '开始写日记后将显示统计信息';

  @override
  String statsLoadError(String error) {
    return '加载统计失败：$error';
  }

  @override
  String get settingsTitle => '⚙️ 设置';

  @override
  String get displaySettings => '显示设置';

  @override
  String get theme => '主题';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeLightDesc => '始终使用浅色主题';

  @override
  String get themeDark => '深色模式';

  @override
  String get themeDarkDesc => '始终使用深色主题';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeSystemDesc => '跟随设备设置';

  @override
  String get dataManagement => '数据管理';

  @override
  String get dataExport => '导出数据';

  @override
  String get dataExportDesc => '将日记保存到文件（设备迁移或卸载前）';

  @override
  String get dataImport => '导入数据';

  @override
  String get dataImportDesc => '从保存的文件恢复日记';

  @override
  String get deleteAllData => '删除所有数据';

  @override
  String get deleteAllDataDesc => '删除所有日记（无法撤销）';

  @override
  String get deviceMigration => '备份与迁移指南';

  @override
  String get dataLossWarning => '⚠ 卸载应用将删除所有数据。请提前导出您的数据。';

  @override
  String get migrationStep1 => '在旧设备上导出数据';

  @override
  String get migrationStep1Desc => '文件将被下载';

  @override
  String get migrationStep2 => '将文件传输到新设备';

  @override
  String get migrationStep2Desc => '通过电子邮件、云存储等';

  @override
  String get migrationStep3 => '在新设备上导入数据';

  @override
  String get migrationStep3Desc => '选择文件完成恢复';

  @override
  String get appInfo => '应用信息';

  @override
  String get version => '版本';

  @override
  String get appName => '应用名称';

  @override
  String get noExportData => '没有可导出的日记';

  @override
  String exportError(String error) {
    return '导出失败：$error';
  }

  @override
  String get importDialogTitle => '导入数据';

  @override
  String importError(String error) {
    return '导入失败：$error';
  }

  @override
  String get fileReadError => '读取文件失败';

  @override
  String get noValidData => '未找到有效数据';

  @override
  String get cancel => '取消';

  @override
  String get import => '导入';

  @override
  String get deleteConfirmTitle => '删除所有数据';

  @override
  String get deleteConfirmMessage => '所有日记将被删除。此操作无法撤销。\n\n确定要删除吗？';

  @override
  String get delete => '删除';

  @override
  String get deleteSuccess => '所有数据已删除';

  @override
  String deleteError(String error) {
    return '删除失败：$error';
  }

  @override
  String get themeSelectTitle => '选择主题';

  @override
  String get selectYear => '选择年份';

  @override
  String thisMonthDiaries(int count) {
    return '本月（$count篇）';
  }

  @override
  String calendarError(String error) {
    return '发生错误\n$error';
  }

  @override
  String get pastTodayNote => '继续写日记，查看过去的回忆';

  @override
  String get edit => '编辑';

  @override
  String get randomNoDiary => '还没有日记';

  @override
  String randomError(String error) {
    return '发生错误：$error';
  }

  @override
  String get randomTryAgain => '再试一次';

  @override
  String get backToHome => '返回首页';

  @override
  String get startWritingDiary => '开始写日记吧';

  @override
  String get saveSaved => '✅ 已保存！';

  @override
  String saveError(String error) {
    return '❌ 发生错误：$error';
  }

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String pastTodayTitle(String monthDay) {
    return '过去的今天（$monthDay）';
  }

  @override
  String pastTodayNoPastEntries(String monthDay) {
    return '$monthDay还没有过去的日记';
  }

  @override
  String get pastTodayKeepWriting => '继续写日记，留下回忆';

  @override
  String get searchEnterKeywordOrTag => '请输入关键词或标签';

  @override
  String get searchDiaryContent => '搜索日记内容';

  @override
  String get count => '条';

  @override
  String get searchByKeywordOrTag => '按关键词或标签搜索';

  @override
  String get searchNoResults => '未找到相关日记';

  @override
  String get searchTryDifferentKeyword => '请尝试其他关键词';

  @override
  String get statsRecordStats => '记录统计';

  @override
  String get statsTotalEntries => '总日记数';

  @override
  String get statsCurrentStreak => '连续记录天数';

  @override
  String get days => '天';

  @override
  String get statsAvgChars => '平均字数';

  @override
  String get chars => '字';

  @override
  String get statsWriteRate => '记录率';

  @override
  String get statsPeriod => '记录期间';

  @override
  String get statsRecordingDays => '记录天数';

  @override
  String get statsFirstEntry => '第一篇日记';

  @override
  String get statsLatestEntry => '最新日记';

  @override
  String get daysCount => '天';

  @override
  String get statsMoodRecord => '心情记录';

  @override
  String get notSet => '未设置';

  @override
  String get times => '次';

  @override
  String thisMonthEntries(int count) {
    return '本月日记（$count条）';
  }

  @override
  String exportSuccess(int count) {
    return '已导出$count条日记';
  }

  @override
  String importConfirmMessage(int count) {
    return '将导入$count条日记。\n\n是否继续？';
  }

  @override
  String importConflictMessage(int total, int newCount, int duplicateCount) {
    return '文件包含: $total条（新增: $newCount条，重复: $duplicateCount条）\n\n如何处理重复的日记？';
  }

  @override
  String get importSkipExisting => '保留现有';

  @override
  String get importOverwrite => '覆盖';

  @override
  String importSuccess(int count) {
    return '已导入$count条日记';
  }

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get urlOpenError => '无法打开URL';

  @override
  String get goToToday => '返回今天';

  @override
  String get reminderSection => '提醒';

  @override
  String get reminderDaily => '每日提醒';

  @override
  String get reminderDailyDesc => '每天在固定时间通知您';

  @override
  String get reminderTime => '通知时间';

  @override
  String get reminderNotificationTitle => '今天的日记';

  @override
  String get reminderNotificationBody => '记录一下今天发生的事吧';

  @override
  String get reminderPermissionDenied => '通知未被允许。请在系统设置中开启通知';

  @override
  String get securitySection => '安全';

  @override
  String get appLock => '应用锁';

  @override
  String get appLockDesc => '启动时使用生物识别或屏幕锁保护';

  @override
  String get appLockUnavailable => '此设备未设置生物识别或屏幕锁';

  @override
  String get appLockUnlock => '解锁';

  @override
  String get appLockReason => '请验证身份以查看日记';

  @override
  String lastBackup(String date) {
    return '上次备份：$date';
  }

  @override
  String get lastBackupNever => '尚未备份';

  @override
  String get backupReminderTitle => '建议备份';

  @override
  String get backupReminderMessage => '距离上次备份已超过30天。请导出日记以保护数据';

  @override
  String get backupNow => '立即备份';

  @override
  String get later => '稍后';

  @override
  String get statsEmotionTitle => '心情变化';

  @override
  String get statsEmotionSubtitle => '根据日记内容在设备上自动分析（不发送数据）';

  @override
  String get statsTopWordsTitle => '本月常用词';

  @override
  String get emotionPositive => '积极';

  @override
  String get emotionNegative => '消极';

  @override
  String get yearReview => '年度回顾';

  @override
  String get yearReviewEntries => '写下的日记';

  @override
  String get yearReviewChars => '写下的字数';

  @override
  String get yearReviewMaxStreak => '最长连续记录';

  @override
  String get yearReviewTopWords => '今年常用词';

  @override
  String get yearReviewMonthlyMood => '每月心情';

  @override
  String get yearReviewShare => '分享为图片';

  @override
  String get yearReviewNoData => '还没有日记';

  @override
  String get statsMeaningTitle => '意义梳理词汇';

  @override
  String get statsMeaningSubtitle => '每100字中领悟与因果类词语的密度';

  @override
  String get programs => '书写计划';

  @override
  String get pennebakerTitle => '表达性书写（4天课程）';

  @override
  String get pennebakerDesc => '针对萦绕心头的事，不加修饰地连续书写15分钟，同一主题坚持4天';

  @override
  String get pennebakerCitation => '源自 Pennebaker & Beall (1986) 及其后200多项研究';

  @override
  String get tgtTitle => '三件好事';

  @override
  String get tgtDesc => '写下今天发生的三件好事及其原因';

  @override
  String get tgtCitation => '基于 Seligman 等 (2005) 的积极心理学研究';

  @override
  String get programDisclaimer => '这些功能帮助你实践研究中报告过效果的书写方法，不构成治疗，也不保证效果';

  @override
  String get startWriting => '开始书写';

  @override
  String get continueWriting => '继续';

  @override
  String get newCourse => '开始新主题';

  @override
  String get themeLabel => '这4天要面对的主题';

  @override
  String get themeHint => '例如：工作上的挫折、人际关系的烦恼';

  @override
  String get timerKeepWriting => '不要停笔，想到什么写什么';

  @override
  String get timerDone => '15分钟到了，写完这段就可以结束';

  @override
  String get finishEarlyTitle => '提前结束？';

  @override
  String get finishEarlyMessage => '研究建议持续书写满15分钟';

  @override
  String get finishSession => '结束并保存';

  @override
  String get sessionSaved => '已保存（与日记正文分开存放）';

  @override
  String get goodThingLabel => '好事';

  @override
  String get whyLabel => '为什么？（可选）';

  @override
  String get tgtDoneToday => '今天已完成 ✅';

  @override
  String get sessionHistory => '历史记录';

  @override
  String get tgtValidation => '至少写一条';

  @override
  String get pennebakerCompleted => '4天课程完成！';

  @override
  String get ok => '确定';

  @override
  String get themeValidation => '请输入主题';

  @override
  String homeStreakDays(int count) {
    return '已连续$count天！';
  }

  @override
  String get homePromptLabel => '今日话题';

  @override
  String get homePromptSkip => '不用也可以';

  @override
  String get writeTodayButton => '写今天';

  @override
  String get reviewTitle => '回顾';

  @override
  String get stampsMenu => '贴纸';

  @override
  String homeCollectedStamps(int count) {
    return '已收集$count枚贴纸';
  }

  @override
  String get moodGood => '不错';

  @override
  String get moodMeh => '一般';

  @override
  String writePromptHint(String prompt) {
    return '话题：$prompt — 不用也可以';
  }

  @override
  String get celebrateTitle => '写好啦！';

  @override
  String celebrateStreak(int count) {
    return '连续$count天！🔥';
  }

  @override
  String celebrateStampGet(String name) {
    return '获得「$name」贴纸！';
  }

  @override
  String get stampsTitle => '收集贴纸';

  @override
  String stampsCount(int count) {
    return '已收集$count枚';
  }

  @override
  String get stampLockedHint => '还是个秘密';

  @override
  String get onboardSkip => '跳过';

  @override
  String get onboardNext => '下一步';

  @override
  String get onboardStart => '开始！';

  @override
  String get onboard1Title => '欢迎！';

  @override
  String get onboard1Body => '轻松几笔就能写的日记';

  @override
  String get onboard2Title => '点一下心情，随手就写';

  @override
  String get onboard2Body => '还有话题，不用也可以';

  @override
  String get onboard3Title => '坚持写就能集贴纸🎈';

  @override
  String get onboard3Body => '按自己的节奏慢慢来';

  @override
  String get howToUse => '再看一次使用说明';

  @override
  String get statsMoodShare => '心情占比';

  @override
  String get statsTopTags => '常用标签';

  @override
  String get promptQuestion1 => '今天最好笑的事是？😆';

  @override
  String get promptQuestion2 => '今天吃到最好吃的是？🍰';

  @override
  String get promptQuestion3 => '现在最想为谁加油？📣';

  @override
  String get promptQuestion4 => '今天遇到谁让你开心？🙌';

  @override
  String get promptQuestion5 => '最近迷上了什么？🎮';

  @override
  String get promptQuestion6 => '今天有什么小幸运？🍀';

  @override
  String get promptQuestion7 => '明天有点期待的事是？✨';

  @override
  String get promptQuestion8 => '用一句话形容今天？💬';

  @override
  String get stampNameFirst => '第一步';

  @override
  String get stampNameCount10 => '写满10篇';

  @override
  String get stampNameCount30 => '写满30篇';

  @override
  String get stampNameCount50 => '写满50篇';

  @override
  String get stampNameCount100 => '写满100篇';

  @override
  String get stampNameStreak3 => '连续3天';

  @override
  String get stampNameStreak7 => '连续一周';

  @override
  String get stampNameStreak14 => '连续两周';

  @override
  String get stampNameStreak30 => '连续一个月';

  @override
  String get statsThisMonth => '本月';
}
