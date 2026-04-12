import 'dart:developer';

import 'package:budgetly/core/import_to_export.dart';
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

  static const int _dailyReminderId = 1001;
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
    _listenBackgroundTap();
    await _captureTerminatedTap();
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      // ✅ FIX 1 — local notification tap (foreground + background)
      // Use addPostFrameCallback so the navigator is guaranteed to be ready.
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigateToCurrentMonth();
        });
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _dailyReminderChannelId,
            _dailyReminderChannelName,
            description: _dailyReminderChannelDesc,
            importance: Importance.max,
            showBadge: true,
          ),
        );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
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
    FirebaseMessaging.onMessage.listen(showLocalNotification);
  }

  // ✅ FIX 2 — FCM notification tap when app is in background (not killed)
  // Same addPostFrameCallback trick — the app is resuming, navigator may
  // not have processed the route stack yet.
  static void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToCurrentMonth();
      });
    });
  }

  // ✅ FIX 3 — app opened from terminated state via notification
  // Don't navigate here — save the message and let the home screen
  // call consumeInitialNotification() once the widget tree is built.
  static Future<void> _captureTerminatedTap() async {
    _initialMessage = await _messaging.getInitialMessage();
  }

  // ─── Called from HomeScreen.initState / onInit after first frame ──────────
  // This is the correct place to handle the terminated-state tap because
  // the navigator and route stack are fully ready by then.
  static void consumeInitialNotification() {
    if (_initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToCurrentMonth();
        _initialMessage = null;
      });
    }
  }

  // ─── Enable / Disable ─────────────────────────────────────────────────────

  static Future<bool> enable() async {
    final status = await _messaging.requestPermission(alert: true, badge: true, sound: true);
    if (status.authorizationStatus == AuthorizationStatus.denied) return false;

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    if (granted == false) return false;

    final token = await _messaging.getToken();
    if (token == null) return false;
    log('FCM Token: $token');
    PreferenceHelper.fcmToken = token;
    _messaging.onTokenRefresh.listen((token) => PreferenceHelper.fcmToken = token);

    await scheduleDailyReminder();
    PreferenceHelper.isNotificationEnabled = true;

    return true;
  }

  static Future<void> disable() async {
    await cancelDailyReminder();
    PreferenceHelper.isNotificationEnabled = false;
  }

  // ─── Scheduling ───────────────────────────────────────────────────────────

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
      matchDateTimeComponents: DateTimeComponents.time,
    );

    log('Daily reminder scheduled at $_reminderHour:$_reminderMinute');
  }

  static Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_dailyReminderId);
    log('Daily reminder cancelled');
  }

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ─── Show local notification ──────────────────────────────────────────────

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
          priority: Priority.max,
          category: AndroidNotificationCategory.reminder,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  static void navigateToCurrentMonth() {
    final now = DateTime.now();

    if (Get.context == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigateToCurrentMonth();
      });
      return;
    }

    Get.toNamed(Routes.MONTH_DETAILS, arguments: {'year': now.year, 'month': now.month});
  }
}
