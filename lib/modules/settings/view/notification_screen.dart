import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationControllerProvider).checkPermissionState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(notificationLoadingProvider);
    final permissionState = ref.watch(notificationPermissionStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: serifText(20)),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
          : switch (permissionState) {
              NotificationPermissionState.denied => const _DeniedView(),
              NotificationPermissionState.granted => const _GrantedView(),
            },
    );
  }
}

// ─── State 2: Denied ──────────────────────────────────────────────────────────

class _DeniedView extends ConsumerWidget {
  const _DeniedView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(notificationControllerProvider);
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
            child: const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.error),
          ),
          const SizedBox(height: 32),
          Text('Notifications Blocked', textAlign: TextAlign.center, style: boldText(26)),
          const SizedBox(height: 16),
          Text(
            'You\'ve turned off notifications for Budgetly. To receive daily expense reminders, please allow notifications.',
            textAlign: TextAlign.center,
            style: regularText(15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Allow Notifications', style: semiBoldText(16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: appRouter.pop,
            child: Text('Go back', style: regularText(14, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// ─── State 3: Granted ─────────────────────────────────────────────────────────

class _GrantedView extends ConsumerWidget {
  const _GrantedView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider);
    final dailyEnabled = ref.watch(dailyReminderEnabledProvider);
    final controller = ref.read(notificationControllerProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // ── Main toggle ───────────────────────────────────────────────
        buildNotificationCard(
          icon: Icons.notifications_rounded,
          iconColor: AppColors.brand,
          title: 'Notifications',
          subtitle: 'Enable or disable all notifications',
          value: enabled,
          onChanged: (_) => controller.toggleNotifications(),
          showBorder: true,
        ),

        // ── Daily reminder (only shown when notifications are on) ──────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, child: child),
          ),
          child: enabled
              ? Padding(
                  key: const ValueKey('daily'),
                  padding: const EdgeInsets.only(top: 12),
                  child: buildNotificationCard(
                    icon: Icons.alarm_rounded,
                    iconColor: AppColors.success,
                    title: 'Daily Reminder',
                    subtitle: 'Reminds you to log expenses at around 11:30 PM every day',
                    value: dailyEnabled,
                    onChanged: (_) => controller.toggleDailyReminder(),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }

  Widget buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBorder = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: showBorder ? Border.all(color: AppColors.borderColor) : null,
      ),
      child: Row(
        children: [
          // Icon
          Icon(icon, size: 20, color: value ? iconColor : AppColors.grey),
          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: semiBoldText(16)),
                Text(subtitle, style: regularText(12, color: Colors.grey)),
              ],
            ),
          ),

          // Trailing
          Transform.scale(
            scale: 0.8,
            alignment: Alignment.centerRight,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.brand,
            ),
          ),
        ],
      ),
    );
  }
}
