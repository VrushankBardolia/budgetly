import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class DashboardProvider extends ChangeNotifier {
  final Ref ref;

  // ─── State ───────────────────────────────────────────────────────
  List<Expense> expenses = [];
  List<Category> categories = [];
  List<int> availableYears = [];
  int selectedYear = DateTime.now().year;
  bool isLoading = true;
  bool showMonthly = true;
  String donutCenterText = '';

  // Carousel
  double totalSheetsBalance = 0.0;
  int currentCarouselIndex = 0;

  DashboardProvider(this.ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  // ─── Initialisation ───────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    String? userId = FirebaseHelper.currentUser?.uid;
    await Future.delayed(const Duration(milliseconds: 300));
    userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    await Future.wait([loadAvailableYears(), loadCategories()]);

    if (availableYears.isNotEmpty) {
      if (!availableYears.contains(selectedYear)) {
        selectedYear = availableYears.first;
      }
      await loadExpenses(selectedYear);
    }

    await loadSheetsBalance();

    isLoading = false;
    notifyListeners();
    WidgetHelper.updateRemainingBudgetWidget();
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> loadAvailableYears() async {
    final results = await FirebaseHelper.getExpenses(DateTime(2000), DateTime(2100));

    if (results.isEmpty) {
      availableYears = [DateTime.now().year];
      notifyListeners();
      return;
    }

    final years = results.map((e) => e.date.year).toSet().toList()..sort((a, b) => b.compareTo(a));
    availableYears = years.isEmpty ? [DateTime.now().year] : years;
    notifyListeners();
  }

  Future<void> loadExpenses(int year) async {
    final result = await FirebaseHelper.getExpenses(
      DateTime(year, 1, 1),
      DateTime(year, 12, 31, 23, 59, 59),
    );
    expenses = result;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    final result = await FirebaseHelper.getCategories();
    categories = result;
    notifyListeners();
  }

  Future<void> loadSheetsBalance() async {
    try {
      totalSheetsBalance = await FirebaseHelper.getTotalSheetsBalance();
    } catch (e) {
      totalSheetsBalance = 0.0;
    }
    notifyListeners();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> changeYear(int year) async {
    selectedYear = year;
    isLoading = true;
    notifyListeners();

    await loadExpenses(year);

    isLoading = false;
    notifyListeners();
  }

  void toggleMonthlyYearly() {
    showMonthly = !showMonthly;
    notifyListeners();
  }

  void onCarouselPageChanged(int index) {
    currentCarouselIndex = index;
    notifyListeners();
  }

  // ─── Category Helper ──────────────────────────────────────────────────────

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int transactionCountForCategory(String categoryId) =>
      expenses.where((e) => e.categoryId == categoryId).length;

  // ─── Total Card ───────────────────────────────────────────────────────────

  double get yearlyTotal => expenses.fold(0.0, (total, e) => total + e.price);

  double get currentMonthTotal {
    final month = DateTime.now().month;
    return expenses
        .where((e) => e.date.month == month && e.date.year == selectedYear)
        .fold(0.0, (total, e) => total + e.price);
  }

  double get displayTotal => showMonthly ? currentMonthTotal : yearlyTotal;

  String get displayPeriodLabel {
    final year = selectedYear;
    if (showMonthly) {
      final monthName = DateFormat.MMMM().format(DateTime.now());
      return 'For $monthName $year';
    }
    return 'For $year';
  }

  // ─── Category List ────────────────────────────────────────────────────────

  /// Raw category ID → total map
  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (final e in expenses) {
      totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.price;
    }
    return totals;
  }

  /// Sorted descending, capped at top 3 — ready for the list
  List<MapEntry<String, double>> get topCategoryEntries {
    final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  /// Highest value among all categories — used to compute progress bar %
  double get categoryMaxValue {
    if (categoryTotals.isEmpty) return 1.0;
    return categoryTotals.values.reduce((a, b) => a > b ? a : b);
  }

  double categoryPercentage(double value) => categoryMaxValue > 0 ? value / categoryMaxValue : 0.0;

  // ─── Pie Chart ────────────────────────────────────────────────────────────

  /// All categories sorted descending — for the full pie
  List<MapEntry<String, double>> get sortedCategoryEntries {
    final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  double get categoryGrandTotal => categoryTotals.values.fold(0.0, (total, v) => total + v);

  String piePercentage(double value) =>
      categoryGrandTotal > 0 ? (value / categoryGrandTotal * 100).toStringAsFixed(2) : "0";

  void onDonutSectionTap(ChartPointDetails details) {
    if (details.pointIndex != null) {
      final tappedEntry = sortedCategoryEntries[details.pointIndex!];
      final value = tappedEntry.value;
      final pct = piePercentage(value);
      if ('$pct%' == donutCenterText) {
        donutCenterText = '';
      } else {
        donutCenterText = '$pct%';
      }
      notifyListeners();
    }
  }

  // ─── Monthly Chart ────────────────────────────────────────────────────────

  /// Month index (1–12) → total spent for [selectedYear]
  Map<int, double> get monthlyTotals {
    final totals = <int, double>{for (var i = 1; i <= 12; i++) i: 0.0};
    for (final e in expenses) {
      totals[e.date.month] = (totals[e.date.month] ?? 0) + e.price;
    }
    return totals;
  }

  /// Y-axis ceiling for the line chart with 20% headroom
  double get chartMaxY {
    final values = monthlyTotals.values;
    if (values.isEmpty) return 10000.0;
    return values.reduce((a, b) => a > b ? a : b) * 1.2;
  }
}
