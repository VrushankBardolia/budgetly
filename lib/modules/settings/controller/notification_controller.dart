import 'package:budgetly/core/import_to_export.dart';

class NotificationController extends GetxController {
  final RxBool notificationsEnabled = false.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadNotificationPreference();
  }

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> _loadNotificationPreference() async {
    final enabled = PreferenceHelper.isNotificationEnabled;
    notificationsEnabled.value = enabled;

    // Re-schedule on every app launch in case the OS cleared it
    // (Android clears all alarms on device restart)
    if (enabled) await NotificationService.scheduleDailyReminder();
  }

  // ─── Toggle ───────────────────────────────────────────────────────────────

  Future<void> toggleNotifications() async {
    HapticFeedback.lightImpact();

    try {
      if (notificationsEnabled.value) {
        await NotificationService.disable();
        notificationsEnabled.value = false;
      } else {
        final granted = await NotificationService.enable();
        if (granted) {
          notificationsEnabled.value = true;
        } else {
          Get.snackbar('Permission Denied', 'Please enable notifications from your device settings.', snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not update notification settings. Please try again.', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
