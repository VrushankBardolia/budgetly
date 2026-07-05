import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class MonthProvider extends ChangeNotifier {
  final Ref ref;

  // ─── State ───────────────────────────────────────────────────────
  List<Expense> expenses = [];
  List<MonthBudget> budgets = [];
  int selectedYear = DateTime.now().year;
  bool isLoading = true;

  MonthProvider(this.ref) {
    loadData();
  }

  // ─── Derived ──────────────────────────────────────────────────────────────
  List<MonthSummary> get monthSummaries {
    final now = DateTime.now();
    return List.generate(12, (index) {
      final month = index + 1;
      final monthDate = DateTime(selectedYear, month);

      final isCurrent = monthDate.year == now.year && monthDate.month == now.month;
      final isPast = monthDate.isBefore(DateTime(now.year, now.month));

      final budget = _getBudgetForMonth(selectedYear, month);
      final expense = _getTotalExpenseForMonth(selectedYear, month);
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
    isLoading = true;
    notifyListeners();
    await Future.wait([_loadExpenses(selectedYear), _loadBudgets(selectedYear)]);
    isLoading = false;
    notifyListeners();
    WidgetHelper.updateRemainingBudgetWidget();
  }

  Future<void> changeYear(int year) async {
    selectedYear = year;
    notifyListeners();
    await _loadAll(year);
  }

  Future<void> navigateToMonth(int month) async {
    await appRouter.pushNamed(Routes.MONTH_DETAILS, extra: {'year': selectedYear, 'month': month});
    await _loadAll(selectedYear);
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> _loadAll(int year) async {
    isLoading = true;
    notifyListeners();
    await Future.wait([_loadExpenses(year), _loadBudgets(year)]);
    isLoading = false;
    notifyListeners();
    WidgetHelper.updateRemainingBudgetWidget();
  }

  Future<void> _loadExpenses(int year) async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final result = await FirebaseHelper.getExpenses(
      DateTime(year, 1, 1),
      DateTime(year, 12, 31, 23, 59, 59),
    );

    expenses = result;
    notifyListeners();
  }

  Future<void> _loadBudgets(int year) async {
    final result = await FirebaseHelper.getBudgets(year);

    budgets = result;
    notifyListeners();
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
