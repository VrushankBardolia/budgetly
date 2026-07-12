import 'package:budgetly/core/import_to_export.dart';

class DashboardState {
  final int selectedYear;
  final List<int> availableYears;
  final List<Expense> expenses;
  final List<Category> categories;
  final double totalSheetsBalance;
  final String donutCenterText;

  // Computed once in the constructor, not re-derived on every getter call.
  final Map<String, double> categoryTotals;
  final Map<int, double> monthlyTotals;

  DashboardState({
    required this.selectedYear,
    required this.availableYears,
    required this.expenses,
    required this.categories,
    required this.totalSheetsBalance,
    required this.donutCenterText,
  }) : categoryTotals = _computeCategoryTotals(expenses),
       monthlyTotals = _computeMonthlyTotals(expenses);

  static Map<String, double> _computeCategoryTotals(List<Expense> expenses) {
    final totals = <String, double>{};
    for (final e in expenses) {
      totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.price;
    }
    return totals;
  }

  static Map<int, double> _computeMonthlyTotals(List<Expense> expenses) {
    final totals = <int, double>{for (var i = 1; i <= 12; i++) i: 0.0};
    for (final e in expenses) {
      totals[e.date.month] = (totals[e.date.month] ?? 0) + e.price;
    }
    return totals;
  }

  DashboardState copyWith({
    int? selectedYear,
    List<int>? availableYears,
    List<Expense>? expenses,
    List<Category>? categories,
    double? totalSheetsBalance,
    String? donutCenterText,
  }) {
    return DashboardState(
      selectedYear: selectedYear ?? this.selectedYear,
      availableYears: availableYears ?? this.availableYears,
      expenses: expenses ?? this.expenses,
      categories: categories ?? this.categories,
      totalSheetsBalance: totalSheetsBalance ?? this.totalSheetsBalance,
      donutCenterText: donutCenterText ?? this.donutCenterText,
    );
  }

  // ─── Total Card Getters ───────────────────────────────────────────────────

  double get yearlyTotal => expenses.fold(0.0, (total, e) => total + e.price);

  double get currentMonthTotal {
    final month = DateTime.now().month;
    return expenses
        .where((e) => e.date.month == month && e.date.year == selectedYear)
        .fold(0.0, (total, e) => total + e.price);
  }

  // ─── Category Helper Methods ──────────────────────────────────────────────

  Category? getCategoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  int transactionCountForCategory(String categoryId) =>
      expenses.where((e) => e.categoryId == categoryId).length;

  // ─── Category List Calculations (all reuse the cached categoryTotals) ─────

  List<MapEntry<String, double>> get topCategoryEntries {
    final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  double get categoryMaxValue {
    if (categoryTotals.isEmpty) return 1.0;
    return categoryTotals.values.reduce((a, b) => a > b ? a : b);
  }

  double categoryPercentage(double value) => categoryMaxValue > 0 ? value / categoryMaxValue : 0.0;

  // ─── Pie Chart Calculations ───────────────────────────────────────────────

  List<MapEntry<String, double>> get sortedCategoryEntries {
    final sorted = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.length <= 6) return sorted;
    final top6 = sorted.sublist(0, 6);
    final remaining = sorted.sublist(6);
    final otherSum = remaining.fold(0.0, (sm, entry) => sm + entry.value);
    return [...top6, MapEntry('other', otherSum)];
  }

  double get categoryGrandTotal => categoryTotals.values.fold(0.0, (total, v) => total + v);

  String piePercentage(double value) =>
      categoryGrandTotal > 0 ? (value / categoryGrandTotal * 100).toStringAsFixed(2) : "0";

  // ─── Monthly Chart Calculations ───────────────────────────────────────────

  double get chartMaxY {
    final values = monthlyTotals.values;
    if (values.isEmpty) return 10000.0;
    return values.reduce((a, b) => a > b ? a : b) * 1.2;
  }
}
