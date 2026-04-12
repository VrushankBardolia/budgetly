import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class MonthDetailScreen extends GetView<MonthDetailController> {
  const MonthDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(controller.formattedMonth, style: boldText(20)),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedEdit04, size: 20, color: Colors.white),
            onPressed: controller.showBudgetDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoader();
        }
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Summary Cards ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            "Budget",
                            controller.formatter.format(controller.budget.value),
                            Colors.white,
                            icon: HugeIcons.strokeRoundedWallet01,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            "Spent",
                            controller.formatter.format(controller.totalExpense),
                            Colors.white,
                            icon: HugeIcons.strokeRoundedMoney01,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (controller.isCurrent) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              controller.statusLabel,
                              controller.formatter.format(controller.remaining),
                              controller.statusColor,
                              icon: controller.statusIcon,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              "Safe / Day",
                              controller.formatter.format(controller.remainPerDay),
                              Colors.blueAccent,
                              icon: HugeIcons.strokeRoundedCoins01,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildInfoCard(
                        controller.statusLabel,
                        controller.formatter.format(controller.remaining),
                        controller.statusColor,
                        icon: controller.statusIcon,
                        isFullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: controller.showSortDialog,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowUpDown,
                      color: AppColors.white,
                      size: 20,
                    ),
                    label: Text('Sort by', style: boldText(16)),
                  ),
                  TextButton.icon(
                    onPressed: controller.showCategoryFilterDialog,
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedFilter,
                      color: AppColors.white,
                      size: 20,
                    ),
                    label: Text('Category Filter', style: boldText(16)),
                  ),
                ],
              ),
            ),

            // ── Transactions Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Transactions", style: semiBoldText(18, color: Colors.grey.shade400)),
                    Text(
                      "${controller.expenses.length}",
                      style: regularText(14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),

            // ── Empty State ─────────────────────────────────────────────────
            if (controller.expenses.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 50,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('No transactions', style: regularText(14, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              )
            else ...[
              // ── Expense List ───────────────────────────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final expense = controller.expenses[index];
                  final category = controller.getCategoryById(expense.categoryId);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GestureDetector(
                      onLongPressStart: (details) {
                        HapticFeedback.heavyImpact();
                        showPullDownMenu(
                          context: context,
                          routeTheme: PullDownMenuRouteTheme(
                            backgroundColor: AppColors.surfaceLight,
                            width: 200,
                          ),
                          items: [
                            PullDownMenuItem(
                              onTap: () => controller.goToEditExpense(expense),
                              title: "Edit",
                              icon: CupertinoIcons.pen,
                              itemTheme: PullDownMenuItemTheme(textStyle: regularText(14)),
                            ),
                            PullDownMenuItem(
                              onTap: () => controller.showDeleteExpenseDialog(expense.id),
                              title: "Delete",
                              icon: CupertinoIcons.delete,
                              isDestructive: true,
                              itemTheme: PullDownMenuItemTheme(textStyle: regularText(14)),
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
                      child: ExpenseTile(expense: expense, category: category!),
                    ),
                  );
                }, childCount: controller.expenses.length),
              ),
              controller.selectedFilterCategoryId.value == "All"
                  ? SliverToBoxAdapter(child: SizedBox())
                  : SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "${controller.selectedFilterOption.value} Total : ${controller.formatter.format(controller.filteredExpenseTotal)}",
                          style: regularText(14, color: AppColors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      }),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToAddExpense,
        label: Text("Add Expense", style: regularText(14)),
        icon: HugeIcon(icon: HugeIcons.strokeRoundedMoneyAdd01),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ─── Info Card Widget ─────────────────────────────────────────────────────

  Widget _buildInfoCard(
    String title,
    String value,
    Color valueColor, {
    dynamic icon,
    VoidCallback? onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: regularText(14, color: Colors.grey)),
                HugeIcon(icon: icon, size: 20, color: valueColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: boldText(24, color: valueColor)),
          ],
        ),
      ),
    );
  }

  // MARK:Shimmer Loader

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildShimmerCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildShimmerCard()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildShimmerCard()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildShimmerCard()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 16,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildShimmerExpenseTile(),
              );
            }, childCount: 5),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 14,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 24,
            width: 80,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerExpenseTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 18,
            width: 60,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}
