import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class CategoryDetailsScreen extends GetView<CategoryDetailsController> {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.title, style: boldText(20)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final grouped = controller.groupedExpenses;
        final keys = grouped.keys.toList();

        if (keys.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.borderColor),
                const SizedBox(height: 16),
                Text("No expenses yet", style: regularText(16, color: AppColors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 32),
          physics: const BouncingScrollPhysics(),
          itemCount: keys.length,
          itemBuilder: (context, index) {
            final month = keys[index];
            final monthExpenses = grouped[month]!;
            final monthTotal = monthExpenses.fold(0.0, (total, e) => total + e.price);

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthHeader(month, monthTotal),
                  ...monthExpenses.map((expense) => _buildExpenseTile(expense)),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMonthHeader(String month, double total) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Column(
      spacing: 8,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month, style: boldText(18, color: AppColors.brand)),
              Text(formatter.format(total), style: semiBoldText(18, color: AppColors.brand)),
            ],
          ),
        ),
        Divider(color: AppColors.borderColor),
      ],
    );
  }

  Widget _buildExpenseTile(Expense expense) {
    final date = DateFormat('dd').format(expense.date);
    final dayName = DateFormat('E').format(expense.date).toUpperCase();
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(date, style: boldText(18)),
                Text(dayName, style: regularText(12, color: AppColors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Text(
              expense.detail.isNotEmpty ? expense.detail : 'Expense',
              style: semiBoldText(16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Text(formatter.format(expense.price), style: boldText(16)),
        ],
      ),
    );
  }
}
