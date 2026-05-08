import 'package:budgetly/core/import_to_export.dart';

class DatePickerField extends StatelessWidget {
  final String formattedDate;
  final VoidCallback onTap;

  const DatePickerField({
    super.key,
    required this.formattedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: 12,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar04,
              size: 20,
              color: Colors.grey[400]!,
            ),
            Text(formattedDate, style: regularText(15)),
          ],
        ),
      ),
    );
  }
}
