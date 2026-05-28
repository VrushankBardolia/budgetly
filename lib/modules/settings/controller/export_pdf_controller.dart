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

class ExportPdfController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isExporting = false.obs;
  final RxList<MonthInfo> months = <MonthInfo>[].obs;
  final RxList<Category> categories = <Category>[].obs;

  // Toggle states for PDF layout configurations
  final RxBool includeCategory = true.obs;
  final RxBool includeTxList = true.obs;

  final NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

  @override
  void onInit() {
    super.onInit();
    loadMonths();
  }

  Future<void> loadMonths() async {
    isLoading.value = true;
    try {
      final allExpenses = await FirebaseHelper.getYearsWithExpenses();
      final fetchedCategories = await FirebaseHelper.getCategories();
      categories.assignAll(fetchedCategories);

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

      months.assignAll(list);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load months data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void exportToPdf(MonthInfo monthInfo) {
    HapticFeedback.lightImpact();

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      SafeArea(
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
                    onPressed: Get.back,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Customize the report PDF for ${monthInfo.label}. You can choose which sections to include.',
                style: regularText(14, color: AppColors.grey),
              ),
              const SizedBox(height: 24),
              Obx(
                () => _buildToggleRow(
                  title: 'Category Breakdown',
                  subtitle: 'Summary and progress bar of category spending',
                  icon: HugeIcons.strokeRoundedBarChartHorizontal,
                  value: includeCategory.value,
                  onChanged: (val) => includeCategory.value = val,
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildToggleRow(
                  title: 'Transaction List',
                  subtitle: 'Detailed list of all expenses with date and amount',
                  icon: HugeIcons.strokeRoundedLeftToRightListDash,
                  value: includeTxList.value,
                  onChanged: (val) => includeTxList.value = val,
                ),
              ),
              const SizedBox(height: 32),
              Button(
                onClick: () {
                  if (!includeCategory.value && !includeTxList.value) {
                    Get.snackbar(
                      'Select Options',
                      'Please select at least one option',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.error.withValues(alpha: 0.1),
                      colorText: AppColors.error,
                      icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.error),
                    );
                    return;
                  }
                  Get.back();
                  _generatePdf(monthInfo);
                },
                child: Text('Generate Report', style: semiBoldText(16, color: Colors.white)),
              ),
            ],
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
    if (isExporting.value) return;
    isExporting.value = true;

    Get.dialog(
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
        includeCategoryBreakdown: includeCategory.value,
        includeTransactions: includeTxList.value,
      );

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      includeCategory.value = true;
      includeTxList.value = true;

      await OpenFilex.open(filePath);
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        'Export Failed',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        icon: const Icon(CupertinoIcons.xmark_circle_fill, color: AppColors.error),
        margin: const EdgeInsets.all(16),
        borderRadius: 14,
      );
    } finally {
      isExporting.value = false;
    }
  }
}
