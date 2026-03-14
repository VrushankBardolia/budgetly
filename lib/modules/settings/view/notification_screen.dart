import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), centerTitle: true, elevation: 0),
      body: Column(
        children: [
          _buildNotificationToggle(),
          const Center(child: Text("Notifications")),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          // onTap: controller.toggleNotifications,
          splashColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
          ),
          title: const Text(
            "Notifications",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: CupertinoSwitch(value: controller.notificationsEnabled.value, onChanged: (value) => controller.toggleNotifications(), activeTrackColor: AppColors.brand),
        ),
      ),
    );
  }
}
