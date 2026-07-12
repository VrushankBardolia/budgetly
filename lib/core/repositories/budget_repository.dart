import 'package:budgetly/core/import_to_export.dart';

abstract class BudgetRepository {
  Future<List<MonthBudget>> getBudgets(int year);
  Future<MonthBudget?> getBudgetForMonth(int year, int month);
  Future<void> addBudget(Map<String, dynamic> budgetData);
  Future<void> updateBudget(String id, int value);
  Future<void> deleteUserBudgets();
}

class FirebaseBudgetRepository implements BudgetRepository {
  @override
  Future<List<MonthBudget>> getBudgets(int year) {
    return FirebaseHelper.getBudgets(year);
  }

  @override
  Future<MonthBudget?> getBudgetForMonth(int year, int month) {
    return FirebaseHelper.getBudgetForMonth(year, month);
  }

  @override
  Future<void> addBudget(Map<String, dynamic> budgetData) {
    return FirebaseHelper.addBudget(budgetData);
  }

  @override
  Future<void> updateBudget(String id, int value) {
    return FirebaseHelper.updateBudget(id, value);
  }

  @override
  Future<void> deleteUserBudgets() {
    return FirebaseHelper.deleteUserBudgets();
  }
}

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return FirebaseBudgetRepository();
});
