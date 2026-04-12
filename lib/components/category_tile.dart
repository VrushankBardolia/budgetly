import 'package:budgetly/core/import_to_export.dart';

class CategoryTile extends StatelessWidget {
  final String emoji;
  final String name;
  final bool showProgress;
  final double? percentage;
  final String formattedAmount;
  final int transactionCount;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const CategoryTile({
    super.key,
    required this.emoji,
    required this.name,
    this.showProgress = false,
    this.percentage,
    required this.formattedAmount,
    this.transactionCount = 0,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: regularText(24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: showProgress
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: semiBoldText(16)),
                            Spacer(),
                            Text(
                              "$transactionCount • ",
                              style: boldText(16, color: AppColors.grey),
                            ),
                            Text(formattedAmount, style: boldText(16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage ?? 0.0,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(name, style: semiBoldText(18)),
                            Text(
                              '$transactionCount transactions',
                              style: regularText(12, color: AppColors.grey),
                            ),
                          ],
                        ),
                        Text(formattedAmount, style: boldText(16)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
