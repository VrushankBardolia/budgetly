import 'package:budgetly/core/import_to_export.dart';

class CategoryTile extends StatelessWidget {
  final String emoji;
  final String name;
  final bool showProgress;
  final double? percentage;
  final String formattedAmount;
  final int transactionCount;
  final VoidCallback? onTap;

  const CategoryTile({
    super.key,
    required this.emoji,
    required this.name,
    this.showProgress = false,
    this.percentage,
    required this.formattedAmount,
    this.transactionCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            alignment: Alignment.center,
            child: Text(emoji, style: regularText(20)),
          ),
          const SizedBox(width: 8),
          Expanded(child: showProgress ? buildProgressView() : buildDefaultView()),
        ],
      ),
    );
  }

  Widget buildProgressView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(name, style: semiBoldText(16)),
            Spacer(),
            Text("$transactionCount • ", style: mediumText(14, color: AppColors.grey)),
            Text(formattedAmount, style: boldText(16)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage ?? 0.0,
            backgroundColor: AppColors.brand.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brand),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget buildDefaultView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: semiBoldText(16)),
            Text('$transactionCount transactions', style: regularText(12, color: AppColors.grey)),
          ],
        ),
        Text(formattedAmount, style: boldText(16)),
      ],
    );
  }
}
