import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class MonthInfo {
  final int year;
  final int month;
  final String label;
  final List<Expense> expenses;

  MonthInfo({required this.year, required this.month, required this.label, required this.expenses});
}

// ─── Asynchronous Data Providers ─────────────────────────────────────────────

/// Fetches all transactions, groups them by month/year, and sorts them.
final pdfMonthsProvider = FutureProvider.autoDispose<List<MonthInfo>>((ref) async {
  final allExpenses = await FirebaseHelper.getYearsWithExpenses();

  // Group expenses by year and month
  final Map<String, List<Expense>> grouped = {};
  for (final expense in allExpenses) {
    final key = '${expense.date.year}-${expense.date.month}';
    if (!grouped.containsKey(key)) {
      grouped[key] = [];
    }
    grouped[key]!.add(expense);
  }

  // Map to MonthInfo objects
  final List<MonthInfo> list = [];
  grouped.forEach((key, listExpenses) {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final label = DateFormat('MMMM yyyy').format(DateTime(year, month));
    list.add(MonthInfo(year: year, month: month, label: label, expenses: listExpenses));
  });

  // Sort months (newest first)
  list.sort((a, b) {
    if (a.year != b.year) {
      return b.year.compareTo(a.year);
    }
    return b.month.compareTo(a.month);
  });

  return list;
});

// ─── Local UI State Providers ────────────────────────────────────────────────

final pdfIncludeCategoryProvider = StateProvider.autoDispose<bool>((ref) => true);
final pdfIncludeTxListProvider = StateProvider.autoDispose<bool>((ref) => true);
final pdfIsExportingProvider = StateProvider.autoDispose<bool>((ref) => false);

// ─── PDF Export Action Controller ────────────────────────────────────────────

final pdfExportControllerProvider = Provider.autoDispose<PdfExportController>((ref) {
  return PdfExportController(ref);
});

class PdfExportController {
  final Ref ref;
  PdfExportController(this.ref);

  void exportToPdf(MonthInfo monthInfo) {
    HapticFeedback.lightImpact();

    bottomSheet(
      StatefulBuilder(
        builder: (context, setBottomSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Export PDF', style: serifText(24)),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.black),
                      onPressed: appRouter.pop,
                    ),
                  ],
                ),
                Text(
                  'Customize the report PDF for ${monthInfo.label}. You can choose which sections to include.',
                  style: regularText(14, color: AppColors.grey),
                ),
                const SizedBox(height: 12),
                _buildToggleRow(
                  title: 'Category Breakdown',
                  subtitle: 'Summary and progress bar of category spending',
                  icon: HugeIcons.strokeRoundedBarChartHorizontal,
                  value: ref.read(pdfIncludeCategoryProvider),
                  onChanged: (val) {
                    ref.read(pdfIncludeCategoryProvider.notifier).state = val;
                    setBottomSheetState(() {});
                  },
                ),
                const SizedBox(height: 16),
                _buildToggleRow(
                  title: 'Transaction List',
                  subtitle: 'Detailed list of all expenses with date and amount',
                  icon: HugeIcons.strokeRoundedLeftToRightListDash,
                  value: ref.read(pdfIncludeTxListProvider),
                  onChanged: (val) {
                    ref.read(pdfIncludeTxListProvider.notifier).state = val;
                    setBottomSheetState(() {});
                  },
                ),
                const SizedBox(height: 20),
                Button(
                  onClick: () {
                    final includeCat = ref.read(pdfIncludeCategoryProvider);
                    final includeTx = ref.read(pdfIncludeTxListProvider);

                    if (!includeCat && !includeTx) {
                      errorSnackbar('Please select at least one option');
                      return;
                    }
                    appRouter.pop();
                    _generatePdf(monthInfo);
                  },
                  child: Text('Generate Report', style: semiBoldText(16, color: AppColors.white)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
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
          Transform.scale(
            scale: 0.8,
            alignment: Alignment.centerRight,
            child: CupertinoSwitch(
              value: value,
              activeTrackColor: AppColors.brand,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf(MonthInfo monthInfo) async {
    if (ref.read(pdfIsExportingProvider)) return;
    ref.read(pdfIsExportingProvider.notifier).state = true;

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

      // Fetch categories
      final categoriesList = await ref.read(categoriesProvider.future);

      // Fetch budget for selected month
      double budgetVal = 0.0;
      final budgetObj = await FirebaseHelper.getBudgetForMonth(monthInfo.year, monthInfo.month);
      if (budgetObj != null) {
        budgetVal = budgetObj.budget.toDouble();
      }

      final filePath = await PdfExportService.exportMonthlyReport(
        expenses: monthInfo.expenses,
        month: monthInfo.month,
        year: monthInfo.year,
        userName: user?.displayName ?? user?.email ?? 'User',
        budget: budgetVal,
        categoryNames: {for (final cat in categoriesList) cat.id: cat.name},
        includeCategoryBreakdown: ref.read(pdfIncludeCategoryProvider),
        includeTransactions: ref.read(pdfIncludeTxListProvider),
      );

      if (isDialogOpen) {
        appRouter.pop();
      }

      // Reset options
      ref.read(pdfIncludeCategoryProvider.notifier).state = true;
      ref.read(pdfIncludeTxListProvider.notifier).state = true;

      await OpenFilex.open(filePath);
    } catch (e) {
      if (isDialogOpen) {
        appRouter.pop();
      }
      errorSnackbar('Export Failed');
    } finally {
      ref.read(pdfIsExportingProvider.notifier).state = false;
    }
  }
}
