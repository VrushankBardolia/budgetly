import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class SheetDetailsScreen extends ConsumerWidget {
  const SheetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final stateAsync = ref.watch(sheetDetailsStateProvider(args));
    final controller = ref.read(sheetDetailsControllerProvider(args));

    return stateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(args['sheetName'] ?? 'Loading...', style: serifText(20)),
        ),
        body: buildShimmerLoader(),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Error'),
        ),
        body: Center(child: Text('Error loading sheet records: $err')),
      ),
      data: (state) => Scaffold(
        appBar: AppBar(centerTitle: true, title: Text(state.sheetName, style: serifText(20))),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.goToAddRecord,
          backgroundColor: AppColors.brandDark,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: AppColors.white),
          label: Text('Add Record', style: semiBoldText(14, color: AppColors.white)),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(sheetRecordsProvider(state.sheetId));
            ref.invalidate(sheetsListProvider);
            ref.invalidate(totalSheetsBalanceProvider);
          },
          color: AppColors.brand,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    spacing: 12,
                    children: [
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(
                            child: buildSummaryCard(
                              'Total Income',
                              state.totalIncome,
                              AppColors.success,
                              Icons.arrow_downward_rounded,
                            ),
                          ),
                          Expanded(
                            child: buildSummaryCard(
                              'Total Expense',
                              state.totalExpense,
                              AppColors.error,
                              Icons.arrow_upward_rounded,
                            ),
                          ),
                        ],
                      ),
                      buildBalanceCard(state.netBalance, state.isProfit),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: buildFilterBar(state, controller),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Records', style: serifText(18)),
                      Text(
                        '${state.filteredRecords.length}'.padLeft(2, '0'),
                        style: semiBoldText(12, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                state.filteredRecords.isEmpty
                    ? buildEmptyState()
                    : buildRecordList(context, state, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSummaryCard(String label, double amount, Color color, IconData icon) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(label, style: mediumText(13, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 8),
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
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Net Balance', style: mediumText(14, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(fmt.format(balance), style: customText(28, FontWeight.w800, color: color)),
            ],
          ),
          HugeIcon(
            icon: isProfit
                ? HugeIcons.strokeRoundedArrowUpRight01
                : HugeIcons.strokeRoundedArrowDownRight01,
            color: color,
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget buildFilterBar(SheetDetailsState state, SheetDetailsController controller) {
    final filters = [('income', 'Income'), ('expense', 'Expense')];

    final currentIndex = filters.indexWhere((f) => f.$1 == state.filterType);
    final hasSelection = currentIndex != -1;
    final safeIndex = hasSelection ? currentIndex : 0;

    final activeColor = state.filterType == 'income'
        ? AppColors.success
        : state.filterType == 'expense'
        ? AppColors.error
        : AppColors.info;

    return Container(
      height: 44,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(30)),
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
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: hasSelection ? 1.0 : 0.0,
                  child: Container(
                    width: tabWidth,
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: activeColor.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
              ),

              Row(
                children: filters.map((f) {
                  final isActive = state.filterType == f.$1;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (isActive) {
                          controller.setFilter('all');
                        } else {
                          controller.setFilter(f.$1);
                        }
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: isActive
                              ? boldText(14, color: activeColor)
                              : regularText(14, color: AppColors.textSecondary),
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

  Widget buildRecordList(BuildContext context, SheetDetailsState state, SheetDetailsController controller) {
    final grouped = state.groupedRecords;
    final keys = grouped.keys.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120, left: 16, right: 16),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final month = keys[index];
        final monthRecords = grouped[month]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4, left: 8),
              child: Text(
                month.toUpperCase(),
                style: boldText(13, color: AppColors.grey).copyWith(letterSpacing: 1),
              ),
            ),
            ...monthRecords.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: buildRecordTile(context, controller, record),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildRecordTile(BuildContext context, SheetDetailsController controller, SheetRecord record) {
    final fmt = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final color = record.isIncome ? AppColors.success : AppColors.textPrimary;

    return GestureDetector(
      onLongPressStart: (details) {
        HapticFeedback.heavyImpact();
        showPullDownMenu(
          context: context,
          routeTheme: const PullDownMenuRouteTheme(
            backgroundColor: AppColors.surfaceLight,
            width: 200,
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Center(
              child: Icon(
                record.isIncome ? CupertinoIcons.arrow_down_left : CupertinoIcons.arrow_up_right,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    record.detail,
                    style: semiBoldText(16, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('dd MMMM').format(record.date).toUpperCase(),
                    style: mediumText(
                      12,
                      color: AppColors.textSecondary,
                    ).copyWith(letterSpacing: 0.7),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${record.isIncome ? '+ ' : ''}${fmt.format(record.amount)}',
                  style: boldText(16, color: color).copyWith(letterSpacing: -0.5),
                ),
                Text(
                  record.isIncome ? "IN" : "OUT",
                  style: boldText(
                    10,
                    color: record.isIncome
                        ? AppColors.success.withValues(alpha: 0.8)
                        : AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            const SizedBox(height: 24),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 24,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 16,
                  width: 24,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: buildRecordShimmerTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecordShimmerTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 20,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 30,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
