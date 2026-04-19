import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class MonthController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<MonthBudget> budgets = <MonthBudget>[].obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxBool isLoading = true.obs;

  // ─── Derived ──────────────────────────────────────────────────────────────
  List<MonthSummary> get monthSummaries {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final month = index + 1;
      final monthDate = DateTime(selectedYear.value, month);

      final isCurrent = monthDate.year == now.year && monthDate.month == now.month;
      final isPast = monthDate.isBefore(DateTime(now.year, now.month));

      final budget = _getBudgetForMonth(selectedYear.value, month);
      final expense = _getTotalExpenseForMonth(selectedYear.value, month);
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

  // ─── Public Actions ───────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([_loadExpenses(selectedYear.value), _loadBudgets(selectedYear.value)]);
    isLoading.value = false;
  }

  Future<void> changeYear(int year) async {
    selectedYear.value = year;
    await _loadAll(year);
  }

  Future<void> navigateToMonth(int month) async {
    await Get.toNamed(
      Routes.MONTH_DETAILS,
      arguments: {'year': selectedYear.value, 'month': month},
    );
    await _loadAll(selectedYear.value);
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> _loadAll(int year) async {
    isLoading.value = true;
    await Future.wait([_loadExpenses(year), _loadBudgets(year)]);
    isLoading.value = false;
  }

  Future<void> _loadExpenses(int year) async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseHelper.getExpenses(
      DateTime(year, 1, 1),
      DateTime(year, 12, 31, 23, 59, 59),
    );

    expenses.assignAll(snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> _loadBudgets(int year) async {
    final snapshot = await FirebaseHelper.getBudgets(year);

    budgets.assignAll(snapshot.docs.map((doc) => MonthBudget.fromFirestore(doc)).toList());
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  double _getBudgetForMonth(int year, int month) {
    try {
      return budgets
          .firstWhere(
            (b) => b.year == year && b.month == month,
            orElse: () => MonthBudget(id: '', year: year, month: month, budget: 0, userId: ''),
          )
          .budget;
    } catch (_) {
      return 0.0;
    }
  }

  double _getTotalExpenseForMonth(int year, int month) {
    return expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .fold(0.0, (total, e) => total + e.price);
  }
}
