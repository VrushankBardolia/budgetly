import 'package:budgetly/core/import_to_export.dart';

class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;

  final screens = [DashboardTab(), MonthsTab(), CategoriesTab(), SettingsTab()];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> loadData() async {
    final categoryController = Get.find<CategoryController>();
    final expenseController = Get.find<ExpenseController>();

    await categoryController.loadCategories();
    await expenseController.loadExpenses(expenseController.selectedYear);
    await expenseController.loadBudgets(expenseController.selectedYear);

    NotificationService.consumeInitialNotification();
  }
}
