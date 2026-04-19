import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class SheetDetailsScreen extends GetView<SheetDetailsController> {
  const SheetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: Get.back,
        ),
        title: Text(controller.sheetName, style: boldText(20)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToAddRecord,
        backgroundColor: AppColors.brandDark,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add Record', style: semiBoldText(14, color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadRecords(isRefresh: true),
          color: AppColors.brand,
          backgroundColor: AppColors.surface,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // ── Summary Cards ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: buildSummaryCard(
                              label: 'Total Income',
                              amount: controller.totalIncome,
                              color: AppColors.success,
                              icon: Icons.arrow_downward_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: buildSummaryCard(
                              label: 'Total Expense',
                              amount: controller.totalExpense,
                              color: AppColors.error,
                              icon: Icons.arrow_upward_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      buildBalanceCard(
                        balance: controller.netBalance,
                        isProfit: controller.isProfit,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Filter Bar ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: buildFilterBar(),
                ),
              ),

              // ── Records Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Records', style: semiBoldText(13, color: AppColors.grey)),
                      Text(
                        '${controller.filteredRecords.length}',
                        style: semiBoldText(13, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Record List ─────────────────────────────────────────
              controller.filteredRecords.isEmpty ? buildEmptyState() : buildRecordList(),
            ],
          ),
        );
      }),
    );
  }

  // ─── Summary Card ─────────────────────────────────────────────────────────────
  Widget buildSummaryCard({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: regularText(12, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(fmt.format(amount), style: boldText(20, color: color)),
        ],
      ),
    );
  }

  // ─── Net Balance Card ─────────────────────────────────────────────────────────
  Widget buildBalanceCard({required double balance, required bool isProfit}) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final color = isProfit ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Net Balance', style: regularText(12, color: AppColors.grey)),
              const SizedBox(height: 2),
              Text(
                isProfit ? 'You\'re in profit 🎉' : 'You\'re overspending',
                style: GoogleFonts.plusJakartaSans(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(fmt.format(balance), style: customText(22, FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget buildFilterBar() {
    return Obx(() {
      final filters = [('all', 'All'), ('income', 'Income'), ('expense', 'Expense')];

      return Row(
        children: filters.map((f) {
          final isActive = controller.filterType.value == f.$1;
          final color = f.$1 == 'income'
              ? AppColors.success
              : f.$1 == 'expense'
              ? AppColors.error
              : AppColors.brand;

          return GestureDetector(
            onTap: () => controller.setFilter(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? color.withValues(alpha: 0.15) : AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isActive
                      ? color.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                f.$2,
                style: GoogleFonts.plusJakartaSans(
                  color: isActive ? color : Colors.grey[400],
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Text('No records found', style: semiBoldText(14, color: AppColors.grey)),
      ),
    );
  }

  Widget buildRecordList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, index) {
        final record = controller.filteredRecords[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: buildRecordTile(record),
        );
      }, childCount: controller.filteredRecords.length),
    );
  }

  Widget buildRecordTile(SheetRecord record) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final color = record.isIncome ? AppColors.success : AppColors.error;
    final sign = record.isIncome ? '+' : '-';
    final date = DateFormat('dd').format(record.date);
    final month = DateFormat('MMM').format(record.date);

    return GestureDetector(
      onTap: () => controller.goToEditRecord(record),
      onLongPress: () {
        HapticFeedback.heavyImpact();
        controller.showDeleteDialog(record.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(date, style: boldText(14)),
                  Text(month, style: regularText(12)),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Detail + Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.detail.isEmpty
                        ? (record.isIncome ? 'Income' : 'Expense')
                        : record.detail,
                    style: mediumText(14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.isIncome ? 'Income' : 'Expense',
                    style: semiBoldText(12, color: color),
                  ),
                ],
              ),
            ),

            // Amount
            Text('$sign${fmt.format(record.amount)}', style: boldText(15, color: color)),
          ],
        ),
      ),
    );
  }
}
