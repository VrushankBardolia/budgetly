import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../model/Expense.dart';
import '../model/MonthBudget.dart';

class ExpenseController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Expense> _expenses = <Expense>[].obs;
  final RxList<MonthBudget> _budgets = <MonthBudget>[].obs;
  final RxInt _selectedYear = DateTime.now().year.obs;

  List<Expense> get expenses => _expenses;
  List<MonthBudget> get budgets => _budgets;
  int get selectedYear => _selectedYear.value;

  @override
  void onInit() {
    super.onInit();
    loadExpenses(_selectedYear.value);
  }

  void setSelectedYear(int year) {
    _selectedYear.value = year;
    loadExpenses(year);
  }

  Future<void> loadExpenses(int year) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31, 23, 59, 59);

    final snapshot = await _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .get();

    _expenses.assignAll(
      snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList(),
    );
  }

  Future<void> loadBudgets(int year) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('year', isEqualTo: year)
        .get();

    _budgets.assignAll(
      snapshot.docs.map((doc) => MonthBudget.fromFirestore(doc)).toList(),
    );
  }

  Future<List<int>> getYearsWithExpenses() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [DateTime.now().year];

    final snapshot = await _db
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) {
      return [DateTime.now().year];
    }

    final years = <int>{};
    for (var doc in snapshot.docs) {
      final expense = Expense.fromFirestore(doc);
      years.add(expense.date.year);
    }

    if (years.isEmpty) {
      return [DateTime.now().year];
    }

    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    return sortedYears;
  }

  Future<void> addExpense(Expense expense) async {
    await _db.collection('expenses').add(expense.toFirestore());
    await loadExpenses(_selectedYear.value);
  }

  Future<void> updateExpense(String id, Expense expense) async {
    await _db.collection('expenses').doc(id).update(expense.toFirestore());
    await loadExpenses(_selectedYear.value);
  }

  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete();
    await loadExpenses(_selectedYear.value);
  }

  Future<void> setBudget(int year, int month, double budget) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await _db
        .collection('budgets')
        .where('userId', isEqualTo: userId)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .get();

    if (snapshot.docs.isEmpty) {
      await _db.collection('budgets').add({
        'userId': userId,
        'year': year,
        'month': month,
        'budget': budget,
      });
    } else {
      await _db.collection('budgets').doc(snapshot.docs.first.id).update({
        'budget': budget,
      });
    }

    await loadBudgets(year);
  }

  double getBudgetForMonth(int year, int month) {
    if (_budgets.isEmpty) return 0.0;

    // Using firstWhereOrNull logic essentially
    try {
      final budget = _budgets.firstWhere(
        (b) => b.year == year && b.month == month,
        orElse: () => MonthBudget(
          id: '',
          year: year,
          month: month,
          budget: 0,
          userId: '',
        ),
      );
      return budget.budget;
    } catch (e) {
      return 0.0;
    }
  }

  List<Expense> getExpensesForMonth(int year, int month) {
    return _expenses
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  double getTotalExpenseForMonth(int year, int month) {
    return getExpensesForMonth(year, month).fold(0, (sum, e) => sum + e.price);
  }

  Map<String, double> getCategoryTotals(int year) {
    final categoryTotals = <String, double>{};
    for (var expense in _expenses) {
      if (expense.date.year == year) {
        // categoryId check?
        // Logic from provider:
        categoryTotals[expense.categoryId] =
            (categoryTotals[expense.categoryId] ?? 0) + expense.price;
      }
    }
    return categoryTotals;
  }
}
