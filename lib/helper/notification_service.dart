import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../screens/months/monthDetailsScreen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Initialize Local Notifications for Foreground Presentation
    const androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const settings = InitializationSettings(android: androidInit);

    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle local notification tap (Foreground/Background via Local Plugin)
        navigateToCurrentMonth();
      },
    );

    // Request permission for Android 13+ (Local Notifications)
    await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    // Initialize FCM
    await setupFCM();
  }

  static Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission (FCM)
    NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await messaging.getToken();

    print("TOKEN $token");

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Background Message Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground Message Handler
    // FCM doesn't show a visible notification by default on Android while foregrounded.
    // We use flutter_local_notifications to show it.
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
              "daily_expense_channel_v2",
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

    // App Opened from Background (Background implementation of FCM)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification Clicked (Background State)");
      navigateToCurrentMonth();
    });

    // App Opened from Terminated State
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
