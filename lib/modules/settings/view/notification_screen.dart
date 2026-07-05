import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text('Notifications'),
        centerTitle: true,
        elevation: 0,
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : switch (prov.permissionState) {
              NotificationPermissionState.denied => _DeniedView(),
              NotificationPermissionState.granted => _GrantedView(),
            },
    );
  }
}

// ─── State 2: Denied ──────────────────────────────────────────────────────────

class _DeniedView extends ConsumerWidget {
  const _DeniedView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(notificationProvider);
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
            style: regularText(15, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: prov.requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brand,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Allow Notifications', style: semiBoldText(16)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: appRouter.pop,
            child: Text('Go back', style: regularText(14, color: Colors.grey.shade400)),
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
    final prov = ref.watch(notificationProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Main toggle ───────────────────────────────────────────────
        MainNotificationTile(
          icon: Icons.notifications_rounded,
          iconColor: AppColors.brand,
          title: 'Notifications',
          subtitle: 'Enable or disable all notifications',
          value: prov.notificationsEnabled,
          onChanged: (_) => prov.toggleNotifications(),
        ),

        // ── Daily reminder (only shown when notifications are on) ──────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, child: child),
          ),
          child: prov.notificationsEnabled
              ? Padding(
                  key: const ValueKey('daily'),
                  padding: const EdgeInsets.only(top: 12),
                  child: _NotificationTile(
                    icon: Icons.alarm_rounded,
                    iconColor: AppColors.success,
                    title: 'Daily Reminder',
                    subtitle: 'Reminds you to log expenses at around 11:30 PM every day',
                    value: prov.dailyReminderEnabled,
                    onChanged: (_) => prov.toggleDailyReminder(),
                    showChevron: true,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
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
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? iconColor.withValues(alpha: 0.15) : AppColors.surfaceLight,
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
                Text(subtitle, style: regularText(12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Trailing
          Transform.scale(
            scale: 0.9,
            alignment: Alignment.centerRight,
            child: CupertinoSwitch(value: value, onChanged: onChanged, activeTrackColor: iconColor),
          ),
        ],
      ),
    );
  }
}
