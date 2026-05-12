import 'package:intl/intl.dart';
import 'package:budgetly/core/import_to_export.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final Category category;

  const ExpenseTile({super.key, required this.expense, required this.category});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormatter = DateFormat('MMM dd');

    final hasDetail = expense.detail.isNotEmpty;
    final title = hasDetail ? expense.detail : category.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
        gradient: RadialGradient(
          center: Alignment.centerLeft,
          radius: 3,
          colors: [AppColors.brand.withValues(alpha: 0.1), AppColors.black.withValues(alpha: 0)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(category.emoji, style: regularText(24)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: boldText(16)),
                Row(
                  children: [
                    Text(
                      dateFormatter.format(expense.date),
                      style: boldText(14, color: AppColors.grey),
                    ),
                    if (hasDetail) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.circle, size: 4, color: AppColors.grey),
                      ),
                      Flexible(
                        child: Text(
                          category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: regularText(14, color: AppColors.grey),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(formatter.format(expense.price), style: boldText(18)),
        ],
      ),
    );
  }
}
