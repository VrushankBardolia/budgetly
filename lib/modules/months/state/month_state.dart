import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class MonthState {
  final int selectedYear;
  final List<Expense> expenses;
  final List<MonthBudget> budgets;
  final List<MonthSummary> monthSummaries;

  MonthState({
    required this.selectedYear,
    required this.expenses,
    required this.budgets,
  }) : monthSummaries = _computeMonthSummaries(selectedYear, expenses, budgets);

  static List<MonthSummary> _computeMonthSummaries(
    int selectedYear,
    List<Expense> expenses,
    List<MonthBudget> budgets,
  ) {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final month = index + 1;
      final monthDate = DateTime(selectedYear, month);

      final isCurrent = monthDate.year == now.year && monthDate.month == now.month;
      final isPast = monthDate.isBefore(DateTime(now.year, now.month));

      final budget = _getBudgetForMonth(budgets, selectedYear, month);
      final expense = _getTotalExpenseForMonth(expenses, selectedYear, month);
      final difference = budget - expense;
      final progressValue = budget > 0 ? (expense / budget).clamp(0.0, 1.0) : 0.0;

      final hasData = (isPast && budget > 0) || (isCurrent && (budget > 0 || expense > 0));

      final isBalanced = difference == 0;
      final isSaved = difference > 0;

      Color statusColor;
      String statusLabel;
      dynamic statusIcon;

      if (isBalanced) {
        statusColor = AppColors.warning;
        statusLabel = 'On Target';
        statusIcon = HugeIcons.strokeRoundedAlert02;
      } else if (isSaved) {
        statusColor = AppColors.success;
        statusLabel = isCurrent ? 'Remaining' : 'Saved';
        statusIcon = HugeIcons.strokeRoundedCheckmarkCircle03;
      } else {
        statusColor = AppColors.error;
        statusLabel = 'Overspent';
        statusIcon = HugeIcons.strokeRoundedCancelCircle;
      }

      if (isCurrent) {
        statusColor = AppColors.secondaryAccent;
      }

      return MonthSummary(
        month: month,
        monthName: DateFormat('MMMM').format(monthDate),
        budget: budget,
        expense: expense,
        difference: difference,
        progressValue: progressValue,
        isCurrent: isCurrent,
        isPast: isPast,
        hasData: hasData,
        statusColor: statusColor,
        statusLabel: statusLabel,
        statusIcon: statusIcon,
      );
    });
  }

  static double _getBudgetForMonth(List<MonthBudget> budgets, int year, int month) {
    for (final b in budgets) {
      if (b.year == year && b.month == month) return b.budget;
    }
    return 0.0;
  }

  static double _getTotalExpenseForMonth(List<Expense> expenses, int year, int month) {
    double total = 0.0;
    for (final e in expenses) {
      if (e.date.year == year && e.date.month == month) {
        total += e.price;
      }
    }
    return total;
  }
}
