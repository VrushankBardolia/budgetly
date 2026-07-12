import 'package:budgetly/core/import_to_export.dart';

final selectedDashboardYearProvider = StateProvider<int>((ref) => DateTime.now().year);

final donutCenterTextProvider = StateProvider<String>((ref) => '');

final expensesProvider = FutureProvider.family<List<Expense>, int>((ref, year) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpensesInRange(DateTime(year, 1, 1), DateTime(year, 12, 31, 23, 59, 59));
});

final availableYearsProvider = FutureProvider<List<int>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final results = await repo.getExpensesInRange(DateTime(2000), DateTime(2100));
  if (results.isEmpty) return [DateTime.now().year];
  final years = results.map((e) => e.date.year).toSet().toList()..sort((a, b) => b.compareTo(a));
  return years.isEmpty ? [DateTime.now().year] : years;
});

final totalSheetsBalanceProvider = FutureProvider<double>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  try {
    return await repo.getTotalSheetsBalance();
  } catch (_) {
    return 0.0;
  }
});

final dashboardStateProvider = Provider<AsyncValue<DashboardState>>((ref) {
  final selectedYear = ref.watch(selectedDashboardYearProvider);
  final donutCenterText = ref.watch(donutCenterTextProvider);

  final asyncValues = [
    ref.watch(categoriesProvider),
    ref.watch(expensesProvider(selectedYear)),
    ref.watch(availableYearsProvider),
    ref.watch(totalSheetsBalanceProvider),
  ];

  // Bail out on the first loading/error state — same behavior as before,
  // but without four repeated if-blocks.
  for (final value in asyncValues) {
    if (value.isLoading) return const AsyncValue.loading();
    if (value.hasError) return AsyncValue.error(value.error!, value.stackTrace!);
  }

  return AsyncValue.data(
    DashboardState(
      selectedYear: selectedYear,
      availableYears: (asyncValues[2] as AsyncValue<List<int>>).value ?? [DateTime.now().year],
      expenses: (asyncValues[1] as AsyncValue<List<Expense>>).value ?? [],
      categories: (asyncValues[0] as AsyncValue<List<Category>>).value ?? [],
      totalSheetsBalance: (asyncValues[3] as AsyncValue<double>).value ?? 0.0,
      donutCenterText: donutCenterText,
    ),
  );
});
