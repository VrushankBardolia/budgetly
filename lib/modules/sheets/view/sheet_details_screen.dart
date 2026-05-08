import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.brandDark.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: FloatingActionButton.extended(
          onPressed: controller.goToAddRecord,
          backgroundColor: AppColors.brandDark,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('Add Record', style: semiBoldText(14, color: Colors.white)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  spacing: 14,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: buildSummaryCard(
                            label: 'Total Income',
                            amount: controller.totalIncome,
                            color: AppColors.success,
                            icon: Icons.arrow_downward_rounded,
                          ),
                        ),
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
                    buildBalanceCard(controller.netBalance, controller.isProfit),
                  ],
                ),
              ),

              Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: buildFilterBar()),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Records', style: boldText(18, color: AppColors.white)),
                    Text(
                      '${controller.filteredRecords.length}'.padLeft(2, '0'),
                      style: semiBoldText(12, color: AppColors.grey),
                    ),
                  ],
                ),
              ),

              controller.filteredRecords.isEmpty ? buildEmptyState() : buildRecordList(),
            ],
          ),
        );
      }),
    );
  }

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(label, style: mediumText(13, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fmt.format(amount),
            style: boldText(22, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildBalanceCard(double balance, bool isProfit) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final color = isProfit ? AppColors.success : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.01)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Balance',
                style: mediumText(14, color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: 4),
              Text(fmt.format(balance), style: customText(28, FontWeight.w800, color: color)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: HugeIcon(
              icon: isProfit
                  ? HugeIcons.strokeRoundedArrowUpRight01
                  : HugeIcons.strokeRoundedArrowDownRight01,
              color: color,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterBar() {
    return Obx(() {
      final filters = [('all', 'All'), ('income', 'Income'), ('expense', 'Expense')];

      final currentIndex = filters.indexWhere((f) => f.$1 == controller.filterType.value);
      final safeIndex = currentIndex == -1 ? 0 : currentIndex;

      final activeColor = controller.filterType.value == 'income'
          ? AppColors.success
          : controller.filterType.value == 'expense'
          ? AppColors.error
          : AppColors.brand;

      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / filters.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: safeIndex * tabWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: tabWidth,
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: activeColor.withValues(alpha: 0.5)),
                    ),
                  ),
                ),

                Row(
                  children: filters.map((f) {
                    final isActive = controller.filterType.value == f.$1;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.setFilter(f.$1);
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: isActive
                                ? boldText(14, color: AppColors.white)
                                : regularText(14, color: Colors.white.withValues(alpha: 0.5)),
                            child: Text(f.$2),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(
              CupertinoIcons.doc_text_search,
              size: 48,
              color: AppColors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text('No records found', style: semiBoldText(16, color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  Widget buildRecordList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16),
      itemCount: controller.filteredRecords.length,
      itemBuilder: (ctx, index) {
        final record = controller.filteredRecords[index];
        return buildRecordTile(record);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 10),
    );
  }

  Widget buildRecordTile(SheetRecord record) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final color = record.isIncome ? AppColors.success : AppColors.white;

    return GestureDetector(
      onLongPressStart: (details) {
        HapticFeedback.heavyImpact();
        showPullDownMenu(
          context: Get.context!,
          routeTheme: PullDownMenuRouteTheme(backgroundColor: AppColors.surfaceLight, width: 200),
          items: [
            PullDownMenuItem(
              onTap: () => controller.goToEditRecord(record),
              title: "Edit",
              icon: CupertinoIcons.pen,
              itemTheme: PullDownMenuItemTheme(textStyle: mediumText(14)),
            ),
            PullDownMenuItem(
              onTap: () => controller.showDeleteDialog(record.id),
              title: "Delete",
              icon: CupertinoIcons.delete,
              isDestructive: true,
              itemTheme: PullDownMenuItemTheme(textStyle: mediumText(14)),
            ),
          ],
          position: Rect.fromLTRB(
            details.globalPosition.dx,
            details.globalPosition.dy,
            details.globalPosition.dx,
            details.globalPosition.dy,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.5)),
          gradient: RadialGradient(
            center: Alignment.centerLeft,
            radius: 2.5,
            colors: [
              record.isIncome
                  ? AppColors.success.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.03),
              AppColors.surface.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: record.isIncome
                    ? AppColors.success.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: record.isIncome
                      ? AppColors.success.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Center(
                child: Icon(
                  record.isIncome ? CupertinoIcons.arrow_down_left : CupertinoIcons.arrow_up_right,
                  color: color,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ── 2. Details & Date ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.detail,
                    style: semiBoldText(16, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.calendar, size: 14, color: AppColors.hintColor),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd MMMM').format(record.date).toUpperCase(),
                        style: mediumText(12, color: AppColors.grey).copyWith(letterSpacing: 0.7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── 3. Stacked Amount ──────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${record.isIncome ? '+' : ''}${fmt.format(record.amount)}',
                  style: boldText(16, color: color).copyWith(letterSpacing: -0.5),
                ),
                // const SizedBox(height: 4),

                // Tiny IN/OUT tag
                Text(
                  record.isIncome ? "IN" : "OUT",
                  style: boldText(
                    10,
                    color: record.isIncome
                        ? AppColors.success.withValues(alpha: 0.8)
                        : AppColors.white.withValues(alpha: 0.6),
                  ).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
