import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class DashboardController extends GetxController {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<int> availableYears = <int>[DateTime.now().year].obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxBool isLoading = true.obs;
  final RxBool showMonthly = true.obs;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  // ─── Initialisation ───────────────────────────────────────────────────────

  Future<void> _init() async {
    isLoading.value = true;
    await Future.wait([loadAvailableYears(), loadCategories()]);
    if (availableYears.isNotEmpty) {
      if (!availableYears.contains(selectedYear.value)) {
        selectedYear.value = availableYears.first;
      }
      await loadExpenses(selectedYear.value);
    }
    isLoading.value = false;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([loadAvailableYears(), loadCategories()]);
    if (availableYears.isNotEmpty) {
      if (!availableYears.contains(selectedYear.value)) {
        selectedYear.value = availableYears.first;
      }
      await loadExpenses(selectedYear.value);
    }
    isLoading.value = false;
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> loadAvailableYears() async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseHelper.getExpenses(userId, DateTime(2000), DateTime(2100));

    if (snapshot.docs.isEmpty) {
      availableYears.assignAll([DateTime.now().year]);
      return;
    }

    final years = snapshot.docs.map((doc) => Expense.fromFirestore(doc).date.year).toSet().toList()..sort((a, b) => b.compareTo(a));

    availableYears.assignAll(years.isEmpty ? [DateTime.now().year] : years);
  }

  Future<void> loadExpenses(int year) async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseHelper.getExpenses(userId, DateTime(year, 1, 1), DateTime(year, 12, 31, 23, 59, 59));

    expenses.assignAll(snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> loadCategories() async {
    final userId = FirebaseHelper.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseHelper.getCategories(userId);
    categories.assignAll(snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> changeYear(int year) async {
    selectedYear.value = year;
    await loadExpenses(year);
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

  int transactionCountForCategory(String categoryId) => expenses.where((e) => e.categoryId == categoryId).length;

  // ─── Total Card ───────────────────────────────────────────────────────────

  double get yearlyTotal => expenses.fold(0.0, (sum, e) => sum + e.price);

  double get currentMonthTotal {
    final month = DateTime.now().month;
    return expenses.where((e) => e.date.month == month && e.date.year == selectedYear.value).fold(0.0, (sum, e) => sum + e.price);
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

  double piePercentage(double value) => categoryGrandTotal > 0 ? value / categoryGrandTotal * 100 : 0.0;

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
