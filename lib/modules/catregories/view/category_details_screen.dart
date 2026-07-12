import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class CategoryDetailsScreen extends ConsumerWidget {
  const CategoryDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final category = args['category'] as Category;
    final stateAsync = ref.watch(categoryDetailsStateProvider(category));

    return stateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text("${category.emoji}  ${category.name}", style: serifText(20)),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.brand)),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: Text("${category.emoji}  ${category.name}", style: serifText(20)),
          centerTitle: true,
        ),
        body: Center(child: Text('Error loading details: $err')),
      ),
      data: (state) => Scaffold(
        appBar: AppBar(title: Text(state.title, style: serifText(20)), centerTitle: true),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoryExpensesProvider(state.category.id));
          },
          color: AppColors.brand,
          child: buildList(state),
        ),
      ),
    );
  }

  Widget buildList(CategoryDetailsState state) {
    final grouped = state.groupedExpenses;
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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthHeader(month, monthTotal),
              Divider(
                height: 1,
                color: AppColors.brand.withValues(alpha: 0.2),
                indent: 12,
                endIndent: 12,
              ),
              ...monthExpenses.map(_buildExpenseTile),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthHeader(String month, double total) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(month, style: boldText(16, color: AppColors.brand)),
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
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(date, style: boldText(14, color: AppColors.textPrimary).copyWith(height: 1.2)),
                Text(dayName, style: mediumText(10, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              expense.detail.isNotEmpty ? expense.detail : 'Expense',
              style: mediumText(14, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            formatter.format(expense.price),
            style: mediumText(14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
