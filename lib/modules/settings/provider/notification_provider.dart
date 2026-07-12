import 'package:budgetly/core/import_to_export.dart';

enum NotificationPermissionState { denied, granted }

// ─── Local UI State Providers ────────────────────────────────────────────────

final notificationPermissionStateProvider = StateProvider<NotificationPermissionState>((ref) {
  return NotificationPermissionState.denied;
});

final notificationsEnabledProvider = StateProvider<bool>((ref) {
  return PreferenceHelper.isNotificationEnabled;
});

final dailyReminderEnabledProvider = StateProvider<bool>((ref) {
  return PreferenceHelper.isDailyReminderEnabled;
});

final notificationLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

// ─── Notification Action Controller ──────────────────────────────────────────

final notificationControllerProvider = Provider<NotificationController>((ref) {
  return NotificationController(ref);
});

class NotificationController {
  final Ref ref;
  NotificationController(this.ref);

  Future<void> checkPermissionState() async {
    ref.read(notificationLoadingProvider.notifier).state = true;
    try {
      final status = await Permission.notification.status;

      if (status.isGranted) {
        ref.read(notificationPermissionStateProvider.notifier).state = NotificationPermissionState.granted;
        final enabled = PreferenceHelper.isNotificationEnabled;
        final reminder = PreferenceHelper.isDailyReminderEnabled;

        ref.read(notificationsEnabledProvider.notifier).state = enabled;
        ref.read(dailyReminderEnabledProvider.notifier).state = reminder;

        if (enabled && reminder) {
          await NotificationService.scheduleDailyReminder();
        }
      } else {
        ref.read(notificationPermissionStateProvider.notifier).state = NotificationPermissionState.denied;
      }
    } finally {
      ref.read(notificationLoadingProvider.notifier).state = false;
    }
  }

  Future<void> requestPermission() async {
    final granted = await NotificationService.enable();

    if (granted) {
      ref.read(notificationPermissionStateProvider.notifier).state = NotificationPermissionState.granted;
      ref.read(notificationsEnabledProvider.notifier).state = true;
      ref.read(dailyReminderEnabledProvider.notifier).state = true;
      PreferenceHelper.isNotificationEnabled = true;
      PreferenceHelper.isDailyReminderEnabled = true;
    } else {
      ref.read(notificationPermissionStateProvider.notifier).state = NotificationPermissionState.denied;
    }
  }

  Future<void> toggleNotifications() async {
    HapticFeedback.lightImpact();
    final enabled = ref.read(notificationsEnabledProvider);

    try {
      if (enabled) {
        await NotificationService.disable();
        ref.read(notificationsEnabledProvider.notifier).state = false;
        ref.read(dailyReminderEnabledProvider.notifier).state = false;
        PreferenceHelper.isNotificationEnabled = false;
        PreferenceHelper.isDailyReminderEnabled = false;
      } else {
        ref.read(notificationsEnabledProvider.notifier).state = true;
        ref.read(dailyReminderEnabledProvider.notifier).state = true;
        await NotificationService.scheduleDailyReminder();
        PreferenceHelper.isNotificationEnabled = true;
        PreferenceHelper.isDailyReminderEnabled = true;
      }
    } catch (e) {
      errorSnackbar('Could not update notification settings. Please try again.');
    }
  }

  Future<void> toggleDailyReminder() async {
    HapticFeedback.lightImpact();
    final dailyEnabled = ref.read(dailyReminderEnabledProvider);

    try {
      if (dailyEnabled) {
        await NotificationService.cancelDailyReminder();
        ref.read(dailyReminderEnabledProvider.notifier).state = false;
        PreferenceHelper.isDailyReminderEnabled = false;
      } else {
        await NotificationService.scheduleDailyReminder();
        ref.read(dailyReminderEnabledProvider.notifier).state = true;
        PreferenceHelper.isDailyReminderEnabled = true;
      }
    } catch (e) {
      errorSnackbar('Could not update reminder settings. Please try again.');
    }
  }
}
