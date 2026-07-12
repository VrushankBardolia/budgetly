import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class CategoryDetailsState {
  final Category category;
  final List<Expense> expenses;

  // Pre-computed fields
  final String title;
  final Map<String, List<Expense>> groupedExpenses;

  CategoryDetailsState({
    required this.category,
    required this.expenses,
  })  : title = "${category.emoji}  ${category.name}",
        groupedExpenses = _computeGroupedExpenses(expenses);

  static Map<String, List<Expense>> _computeGroupedExpenses(List<Expense> expenses) {
    final grouped = <String, List<Expense>>{};
    for (var expense in expenses) {
      final monthYear = DateFormat('MMMM yyyy').format(expense.date);
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(expense);
    }
    return grouped;
  }
}
