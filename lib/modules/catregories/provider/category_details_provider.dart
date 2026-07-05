import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class CategoryDetailsProvider extends ChangeNotifier {
  final Ref ref;
  late Category category;
  List<Expense> expenses = [];
  bool isLoading = true;

  CategoryDetailsProvider(this.ref, Map args) {
    category = args['category'] as Category;
    loadExpenses();
  }

  String get title => "${category.emoji}  ${category.name}";

  Map<String, List<Expense>> get groupedExpenses {
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

  Future<void> loadExpenses() async {
    isLoading = true;
    notifyListeners();
    final result = await FirebaseHelper.getExpensesByCategory(category.id);
    expenses = result;
    isLoading = false;
    notifyListeners();
  }
}
