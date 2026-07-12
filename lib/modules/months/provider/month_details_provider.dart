import 'package:budgetly/core/import_to_export.dart';

// ─── Local UI State Providers ────────────────────────────────────────────────

final monthDetailSortOptionProvider = StateProvider.family.autoDispose<String, Map>((ref, args) {
  return 'Date (Newest first)';
});

final monthDetailFilterCategoryIdProvider = StateProvider.family.autoDispose<String, Map>((
  ref,
  args,
) {
  return 'All';
});

final monthDetailIncludeCategoryProvider = StateProvider.family.autoDispose<bool, Map>((ref, args) {
  return true;
});

final monthDetailIncludeTxListProvider = StateProvider.family.autoDispose<bool, Map>((ref, args) {
  return true;
});

final monthDetailIsExportingProvider = StateProvider.family.autoDispose<bool, Map>((ref, args) {
  return false;
});

// ─── Asynchronous Raw Providers ──────────────────────────────────────────────

final monthDetailExpensesRawProvider = FutureProvider.family.autoDispose<List<Expense>, Map>((
  ref,
  args,
) async {
  final int year = args['year'] ?? DateTime.now().year;
  final int month = args['month'] ?? DateTime.now().month;
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpensesInRange(
    DateTime(year, month, 1),
    DateTime(year, month + 1, 0, 23, 59, 59),
  );
});

final monthDetailBudgetRawProvider = FutureProvider.family.autoDispose<int, Map>((ref, args) async {
  final int year = args['year'] ?? DateTime.now().year;
  final int month = args['month'] ?? DateTime.now().month;
  final repo = ref.watch(budgetRepositoryProvider);
  final result = await repo.getBudgetForMonth(year, month);
  return result?.budget.toInt() ?? 0;
});

// ─── Combined State Provider ─────────────────────────────────────────────────

final monthDetailStateProvider = Provider.family.autoDispose<AsyncValue<MonthDetailState>, Map>((
  ref,
  args,
) {
  final int year = args['year'] ?? DateTime.now().year;
  final int month = args['month'] ?? DateTime.now().month;

  final asyncValues = [
    ref.watch(monthDetailExpensesRawProvider(args)),
    ref.watch(monthDetailBudgetRawProvider(args)),
    ref.watch(categoriesProvider),
  ];

  for (final value in asyncValues) {
    if (value.isLoading) return const AsyncValue.loading();
    if (value.hasError) return AsyncValue.error(value.error!, value.stackTrace!);
  }

  final allExpenses = (asyncValues[0] as AsyncValue<List<Expense>>).value ?? [];
  final budget = (asyncValues[1] as AsyncValue<int>).value ?? 0;
  final categories = (asyncValues[2] as AsyncValue<List<Category>>).value ?? [];

  final sortOption = ref.watch(monthDetailSortOptionProvider(args));
  final filterCategoryId = ref.watch(monthDetailFilterCategoryIdProvider(args));
  final includeCategory = ref.watch(monthDetailIncludeCategoryProvider(args));
  final includeTxList = ref.watch(monthDetailIncludeTxListProvider(args));
  final isExporting = ref.watch(monthDetailIsExportingProvider(args));

  List<Expense> result = allExpenses.toList();
  String selectedFilterOptionName = 'All';

  if (filterCategoryId != 'All') {
    result = result.where((e) => e.categoryId == filterCategoryId).toList();
    final cat = categories.where((c) => c.id == filterCategoryId).firstOrNull;
    selectedFilterOptionName = cat?.name ?? 'Unknown';
  }

  switch (sortOption) {
    case 'Date (Newest first)':
      result.sort((a, b) => b.date.compareTo(a.date));
      break;
    case 'Date (Oldest first)':
      result.sort((a, b) => a.date.compareTo(b.date));
      break;
    case 'Amount (High to Low)':
      result.sort((a, b) => b.price.compareTo(a.price));
      break;
    case 'Amount (Low to High)':
      result.sort((a, b) => a.price.compareTo(b.price));
      break;
  }

  return AsyncValue.data(
    MonthDetailState(
      year: year,
      month: month,
      allExpenses: allExpenses,
      filteredExpenses: result,
      categories: categories,
      budget: budget,
      selectedSortOption: sortOption,
      selectedFilterCategoryId: filterCategoryId,
      selectedFilterOptionName: selectedFilterOptionName,
      includeCategory: includeCategory,
      includeTxList: includeTxList,
      isExporting: isExporting,
    ),
  );
});

// ─── Month Detail Action Controller ──────────────────────────────────────────

final monthDetailControllerProvider = Provider.family.autoDispose<MonthDetailController, Map>((
  ref,
  args,
) {
  return MonthDetailController(ref, args);
});

class MonthDetailController {
  final Ref ref;
  final Map args;
  final int year;
  final int month;

  MonthDetailController(this.ref, this.args)
    : year = args['year'] ?? DateTime.now().year,
      month = args['month'] ?? DateTime.now().month;

  // ─── Budget Dialog / CRUD ──────────────────────────────────────────────────

  void checkBudgetAndShowDialog(MonthDetailState state) {
    if (!state.hasBudget) {
      showBudgetDialog(state);
    }
  }

  Future<void> showBudgetDialog(MonthDetailState state) async {
    final budgetField = TextEditingController(
      text: state.budget > 0 ? state.budget.toString() : '',
    );

    dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Set Budget',
          textAlign: TextAlign.center,
          style: boldText(14, color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.formattedMonth, style: regularText(14, color: AppColors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: budgetField,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: regularText(14),
              decoration: InputDecoration(
                hintStyle: regularText(14, color: Colors.grey.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppColors.surfaceLight,
                prefixText: '₹',
                hintText: 'Enter amount',
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.brand, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: appRouter.pop,
            child: Text(
              budgetField.text.isEmpty ? 'Skip' : 'Cancel',
              style: regularText(14, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(budgetField.text);
              if (value != null && value > 0) {
                await setBudget(value);
                appRouter.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brand,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: boldText(14)),
          ),
        ],
      ),
    );
  }

  Future<void> setBudget(int value) async {
    final budgetRepo = ref.read(budgetRepositoryProvider);
    final result = await budgetRepo.getBudgetForMonth(year, month);
    if (result == null) {
      await budgetRepo.addBudget({
        'userId': PreferenceHelper.userId,
        'year': year,
        'month': month,
        'budget': value,
      });
    } else {
      await budgetRepo.updateBudget(result.id, value);
    }
    ref.invalidate(monthDetailBudgetRawProvider(args));
    ref.invalidate(budgetsProvider(year));
    WidgetHelper.updateRemainingBudgetWidget();
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  Future<void> goToAddExpense() async {
    final result = await appRouter.pushNamed(
      Routes.EXPENSE_FORM,
      extra: {'year': year, 'month': month},
    );
    if (result == true) {
      ref.invalidate(monthDetailExpensesRawProvider(args));
      ref.invalidate(expensesProvider(year));
      ref.invalidate(availableYearsProvider);
    }
  }

  Future<void> goToEditExpense(Expense expense) async {
    final result = await appRouter.pushNamed(
      Routes.EXPENSE_FORM,
      extra: {'year': year, 'month': month, 'expense': expense},
    );
    if (result == true) {
      ref.invalidate(monthDetailExpensesRawProvider(args));
      ref.invalidate(expensesProvider(year));
      ref.invalidate(availableYearsProvider);
    }
  }

  // ─── Delete Expense ────────────────────────────────────────────────────────

  Future<void> showDeleteExpenseDialog(String id) async {
    final confirmed = await confirmationDialog(
      title: 'Delete Expense',
      message: 'Are you sure you want to delete this expense?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) {
      final expenseRepo = ref.read(expenseRepositoryProvider);
      await expenseRepo.deleteExpense(id);
      ref.invalidate(monthDetailExpensesRawProvider(args));
      ref.invalidate(expensesProvider(year));
      ref.invalidate(availableYearsProvider);
    }
  }

  // ─── Sort and Filter dialogs ───────────────────────────────────────────────

  void showSortDialog(MonthDetailState state, List sortOptions) {
    dialog(
      StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Center(child: Text('Sort by', style: semiBoldText(20))),
          titlePadding: const EdgeInsets.only(top: 16, bottom: 0),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: sortOptions.map((option) {
                bool isSelected = option == state.selectedSortOption;
                return GestureDetector(
                  onTap: () {
                    ref.read(monthDetailSortOptionProvider(args).notifier).state = option;
                    appRouter.pop();
                  },
                  child: AnimatedContainer(
                    margin: const EdgeInsets.only(top: 12),
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandDark.withValues(alpha: 0.2)
                          : AppColors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.brand : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          option,
                          style: isSelected
                              ? semiBoldText(15, color: AppColors.brand)
                              : regularText(15),
                        ),
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: const HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                            size: 22,
                            color: AppColors.brand,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void showCategoryFilterDialog(MonthDetailState state) {
    dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Center(child: Text('Filter by Category', style: semiBoldText(20))),
        titlePadding: const EdgeInsets.only(top: 16, bottom: 0),
        content: SizedBox(
          width: appContext != null ? MediaQuery.of(appContext!).size.width : 300,
          child: Builder(
            builder: (context) {
              final activeCategoryIds = state.allExpenses.map((e) => e.categoryId).toSet();
              final activeCategories = state.categories
                  .where((c) => activeCategoryIds.contains(c.id))
                  .toList();
              final options = [null, ...activeCategories];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((category) {
                  final String id = category?.id ?? 'All';
                  final String name = category?.name ?? 'All';
                  bool isSelected = state.selectedFilterCategoryId == id;

                  return GestureDetector(
                    onTap: () {
                      ref.read(monthDetailFilterCategoryIdProvider(args).notifier).state = id;
                      appRouter.pop();
                    },
                    child: AnimatedContainer(
                      margin: const EdgeInsets.only(top: 12),
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandDark.withValues(alpha: 0.1)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: isSelected
                                ? semiBoldText(15, color: AppColors.brand)
                                : regularText(15),
                          ),
                          AnimatedScale(
                            scale: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                              size: 22,
                              color: AppColors.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── PDF Report Generation ─────────────────────────────────────────────────

  void exportToPdf(MonthDetailState state) {
    HapticFeedback.lightImpact();

    bottomSheet(
      StatefulBuilder(
        builder: (context, setBottomSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Export PDF', style: boldText(20)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: appRouter.pop,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your monthly report PDF. You can choose which sections to include in the exported document.',
                  style: regularText(14, color: AppColors.grey),
                ),
                const SizedBox(height: 24),
                _buildToggleRow(
                  title: 'Category Breakdown',
                  subtitle: 'Summary and progress bar of category spending',
                  icon: HugeIcons.strokeRoundedBarChartHorizontal,
                  value: state.includeCategory,
                  onChanged: (val) {
                    ref.read(monthDetailIncludeCategoryProvider(args).notifier).state = val;
                    setBottomSheetState(() {});
                  },
                ),
                const SizedBox(height: 16),
                _buildToggleRow(
                  title: 'Transaction List',
                  subtitle: 'Detailed list of all expenses with date and amount',
                  icon: HugeIcons.strokeRoundedLeftToRightListDash,
                  value: state.includeTxList,
                  onChanged: (val) {
                    ref.read(monthDetailIncludeTxListProvider(args).notifier).state = val;
                    setBottomSheetState(() {});
                  },
                ),
                const SizedBox(height: 32),
                Button(
                  onClick: () {
                    if (!state.includeCategory && !state.includeTxList) {
                      warningSnackbar('Please select at least one option');
                      return;
                    }
                    appRouter.pop();
                    _generatePdf(state);
                  },
                  child: Text('Generate Report', style: semiBoldText(16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required dynamic icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          HugeIcon(icon: icon, color: value ? AppColors.brand : AppColors.grey, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: boldText(14)),
                Text(subtitle, style: regularText(12, color: AppColors.grey)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.brand,
            activeTrackColor: AppColors.surface,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(MonthDetailState state) async {
    ref.read(monthDetailIsExportingProvider(args).notifier).state = true;

    dialog(
      Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.brand),
              const SizedBox(height: 20),
              Text('Exporting PDF...', style: boldText(16), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      final user = FirebaseHelper.currentUser;
      final categoriesList = await ref.read(categoriesProvider.future);

      final filePath = await PdfExportService.exportMonthlyReport(
        expenses: state.filteredExpenses,
        month: month,
        year: year,
        userName: user?.displayName ?? user?.email ?? 'User',
        budget: state.budget.toDouble(),
        categoryNames: {for (final cat in categoriesList) cat.id: cat.name},
        includeCategoryBreakdown: state.includeCategory,
        includeTransactions: state.includeTxList,
      );

      if (isDialogOpen) {
        appRouter.pop();
      }

      // Reset PDF export options
      ref.read(monthDetailIncludeCategoryProvider(args).notifier).state = true;
      ref.read(monthDetailIncludeTxListProvider(args).notifier).state = true;

      await OpenFilex.open(filePath);
    } catch (e) {
      if (isDialogOpen) {
        appRouter.pop();
      }
      errorSnackbar('Export Failed. Please try again.');
    } finally {
      ref.read(monthDetailIsExportingProvider(args).notifier).state = false;
    }
  }
}
