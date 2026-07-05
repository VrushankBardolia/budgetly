import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final prov = ref.watch(categoryDetailsProvider(args));

    return Scaffold(
      appBar: AppBar(title: Text(prov.title, style: boldText(20)), centerTitle: true, elevation: 0),
      body: prov.isLoading ? const Center(child: CircularProgressIndicator()) : buildList(prov),
    );
  }

  Widget buildList(CategoryDetailsProvider prov) {
    final grouped = prov.groupedExpenses;
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
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthHeader(month, monthTotal),
              ...monthExpenses.asMap().entries.map((entry) {
                final isLast = entry.key == monthExpenses.length - 1;
                return Column(
                  children: [
                    _buildExpenseTile(entry.value),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.borderColor.withValues(alpha: .3),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthHeader(String month, double total) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          colors: [AppColors.brandDark.withValues(alpha: .7), AppColors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.3, 1],
        ),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.calendar, color: AppColors.brand, size: 20),
          const SizedBox(width: 12),
          Text(month, style: boldText(16, color: AppColors.brand)),
          const Spacer(),
          Text(formatter.format(total), style: boldText(16, color: AppColors.brand)),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(Expense expense) {
    final date = DateFormat('dd').format(expense.date);
    final dayName = DateFormat('E').format(expense.date).toUpperCase();
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(date, style: boldText(14, color: AppColors.white).copyWith(height: 1.2)),
              Text(dayName, style: mediumText(10, color: AppColors.grey)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              expense.detail.isNotEmpty ? expense.detail : 'Expense',
              style: mediumText(14, color: AppColors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(formatter.format(expense.price), style: mediumText(14, color: AppColors.white)),
        ],
      ),
    );
  }
}
