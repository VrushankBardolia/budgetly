import 'package:budgetly/core/import_to_export.dart';

/// Fetches expenses by category in a cached FutureProvider.
final categoryExpensesProvider = FutureProvider.family.autoDispose<List<Expense>, String>((ref, categoryId) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpensesByCategory(categoryId);
});

/// Combires the given Category and its category expenses into CategoryDetailsState.
final categoryDetailsStateProvider = Provider.family.autoDispose<AsyncValue<CategoryDetailsState>, Category>((ref, category) {
  final expensesAsync = ref.watch(categoryExpensesProvider(category.id));

  return expensesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
    data: (expenses) => AsyncValue.data(CategoryDetailsState(
      category: category,
      expenses: expenses,
    )),
  );
});
