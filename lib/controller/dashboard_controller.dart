import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../model/expense.dart';
import '../model/category.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Reactive State ───────────────────────────────────────────────────────
  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<int> availableYears = <int>[].obs;
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
      // Keep selectedYear valid
      if (!availableYears.contains(selectedYear.value)) {
        selectedYear.value = availableYears.first;
      }
      await loadExpenses(selectedYear.value);
    }

    isLoading.value = false;
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> loadAvailableYears() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db.collection('expenses').where('userId', isEqualTo: userId).get();

    if (snapshot.docs.isEmpty) {
      availableYears.assignAll([DateTime.now().year]);
      return;
    }

    final years = snapshot.docs.map((doc) => Expense.fromFirestore(doc).date.year).toSet().toList()..sort((a, b) => b.compareTo(a));

    availableYears.assignAll(years.isEmpty ? [DateTime.now().year] : years);
  }

  Future<void> loadExpenses(int year) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59);

    final snapshot = await _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    expenses.assignAll(snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> loadCategories() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db.collection('categories').where('userId', isEqualTo: userId).orderBy('name').get();

    categories.assignAll(snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> changeYear(int year) async {
    selectedYear.value = year;
    await loadExpenses(year);
  }

  void toggleMonthlyYearly() {
    showMonthly.value = !showMonthly.value;
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

  /// Total spent across all categories for [selectedYear]
  double get yearlyTotal => expenses.fold(0.0, (sum, e) => sum + e.price);

  /// Total spent in the current month of [selectedYear]
  double get currentMonthTotal {
    final month = DateTime.now().month;
    return expenses.where((e) => e.date.month == month && e.date.year == selectedYear.value).fold(0.0, (sum, e) => sum + e.price);
  }

  /// Category ID → total spent, filtered to [selectedYear]
  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (final e in expenses) {
      totals[e.categoryId] = (totals[e.categoryId] ?? 0) + e.price;
    }
    return totals;
  }

  /// Month index (1–12) → total spent for [selectedYear]
  Map<int, double> get monthlyTotals {
    final totals = <int, double>{for (var i = 1; i <= 12; i++) i: 0.0};
    for (final e in expenses) {
      totals[e.date.month] = (totals[e.date.month] ?? 0) + e.price;
    }
    return totals;
  }

  /// Transaction count per category ID for [selectedYear]
  int transactionCountForCategory(String categoryId) => expenses.where((e) => e.categoryId == categoryId).length;
}
