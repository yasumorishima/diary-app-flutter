import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// デイリーリマインダー通知サービス
///
/// 毎日決まった時刻に「日記を書きましょう」のローカル通知を出す。
/// スケジュールは端末に永続化され、再起動後は
/// ScheduledNotificationBootReceiver（AndroidManifest）が復元する。
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  static const int _dailyReminderId = 0;

  // SharedPreferences キー
  static const String prefEnabled = 'reminder_enabled';
  static const String prefHour = 'reminder_hour';
  static const String prefMinute = 'reminder_minute';

  // デフォルトの通知時刻（20:00）
  static const int defaultHour = 20;
  static const int defaultMinute = 0;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 初期化（タイムゾーン設定 + プラグイン初期化）
  Future<void> init() async {
    if (kIsWeb || _initialized) return;
    tz_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      // 5.0 から TimezoneInfo を返す（identifier が IANA の名前）
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (_) {
      // タイムゾーン取得失敗時はデフォルトのまま（通知時刻がずれる可能性のみ）
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// 通知権限をリクエスト（Android 13+ / iOS）。許可済みなら即 true
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? true;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted =
          await ios.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? true;
    }
    return true;
  }

  /// 毎日のリマインダーを予約（既存の予約は同 ID で上書き）
  Future<void> scheduleDaily({
    required TimeOfDay time,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    await init();
    await _plugin.zonedSchedule(
      _dailyReminderId,
      title,
      body,
      _nextInstanceOf(time),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminder',
          channelDescription: 'Daily diary reminder notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 正確なアラーム権限（SCHEDULE_EXACT_ALARM）を要求しない inexact モード。
      // 日記リマインダーは数分の揺れが許容されるため
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// リマインダーを解除
  Future<void> cancelDaily() async {
    if (kIsWeb) return;
    await init();
    await _plugin.cancel(_dailyReminderId);
  }

  /// 保存済み設定で再予約（アプリ起動時に呼び、言語変更を通知文言に反映する）
  Future<void> rescheduleFromPrefs({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(prefEnabled) != true) return;
    final hour = prefs.getInt(prefHour) ?? defaultHour;
    final minute = prefs.getInt(prefMinute) ?? defaultMinute;
    await scheduleDaily(
      time: TimeOfDay(hour: hour, minute: minute),
      title: title,
      body: body,
    );
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
