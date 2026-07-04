import 'package:budgetly/core/import_to_export.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

class WidgetHelper {
  static const String androidWidgetName = 'RemainingBudgetWidgetProvider';

  static Future<void> updateRemainingBudgetWidget() async {
    try {
      final user = FirebaseHelper.currentUser;
      if (user == null) {
        await HomeWidget.saveWidgetData<String>('remaining_budget', 'Log In');
        await HomeWidget.saveWidgetData<String>('budget_value', '₹0');
        await HomeWidget.saveWidgetData<String>('expense_value', '₹0');
        await HomeWidget.saveWidgetData<String>('month_name', 'Budget Tracker');
        await HomeWidget.updateWidget(androidName: androidWidgetName);
        return;
      }

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // Fetch all budgets for current year (uses existing, working indexed query)
      final budgetsList = await FirebaseHelper.getBudgets(year);
      MonthBudget? budgetObj;
      try {
        budgetObj = budgetsList.firstWhere((b) => b.month == month);
      } catch (_) {
        budgetObj = null;
      }

      // Fetch current month expenses (uses existing, working indexed query)
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));
      final expensesList = await FirebaseHelper.getExpenses(startDate, endDate);
      final totalExpense = expensesList.fold(0.0, (acc, e) => acc + e.price);

      final budget = budgetObj?.budget ?? 0.0;
      final remaining = budget - totalExpense;
      final monthName = DateFormat('MMMM').format(now);

      await HomeWidget.saveWidgetData<String>(
        'remaining_budget',
        '₹${remaining.toStringAsFixed(0)}',
      );
      await HomeWidget.saveWidgetData<String>('budget_value', '₹${budget.toStringAsFixed(0)}');
      await HomeWidget.saveWidgetData<String>(
        'expense_value',
        '₹${totalExpense.toStringAsFixed(0)}',
      );
      await HomeWidget.saveWidgetData<String>('month_name', monthName);

      await HomeWidget.updateWidget(androidName: androidWidgetName);
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }
}
