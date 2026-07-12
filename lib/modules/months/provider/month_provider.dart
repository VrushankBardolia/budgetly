import 'package:budgetly/core/import_to_export.dart';

final selectedMonthYearProvider = StateProvider<int>((ref) => DateTime.now().year);

final budgetsProvider = FutureProvider.family<List<MonthBudget>, int>((ref, year) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getBudgets(year);
});

final monthStateProvider = Provider<AsyncValue<MonthState>>((ref) {
  final year = ref.watch(selectedMonthYearProvider);

  final asyncValues = [
    ref.watch(expensesProvider(year)),
    ref.watch(budgetsProvider(year)),
  ];

  for (final value in asyncValues) {
    if (value.isLoading) return const AsyncValue.loading();
    if (value.hasError) return AsyncValue.error(value.error!, value.stackTrace!);
  }

  return AsyncValue.data(
    MonthState(
      selectedYear: year,
      expenses: (asyncValues[0] as AsyncValue<List<Expense>>).value ?? [],
      budgets: (asyncValues[1] as AsyncValue<List<MonthBudget>>).value ?? [],
    ),
  );
});
