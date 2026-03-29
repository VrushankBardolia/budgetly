import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return switch (controller.permissionState.value) {
          NotificationPermissionState.denied => const _DeniedView(),
          NotificationPermissionState.granted => const _GrantedView(),
        };
      }),
    );
  }
}

// ─── State 2: Denied ──────────────────────────────────────────────────────────

class _DeniedView extends GetView<NotificationController> {
  const _DeniedView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Notifications Blocked',
            textAlign: TextAlign.center,
            style: boldText(26),
          ),
          const SizedBox(height: 16),
          Text(
            'You\'ve turned off notifications for Budgetly. To receive daily expense reminders, please allow notifications.',
            textAlign: TextAlign.center,
            style: regularText(15, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Allow Notifications', style: semiBoldText(16)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Go back',
              style: regularText(14, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── State 3: Granted ─────────────────────────────────────────────────────────

class _GrantedView extends GetView<NotificationController> {
  const _GrantedView();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Main toggle ───────────────────────────────────────────────
          MainNotificationTile(
            icon: Icons.notifications_rounded,
            iconColor: AppColors.brand,
            title: 'Notifications',
            subtitle: 'Enable or disable all notifications',
            value: controller.notificationsEnabled.value,
            onChanged: (_) => controller.toggleNotifications(),
          ),

          // ── Daily reminder (only shown when notifications are on) ──────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(sizeFactor: animation, child: child),
            ),
            child: controller.notificationsEnabled.value
                ? Padding(
                    key: const ValueKey('daily'),
                    padding: const EdgeInsets.only(top: 12),
                    child: _NotificationTile(
                      icon: Icons.alarm_rounded,
                      iconColor: AppColors.success,
                      title: 'Daily Reminder',
                      subtitle:
                          'Reminds you to log expenses at around 11:30 PM every day',
                      value: controller.dailyReminderEnabled.value,
                      onChanged: (_) => controller.toggleDailyReminder(),
                      showChevron: true,
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Tile Widget ───────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showChevron;

  const _NotificationTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? iconColor.withValues(alpha: 0.15)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: value ? iconColor : Colors.grey),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: semiBoldText(15)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: regularText(12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Trailing
          Transform.scale(
            scale: 0.9,
            alignment: Alignment.centerRight,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}
