import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class MonthInfo {
  final int year;
  final int month;
  final String label;
  final List<Expense> expenses;

  MonthInfo({required this.year, required this.month, required this.label, required this.expenses});
}

class ExportPdfProvider extends ChangeNotifier {
  final Ref ref;

  bool isLoading = false;
  bool isExporting = false;
  List<MonthInfo> months = [];
  List<Category> categories = [];

  // Toggle states for PDF layout configurations
  bool includeCategory = true;
  bool includeTxList = true;

  final NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

  ExportPdfProvider(this.ref) {
    loadMonths();
  }

  Future<void> loadMonths() async {
    isLoading = true;
    notifyListeners();
    try {
      final allExpenses = await FirebaseHelper.getYearsWithExpenses();
      final fetchedCategories = await FirebaseHelper.getCategories();
      categories = fetchedCategories;

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

      months = list;
    } catch (e) {
      errorSnackbar('Failed to load months data.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void exportToPdf(MonthInfo monthInfo) {
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
                  'Customize the report PDF for ${monthInfo.label}. You can choose which sections to include.',
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
                      errorSnackbar('Please select at least one option');
                      return;
                    }
                    appRouter.pop();
                    _generatePdf(monthInfo);
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

  Future<void> _generatePdf(MonthInfo monthInfo) async {
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
      errorSnackbar('Export Failed');
    } finally {
      isExporting = false;
      notifyListeners();
    }
  }
}
