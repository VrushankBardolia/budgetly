import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../core/globals.dart';
import '../screens/months/monthDetailsScreen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
  static final globals = Get.put(Globals());

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        navigateToCurrentMonth();
      },
    );
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    await setupFCM();
  }

  static Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();
    globals.FCMToken.value = token!;

    print("FCM TOKEN ${globals.FCMToken.value}");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        plugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              "daily_expense_channel",
              "Daily Expense Reminder",
              importance: Importance.max,
              priority: Priority.max,
              icon: '@mipmap/ic_launcher',
              channelDescription: "Reminds you to add daily expenses",
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification Clicked (Background State)");
      navigateToCurrentMonth();
    });

    initialNotification = await messaging.getInitialMessage();
    if (initialNotification != null) {
      print("Notification Clicked (Terminated State) - Pending Navigation");
    }
  }

  static RemoteMessage? initialNotification;

  static void consumeInitialNotification() {
    if (initialNotification != null) {
      navigateToCurrentMonth();
      initialNotification = null;
    }
  }

  static void navigateToCurrentMonth() {
    final now = DateTime.now();
    Get.to(() => MonthDetailScreen(year: now.year, month: now.month));
  }
}
