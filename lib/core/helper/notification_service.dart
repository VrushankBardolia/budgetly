import 'package:budgetly/core/import_to_export.dart';
import 'dart:developer';

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// ─── Background handler (must be top-level) ───────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.showLocalNotification(message);
}

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ─── Channels ─────────────────────────────────────────────────────────────
  static const String _dailyReminderChannelId = 'daily_expense_channel';
  static const String _dailyReminderChannelName = 'Daily Expense Reminder';
  static const String _dailyReminderChannelDesc = 'Reminds you to add daily expenses';

  static const String _monthlyReminderChannelId = 'monthly_expense_channel';
  static const String _monthlyReminderChannelName = 'Monthly Expense Reminder';
  static const String _monthlyReminderChannelDesc = 'Reminds you to add monthly expenses';

  // ─── Scheduled notification ID ────────────────────────────────────────────
  static const int _dailyReminderId = 1001;

  // ─── Reminder time ────────────────────────────────────────────────────────
  static const int _reminderHour = 23;
  static const int _reminderMinute = 30;

  static RemoteMessage? _initialMessage;

  // ─── Init ─────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    await _initLocalNotifications();
    _registerBackgroundHandler();
    _listenForegroundMessages();
    _listenNotificationTaps();
    await _captureInitialMessage();
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false);

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (_) => navigateToCurrentMonth(),
    );

    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(_dailyReminderChannelId, _dailyReminderChannelName, description: _dailyReminderChannelDesc, importance: Importance.max, showBadge: true),
    );

    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(
        _monthlyReminderChannelId,
        _monthlyReminderChannelName,
        description: _monthlyReminderChannelDesc,
        importance: Importance.max,
        showBadge: true,
      ),
    );
  }

  static void _registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(message);
    });
  }

  static void _listenNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((_) => navigateToCurrentMonth());
  }

  static Future<void> _captureInitialMessage() async {
    _initialMessage = await _messaging.getInitialMessage();
  }

  // ─── Called from home screen after UI is ready ────────────────────────────

  static void consumeInitialNotification() {
    if (_initialMessage != null) {
      navigateToCurrentMonth();
      _initialMessage = null;
    }
  }

  // ─── Enable / Disable ─────────────────────────────────────────────────────

  static Future<bool> enable() async {
    // 1. Request FCM permission
    final status = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (status.authorizationStatus == AuthorizationStatus.denied) return false;

    // 2. Android 13+ explicit permission
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    if (granted == false) return false;

    // 3. Save FCM token
    final token = await _messaging.getToken();
    if (token == null) return false;
    log('FCM Token: $token');
    PreferenceHelper.setFCMToken(token);

    // Keep token fresh
    _messaging.onTokenRefresh.listen(PreferenceHelper.setFCMToken);

    // 4. Schedule daily local notification at 11:30 PM
    await scheduleDailyReminder();

    // 5. Persist preference
    PreferenceHelper.setNotificationEnabled(true);

    return true;
  }

  static Future<void> disable() async {
    await cancelDailyReminder();
    PreferenceHelper.setNotificationEnabled(false);
  }

  // ─── Daily Reminder Scheduling ────────────────────────────────────────────

  /// Schedules (or re-schedules) a notification every day at 11:30 PM.
  /// Safe to call on every app launch — it replaces the previous schedule
  /// because the same [_dailyReminderId] is reused.
  static Future<void> scheduleDailyReminder() async {
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'Did you add today\'s expenses?',
      'Add expenses to stay on track!',
      _nextInstanceOf(_reminderHour, _reminderMinute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyReminderChannelId,
          _dailyReminderChannelName,
          channelDescription: _dailyReminderChannelDesc,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.reminder,
          icon: '@mipmap/ic_launcher',
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // ↓ This is what makes it repeat every day at the same time
      matchDateTimeComponents: DateTimeComponents.time,
    );

    log('Daily reminder scheduled at $_reminderHour:$_reminderMinute');
  }

  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
    log('Daily reminder cancelled');
  }

  /// Returns the next 11:30 PM from now in IST.
  /// If the time has already passed today, schedules for tomorrow.
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ─── Show local notification (foreground + background FCM) ───────────────

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dailyReminderChannelId,
          _dailyReminderChannelName,
          channelDescription: _dailyReminderChannelDesc,
          importance: Importance.max,
          category: AndroidNotificationCategory.reminder,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  static void navigateToCurrentMonth() {
    final now = DateTime.now();
    Get.toNamed(Routes.MONTH_DETAILS, arguments: {'year': now.year, 'month': now.month});
  }
}
