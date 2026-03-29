import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class MonthDetailController extends GetxController {
  // ─── Arguments via GetX ───────────────────────────────────────────────────
  final int year = Get.arguments['year'] ?? DateTime.now().year;
  final int month = Get.arguments['month'] ?? DateTime.now().month;

  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxInt budget = 0.obs;
  final RxBool isLoading = true.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadAll();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBudgetAndShowDialog());
  }

  // ─── Budget Dialog ────────────────────────────────────────────────────────

  void _checkBudgetAndShowDialog() {
    if (!isLoading.value) {
      if (!hasBudget) showBudgetDialog();
    } else {
      once(isLoading, (bool loading) {
        if (!loading && !hasBudget && Get.isDialogOpen != true) {
          showBudgetDialog();
        }
      });
    }
  }

  Future<void> showBudgetDialog() async {
    final budgetField = TextEditingController(text: budget.value > 0 ? budget.value.toString() : '');

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Set Budget',
          textAlign: TextAlign.center,
          style: boldText(14, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedMonth, style: regularText(14, color: AppColors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: budgetField,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: regularText(14),
              decoration: InputDecoration(
                hintStyle: regularText(14, color: Colors.grey.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.surfaceLight,
                prefixText: '₹',
                hintText: 'Enter amount',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.brand, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(budgetField.text.isEmpty ? 'Skip' : 'Cancel', style: regularText(14, color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(budgetField.text);
              if (value != null && value > 0) {
                await setBudget(value);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: boldText(14)),
          ),
        ],
      ),
    );
  }

  // ─── Navigation to Expense Screen ─────────────────────────────────────────

  Future<void> goToAddExpense() async {
    final result = await Get.toNamed(Routes.EXPENSE_FORM, arguments: {'year': year, 'month': month});
    if (result == true) await loadExpenses();
  }

  Future<void> goToEditExpense(Expense expense) async {
    final result = await Get.toNamed(Routes.EXPENSE_FORM, arguments: {'year': year, 'month': month, 'expense': expense});
    if (result == true) await loadExpenses();
  }

  // ─── Delete Dialog ────────────────────────────────────────────────────────

  Future<void> showDeleteExpenseDialog(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Expense', style: boldText(14)),
        content: Text('Are you sure you want to delete this expense?', style: regularText(14, color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: regularText(14, color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: regularText(14, color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) await deleteExpense(id);
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadExpenses(), loadBudget(), loadCategories()]);
    isLoading.value = false;
  }

  Future<void> loadExpenses() async {
    final userId = PreferenceHelper.userId;
    if (userId.isEmpty) return;

    final snapshot = await FirebaseHelper.getExpenses(userId, DateTime(year, month, 1), DateTime(year, month + 1, 0, 23, 59, 59));
    expenses.assignAll(snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> loadBudget() async {
    final userId = PreferenceHelper.userId;
    if (userId.isEmpty) return;

    final snapshot = await FirebaseHelper.getBudgetForMonth(userId, year, month);
    if (snapshot.docs.isNotEmpty) {
      budget.value = (snapshot.docs.first.data()['budget'] as num).toInt();
    }
  }

  Future<void> loadCategories() async {
    final userId = PreferenceHelper.userId;
    if (userId.isEmpty) return;

    final snapshot = await FirebaseHelper.getCategories(userId);
    categories.assignAll(snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // ─── Budget CRUD ──────────────────────────────────────────────────────────

  Future<void> setBudget(int value) async {
    final userId = PreferenceHelper.userId;
    if (userId.isEmpty) return;

    final snapshot = await FirebaseHelper.getBudgetForMonth(userId, year, month);
    if (snapshot.docs.isEmpty) {
      await FirebaseHelper.addBudget({'userId': userId, 'year': year, 'month': month, 'budget': value});
    } else {
      await FirebaseHelper.updateBudget(snapshot.docs.first.id, value);
    }
    budget.value = value;
  }

  // ─── Expense CRUD ─────────────────────────────────────────────────────────

  Future<void> deleteExpense(String id) async {
    await FirebaseHelper.deleteExpense(id);
    await loadExpenses();
  }

  // ─── Category Helper ──────────────────────────────────────────────────────

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Derived Getters ──────────────────────────────────────────────────────

  double get totalExpense => expenses.fold(0.0, (sum, e) => sum + e.price);
  double get remaining => budget.value - totalExpense;
  int get totalDays => DateTime(year, month + 1, 0).day;

  int get remainingDays {
    final diff = totalDays - DateTime.now().day + 1;
    return diff > 0 ? diff : 0;
  }

  double get remainPerDay => remainingDays > 0 ? remaining / remainingDays : 0.0;
  bool get hasBudget => budget.value > 0;

  bool get isCurrent {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isBalanced => remaining == 0;
  bool get isSaved => remaining > 0;

  Color get statusColor {
    if (isBalanced) return AppColors.warning;
    if (isSaved) return AppColors.success;
    return AppColors.error;
  }

  String get statusLabel {
    if (isBalanced) return 'On Target';
    if (isSaved) return isCurrent ? 'Remaining' : 'Saved';
    return 'Overspent';
  }

  dynamic get statusIcon {
    if (isBalanced) return HugeIcons.strokeRoundedAlert02;
    if (isSaved) return HugeIcons.strokeRoundedCheckmarkCircle03;
    return HugeIcons.strokeRoundedCancelCircle;
  }

  String get formattedMonth => DateFormat('MMMM yyyy').format(DateTime(year, month));
  NumberFormat get formatter => NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
}
