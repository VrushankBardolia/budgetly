import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class MonthDetailState {
  final int year;
  final int month;
  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final List<Category> categories;
  final int budget;
  final String selectedSortOption;
  final String selectedFilterCategoryId;
  final String selectedFilterOptionName;
  final bool includeCategory;
  final bool includeTxList;
  final bool isExporting;

  // Pre-computed fields
  final Map<String, List<Expense>> groupedExpenses;
  final double totalExpense;
  final double filteredExpenseTotal;
  final double remaining;
  final int totalDays;
  final int remainingDays;
  final double remainPerDay;
  final bool hasBudget;
  final bool isCurrent;
  final bool isBalanced;
  final bool isSaved;
  final Color statusColor;
  final String statusLabel;
  final dynamic statusIcon;
  final String formattedMonth;
  final NumberFormat formatter;

  MonthDetailState({
    required this.year,
    required this.month,
    required this.allExpenses,
    required this.filteredExpenses,
    required this.categories,
    required this.budget,
    required this.selectedSortOption,
    required this.selectedFilterCategoryId,
    required this.selectedFilterOptionName,
    required this.includeCategory,
    required this.includeTxList,
    required this.isExporting,
  })  : groupedExpenses = _computeGroupedExpenses(filteredExpenses),
        totalExpense = allExpenses.fold(0.0, (total, e) => total + e.price),
        filteredExpenseTotal = filteredExpenses.fold(0.0, (total, e) => total + e.price),
        remaining = budget - allExpenses.fold(0.0, (total, e) => total + e.price),
        totalDays = DateTime(year, month + 1, 0).day,
        remainingDays = _computeRemainingDays(year, month),
        remainPerDay = _computeRemainPerDay(budget, allExpenses, year, month),
        hasBudget = budget > 0,
        isCurrent = _computeIsCurrent(year, month),
        isBalanced = (budget - allExpenses.fold(0.0, (total, e) => total + e.price)) == 0,
        isSaved = (budget - allExpenses.fold(0.0, (total, e) => total + e.price)) > 0,
        statusColor = _computeStatusColor(budget, allExpenses),
        statusLabel = _computeStatusLabel(budget, allExpenses, year, month),
        statusIcon = _computeStatusIcon(budget, allExpenses),
        formattedMonth = DateFormat('MMMM yyyy').format(DateTime(year, month)),
        formatter = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

  static Map<String, List<Expense>> _computeGroupedExpenses(List<Expense> filteredExpenses) {
    final grouped = <String, List<Expense>>{};
    for (var expense in filteredExpenses) {
      final monthYear = DateFormat('MMMM yyyy').format(expense.date);
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(expense);
    }
    return grouped;
  }

  static int _computeRemainingDays(int year, int month) {
    final totalDays = DateTime(year, month + 1, 0).day;
    final diff = totalDays - DateTime.now().day + 1;
    return diff > 0 ? diff : 0;
  }

  static double _computeRemainPerDay(int budget, List<Expense> allExpenses, int year, int month) {
    final remaining = budget - allExpenses.fold(0.0, (total, e) => total + e.price);
    final remainingDays = _computeRemainingDays(year, month);
    return remainingDays > 0 ? remaining / remainingDays : 0.0;
  }

  static bool _computeIsCurrent(int year, int month) {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  static Color _computeStatusColor(int budget, List<Expense> allExpenses) {
    final remaining = budget - allExpenses.fold(0.0, (total, e) => total + e.price);
    if (remaining == 0) return AppColors.warning;
    if (remaining > 0) return AppColors.success;
    return AppColors.error;
  }

  static String _computeStatusLabel(int budget, List<Expense> allExpenses, int year, int month) {
    final remaining = budget - allExpenses.fold(0.0, (total, e) => total + e.price);
    final isCurrent = _computeIsCurrent(year, month);
    if (remaining == 0) return 'On Target';
    if (remaining > 0) return isCurrent ? 'Remaining' : 'Saved';
    return 'Overspent';
  }

  static dynamic _computeStatusIcon(int budget, List<Expense> allExpenses) {
    final remaining = budget - allExpenses.fold(0.0, (total, e) => total + e.price);
    if (remaining == 0) return HugeIcons.strokeRoundedAlert02;
    if (remaining > 0) return HugeIcons.strokeRoundedCheckmarkCircle03;
    return HugeIcons.strokeRoundedCancelCircle;
  }

  Category? getCategoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
