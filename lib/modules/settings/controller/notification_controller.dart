import 'package:budgetly/core/import_to_export.dart';

enum NotificationPermissionState {
  denied, // user denied
  granted, // user allowed
}

class NotificationController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  final Rx<NotificationPermissionState> permissionState =
      NotificationPermissionState.denied.obs;
  final RxBool notificationsEnabled = false.obs;
  final RxBool dailyReminderEnabled = true.obs;
  final RxBool isLoading = false.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading.value = true;
      await _checkPermissionState();
      isLoading.value = false;
    });
  }

  // ─── Permission Check ─────────────────────────────────────────────────────

  Future<void> _checkPermissionState() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      permissionState.value = NotificationPermissionState.granted;
      // Restore saved preferences
      notificationsEnabled.value = PreferenceHelper.isNotificationEnabled;
      dailyReminderEnabled.value = PreferenceHelper.isDailyReminderEnabled;
      // Re-schedule if daily reminder was on
      if (notificationsEnabled.value && dailyReminderEnabled.value) {
        await NotificationService.scheduleDailyReminder();
      }
    } else {
      permissionState.value = NotificationPermissionState.denied;
      requestPermission();
    }
  }

  // ─── Request Permission ───────────────────────────────────────────────────

  Future<void> requestPermission() async {
    // isLoading.value = true;

    final granted = await NotificationService.enable();

    if (granted) {
      permissionState.value = NotificationPermissionState.granted;
      notificationsEnabled.value = true;
      dailyReminderEnabled.value = true;
      PreferenceHelper.isNotificationEnabled = true;
      PreferenceHelper.isDailyReminderEnabled = true;
    } else {
      permissionState.value = NotificationPermissionState.denied;
    }

    // isLoading.value = false;
  }

  // ─── Main Notification Toggle ─────────────────────────────────────────────

  Future<void> toggleNotifications() async {
    HapticFeedback.lightImpact();

    try {
      if (notificationsEnabled.value) {
        // Disabling notifications also cancels daily reminder
        await NotificationService.disable();
        notificationsEnabled.value = false;
        dailyReminderEnabled.value = false;
        PreferenceHelper.isNotificationEnabled = false;
        PreferenceHelper.isDailyReminderEnabled = false;
      } else {
        notificationsEnabled.value = true;
        // Re-enable daily reminder by default when notifications are turned back on
        dailyReminderEnabled.value = true;
        await NotificationService.scheduleDailyReminder();
        PreferenceHelper.isNotificationEnabled = true;
        PreferenceHelper.isDailyReminderEnabled = true;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update notification settings. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── Daily Reminder Toggle ────────────────────────────────────────────────

  Future<void> toggleDailyReminder() async {
    HapticFeedback.lightImpact();

    try {
      if (dailyReminderEnabled.value) {
        await NotificationService.cancelDailyReminder();
        dailyReminderEnabled.value = false;
        PreferenceHelper.isDailyReminderEnabled = false;
      } else {
        await NotificationService.scheduleDailyReminder();
        dailyReminderEnabled.value = true;
        PreferenceHelper.isDailyReminderEnabled = true;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not update reminder settings. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
