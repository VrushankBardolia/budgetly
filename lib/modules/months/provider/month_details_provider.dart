import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class MonthDetailProvider extends ChangeNotifier {
  final Ref ref;

  // ─── Arguments via constructor ───────────────────────────────────────────────────
  final int year;
  final int month;

  // ─── State ───────────────────────────────────────────────────────
  List<Expense> expenses = [];
  List<Category> categories = [];
  int budget = 0;
  int selectedCategoryTotal = 0;
  bool isLoading = true;
  bool isExporting = false;
  bool includeCategory = true;
  bool includeTxList = true;

  // ─── Sort ────────────────────────────────────────────────────────────
  final List sortOptions = [
    'Date (Newest first)',
    'Date (Oldest first)',
    'Amount (High to Low)',
    'Amount (Low to High)',
  ];
  String selectedSortOption = 'Date (Newest first)';

  // ─── Filter ────────────────────────────────────────────────────────────
  List<String> filterOptions = ['All'];
  String selectedFilterOption = 'All';

  List<Expense> _allExpenses = [];
  String selectedFilterCategoryId = 'All';

  MonthDetailProvider(this.ref, Map args)
    : year = args['year'] ?? DateTime.now().year,
      month = args['month'] ?? DateTime.now().month {
    loadAll();
  }

  // ─── Budget Dialog ────────────────────────────────────────────────────────

  void _checkBudgetAndShowDialog() {
    if (!isLoading && !hasBudget) {
      showBudgetDialog();
    }
  }

  Future<void> showBudgetDialog() async {
    final budgetField = TextEditingController(text: budget > 0 ? budget.toString() : '');

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
            Text(formattedMonth, style: regularText(14, color: AppColors.grey)),
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

  // ─── Navigation to Expense Screen ─────────────────────────────────────────

  Future<void> goToAddExpense() async {
    final result = await appRouter.pushNamed(
      Routes.EXPENSE_FORM,
      extra: {'year': year, 'month': month},
    );
    if (result == true) await loadExpenses();
  }

  Future<void> goToEditExpense(Expense expense) async {
    final result = await appRouter.pushNamed(
      Routes.EXPENSE_FORM,
      extra: {'year': year, 'month': month, 'expense': expense},
    );
    if (result == true) await loadExpenses();
  }

  // ─── Delete Dialog ────────────────────────────────────────────────────────

  Future<void> showDeleteExpenseDialog(String id) async {
    final confirmed = await confirmationDialog(
      title: 'Delete Expense',
      message: 'Are you sure you want to delete this expense?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed) await deleteExpense(id);
  }

  // ─── Data Loading ─────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    isLoading = true;
    notifyListeners();
    await Future.wait([loadExpenses(), loadBudget(), loadCategories()]);
    isLoading = false;
    notifyListeners();
    _checkBudgetAndShowDialog();
  }

  Future<void> loadExpenses() async {
    final result = await FirebaseHelper.getExpenses(
      DateTime(year, month, 1),
      DateTime(year, month + 1, 0, 23, 59, 59),
    );
    _allExpenses = result;
    applyFiltersAndSorts();
  }

  Future<void> loadBudget() async {
    final result = await FirebaseHelper.getBudgetForMonth(year, month);
    if (result != null) {
      budget = result.budget.toInt();
    }
    notifyListeners();
  }

  Future<void> loadCategories() async {
    final result = await FirebaseHelper.getCategories();
    categories = result;
    notifyListeners();
  }

  // ─── Budget CRUD ──────────────────────────────────────────────────────────

  Future<void> setBudget(int value) async {
    final result = await FirebaseHelper.getBudgetForMonth(year, month);
    if (result == null) {
      await FirebaseHelper.addBudget({
        'userId': PreferenceHelper.userId,
        'year': year,
        'month': month,
        'budget': value,
      });
    } else {
      await FirebaseHelper.updateBudget(result.id, value);
    }
    budget = value;
    notifyListeners();
  }

  // ─── Expense CRUD ─────────────────────────────────────────────────────────

  Future<void> deleteExpense(String id) async {
    await FirebaseHelper.deleteExpense(id);
    await loadExpenses();
  }

  // ─── Category Helper ──────────────────────────────────────────────────────

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Sorting ────────────────────────────────────────────────────────

  void showSortDialog() {
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
                bool isSelected = option == selectedSortOption;
                return GestureDetector(
                  onTap: () {
                    onSortOptionSelected(option);
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

  void onSortOptionSelected(String option) {
    selectedSortOption = option;
    appRouter.pop();
    applyFiltersAndSorts();
  }

  // ─── Filter ────────────────────────────────────────────────────────────

  void showCategoryFilterDialog() {
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
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              final activeCategoryIds = _allExpenses.map((e) => e.categoryId).toSet();
              final activeCategories = categories
                  .where((c) => activeCategoryIds.contains(c.id))
                  .toList();
              final options = [null, ...activeCategories];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((category) {
                  final String id = category?.id ?? 'All';
                  final String name = category?.name ?? 'All';
                  bool isSelected = selectedFilterCategoryId == id;

                  return GestureDetector(
                    onTap: () {
                      onCategorySelected(id, name);
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

  void onCategorySelected(String categoryId, String categoryName) {
    selectedFilterCategoryId = categoryId;
    selectedFilterOption = categoryName;
    appRouter.pop();
    applyFiltersAndSorts();
  }

  void applyFiltersAndSorts() {
    List<Expense> result = _allExpenses.toList();

    // 1. Filter
    if (selectedFilterCategoryId != 'All') {
      result = result.where((e) => e.categoryId == selectedFilterCategoryId).toList();
      selectedCategoryTotal = result.fold(0, (total, item) => total + item.price.toInt());
    } else {
      selectedCategoryTotal = 0;
    }

    // 2. Sort
    switch (selectedSortOption) {
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

    expenses = result;
    notifyListeners();
  }

  void exportToPdf() {
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
                  value: includeCategory,
                  onChanged: (val) {
                    setBottomSheetState(() {
                      includeCategory = val;
                    });
                    notifyListeners();
                  },
                ),
                const SizedBox(height: 16),
                _buildToggleRow(
                  title: 'Transaction List',
                  subtitle: 'Detailed list of all expenses with date and amount',
                  icon: HugeIcons.strokeRoundedLeftToRightListDash,
                  value: includeTxList,
                  onChanged: (val) {
                    setBottomSheetState(() {
                      includeTxList = val;
                    });
                    notifyListeners();
                  },
                ),
                const SizedBox(height: 32),
                Button(
                  onClick: () {
                    if (!includeCategory && !includeTxList) {
                      warningSnackbar('Please select at least one option');
                      return;
                    }
                    appRouter.pop();
                    _generatePdf();
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

  Future<void> _generatePdf() async {
    if (isExporting) return;
    isExporting = true;
    notifyListeners();

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
      final filePath = await PdfExportService.exportMonthlyReport(
        expenses: expenses,
        month: month,
        year: year,
        userName: user?.displayName ?? user?.email ?? 'User',
        budget: budget.toDouble(),
        categoryNames: {for (final cat in categories) cat.id: cat.name},
        includeCategoryBreakdown: includeCategory,
        includeTransactions: includeTxList,
      );

      if (isDialogOpen) {
        appRouter.pop();
      }

      includeCategory = true;
      includeTxList = true;

      await OpenFilex.open(filePath);
    } catch (e) {
      if (isDialogOpen) {
        appRouter.pop();
      }
      errorSnackbar('Export Failed. Please try again.');
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }

  // ─── Derived Getters ──────────────────────────────────────────────────────

  double get totalExpense => _allExpenses.fold(0.0, (total, e) => total + e.price);
  double get filteredExpenseTotal => expenses.fold(0.0, (total, e) => total + e.price);
  double get remaining => budget - totalExpense;
  int get totalDays => DateTime(year, month + 1, 0).day;

  int get remainingDays {
    final diff = totalDays - DateTime.now().day + 1;
    return diff > 0 ? diff : 0;
  }

  double get remainPerDay => remainingDays > 0 ? remaining / remainingDays : 0.0;
  bool get hasBudget => budget > 0;

  bool get isCurrent {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isBalanced => remaining == 0;
  bool get isSaved => remaining > 0;

  Color get statusColor {
    if (isBalanced) return AppColors.warning;
    if (isSaved) return AppColors.success;
    return AppColors.error;
  }

  String get statusLabel {
    if (isBalanced) return 'On Target';
    if (isSaved) return isCurrent ? 'Remaining' : 'Saved';
    return 'Overspent';
  }

  dynamic get statusIcon {
    if (isBalanced) return HugeIcons.strokeRoundedAlert02;
    if (isSaved) return HugeIcons.strokeRoundedCheckmarkCircle03;
    return HugeIcons.strokeRoundedCancelCircle;
  }

  String get formattedMonth => DateFormat('MMMM yyyy').format(DateTime(year, month));
  NumberFormat get formatter => NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
}
