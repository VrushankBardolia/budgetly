import 'package:budgetly/core/import_to_export.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpensesInRange(DateTime start, DateTime end);
  Future<double> getTotalSheetsBalance();
  Future<List<Expense>> getYearsWithExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(String id, Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> deleteUserExpenses();
  Future<List<Expense>> getExpensesByCategory(String categoryId);
}

class FirebaseExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Expense>> getExpensesInRange(DateTime start, DateTime end) {
    return FirebaseHelper.getExpenses(start, end);
  }

  @override
  Future<double> getTotalSheetsBalance() {
    return FirebaseHelper.getTotalSheetsBalance();
  }

  @override
  Future<List<Expense>> getYearsWithExpenses() {
    return FirebaseHelper.getYearsWithExpenses();
  }

  @override
  Future<void> addExpense(Expense expense) {
    return FirebaseHelper.addExpense(expense);
  }

  @override
  Future<void> updateExpense(String id, Expense expense) {
    return FirebaseHelper.updateExpense(id, expense);
  }

  @override
  Future<void> deleteExpense(String id) {
    return FirebaseHelper.deleteExpense(id);
  }

  @override
  Future<void> deleteUserExpenses() {
    return FirebaseHelper.deleteUserExpenses();
  }

  @override
  Future<List<Expense>> getExpensesByCategory(String categoryId) {
    return FirebaseHelper.getExpensesByCategory(categoryId);
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return FirebaseExpenseRepository();
});
