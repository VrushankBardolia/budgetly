import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class CategoryDetailsController extends GetxController {
  late Category category;
  RxList<Expense> expenses = <Expense>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    category = Get.arguments['category'] as Category;
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
    isLoading.value = true;
    final snapshot = await FirebaseHelper.getExpensesByCategory(category.id);
    expenses.assignAll(snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
    isLoading.value = false;
  }
}
