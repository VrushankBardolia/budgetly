import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class MainNotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showChevron;

  const MainNotificationTile({
    super.key,
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
        border: Border.all(color: value ? iconColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: value ? iconColor.withValues(alpha: 0.15) : AppColors.surfaceLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: value ? iconColor : Colors.grey),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(color: Colors.grey[500], fontSize: 12, height: 1.4)),
              ],
            ),
          ),

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
