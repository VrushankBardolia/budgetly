import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<int> availableYears = <int>[].obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxBool isLoading = true.obs;
  final RxBool showMonthly = true.obs;
  final RxString donutCenterText = ''.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Use addPostFrameCallback to ensure the widget tree is fully built
    // before kicking off the heavy lifting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  // ─── Initialisation ───────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading.value = true;
    String? userId = FirebaseHelper.currentUser?.uid;
    await Future.delayed(const Duration(milliseconds: 300));
    userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    await Future.wait([loadAvailableYears(), loadCategories()]);

    if (availableYears.isNotEmpty) {
      if (!availableYears.contains(selectedYear.value)) {
        selectedYear.value = availableYears.first;
      }
      await loadExpenses(userId, selectedYear.value);
    }
    isLoading.value = false;
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  // Updated to accept userId as a parameter
  Future<void> loadAvailableYears() async {
    final snapshot = await FirebaseHelper.getExpenses(DateTime(2000), DateTime(2100));

    if (snapshot.docs.isEmpty) {
      availableYears.assignAll([DateTime.now().year]);
      return;
    }

    final years = snapshot.docs.map((doc) => Expense.fromFirestore(doc).date.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    availableYears.assignAll(years.isEmpty ? [DateTime.now().year] : years);
  }

  // Updated to accept userId as a parameter
  Future<void> loadExpenses(String userId, int year) async {
    final snapshot = await FirebaseHelper.getExpenses(
      DateTime(year, 1, 1),
      DateTime(year, 12, 31, 23, 59, 59),
    );

    expenses.assignAll(snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  // Updated to accept userId as a parameter
  Future<void> loadCategories() async {
    final snapshot = await FirebaseHelper.getCategories();
    categories.assignAll(snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> changeYear(int year) async {
    selectedYear.value = year;

    // Quick check to grab the user ID for the year change
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId != null) {
      isLoading.value = true;
      await loadExpenses(userId, year);
      isLoading.value = false;
    }
  }

  void toggleMonthlyYearly() => showMonthly.value = !showMonthly.value;

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

  double get yearlyTotal => expenses.fold(0.0, (sum, e) => sum + e.price);

  double get currentMonthTotal {
    final month = DateTime.now().month;
    return expenses
        .where((e) => e.date.month == month && e.date.year == selectedYear.value)
        .fold(0.0, (sum, e) => sum + e.price);
  }

  double get displayTotal => showMonthly.value ? currentMonthTotal : yearlyTotal;

  String get displayPeriodLabel {
    final year = selectedYear.value;
    if (showMonthly.value) {
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

  double get categoryGrandTotal => categoryTotals.values.fold(0.0, (sum, v) => sum + v);

  String piePercentage(double value) =>
      categoryGrandTotal > 0 ? (value / categoryGrandTotal * 100).toStringAsFixed(2) : "0";

  void onDonutSectionTap(ChartPointDetails details) {
    if (details.pointIndex != null) {
      final tappedEntry = sortedCategoryEntries[details.pointIndex!];
      final value = (tappedEntry).value;
      final pct = piePercentage(value);
      if ('$pct%' == donutCenterText.value) {
        donutCenterText.value = '';
      } else {
        donutCenterText.value = '$pct%';
      }
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
