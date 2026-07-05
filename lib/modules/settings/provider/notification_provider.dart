import 'package:budgetly/core/import_to_export.dart';

enum NotificationPermissionState { denied, granted }

class NotificationProvider extends ChangeNotifier {
  final Ref ref;

  // ─── State ───────────────────────────────────────────────────────
  NotificationPermissionState permissionState = NotificationPermissionState.denied;
  bool notificationsEnabled = false;
  bool dailyReminderEnabled = true;
  bool isLoading = false;

  NotificationProvider(this.ref) {
    _init();
  }

  Future<void> _init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading = true;
      notifyListeners();
      await _checkPermissionState();
      isLoading = false;
      notifyListeners();
    });
  }

  // ─── Permission Check ─────────────────────────────────────────────────────

  Future<void> _checkPermissionState() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      permissionState = NotificationPermissionState.granted;
      notificationsEnabled = PreferenceHelper.isNotificationEnabled;
      dailyReminderEnabled = PreferenceHelper.isDailyReminderEnabled;
      if (notificationsEnabled && dailyReminderEnabled) {
        await NotificationService.scheduleDailyReminder();
      }
    } else {
      permissionState = NotificationPermissionState.denied;
      requestPermission();
    }
    notifyListeners();
  }

  // ─── Request Permission ───────────────────────────────────────────────────

  Future<void> requestPermission() async {
    final granted = await NotificationService.enable();

    if (granted) {
      permissionState = NotificationPermissionState.granted;
      notificationsEnabled = true;
      dailyReminderEnabled = true;
      PreferenceHelper.isNotificationEnabled = true;
      PreferenceHelper.isDailyReminderEnabled = true;
    } else {
      permissionState = NotificationPermissionState.denied;
    }
    notifyListeners();
  }

  // ─── Main Notification Toggle ─────────────────────────────────────────────

  Future<void> toggleNotifications() async {
    HapticFeedback.lightImpact();

    try {
      if (notificationsEnabled) {
        // Disabling notifications also cancels daily reminder
        await NotificationService.disable();
        notificationsEnabled = false;
        dailyReminderEnabled = false;
        PreferenceHelper.isNotificationEnabled = false;
        PreferenceHelper.isDailyReminderEnabled = false;
      } else {
        notificationsEnabled = true;
        // Re-enable daily reminder by default when notifications are turned back on
        dailyReminderEnabled = true;
        await NotificationService.scheduleDailyReminder();
        PreferenceHelper.isNotificationEnabled = true;
        PreferenceHelper.isDailyReminderEnabled = true;
      }
    } catch (e) {
      errorSnackbar('Could not update notification settings. Please try again.');
    }
    notifyListeners();
  }

  // ─── Daily Reminder Toggle ────────────────────────────────────────────────

  Future<void> toggleDailyReminder() async {
    HapticFeedback.lightImpact();

    try {
      if (dailyReminderEnabled) {
        await NotificationService.cancelDailyReminder();
        dailyReminderEnabled = false;
        PreferenceHelper.isDailyReminderEnabled = false;
      } else {
        await NotificationService.scheduleDailyReminder();
        dailyReminderEnabled = true;
        PreferenceHelper.isDailyReminderEnabled = true;
      }
    } catch (e) {
      errorSnackbar('Could not update reminder settings. Please try again.');
    }
    notifyListeners();
  }
}
