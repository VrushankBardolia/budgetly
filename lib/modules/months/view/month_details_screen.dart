import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class MonthDetailScreen extends ConsumerWidget {
  const MonthDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final prov = ref.watch(monthDetailProvider(args));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(prov.formattedMonth, style: boldText(20)),
        actions: [
          IconButton(
            tooltip: "Export to PDF",
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedPdf02),
            onPressed: prov.exportToPdf,
          ),
          IconButton(
            tooltip: "Change Budget",
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit04),
            onPressed: prov.showBudgetDialog,
          ),
        ],
      ),
      body: prov.isLoading
          ? _buildShimmerLoader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                "Budget",
                                prov.formatter.format(prov.budget),
                                Colors.white,
                                icon: HugeIcons.strokeRoundedWallet01,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                "Spent",
                                prov.formatter.format(prov.totalExpense),
                                Colors.white,
                                icon: HugeIcons.strokeRoundedMoney01,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (prov.isCurrent) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  prov.statusLabel,
                                  prov.formatter.format(prov.remaining),
                                  prov.statusColor,
                                  icon: prov.statusIcon,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  "Safe / Day",
                                  prov.formatter.format(prov.remainPerDay),
                                  Colors.blueAccent,
                                  icon: HugeIcons.strokeRoundedCoins01,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          _buildInfoCard(
                            prov.statusLabel,
                            prov.formatter.format(prov.remaining),
                            prov.statusColor,
                            icon: prov.statusIcon,
                            isFullWidth: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: prov.showSortDialog,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowUpDown,
                          color: AppColors.white,
                          size: 20,
                        ),
                        label: Text('Sort by', style: boldText(16)),
                      ),
                      TextButton.icon(
                        onPressed: prov.showCategoryFilterDialog,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedFilter,
                          color: AppColors.white,
                          size: 20,
                        ),
                        label: Text('Category Filter', style: boldText(16)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Transactions", style: semiBoldText(18, color: Colors.grey.shade400)),
                        Text(
                          "${prov.expenses.length}",
                          style: regularText(14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  if (prov.expenses.isEmpty)
                    buildEmptyState(context)
                  else ...[
                    buildExpenseList(prov),
                    buildCategoryTotal(prov),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => errorSnackbar("error"), //provider.goToAddExpense,
        label: Text("Add Expense", style: regularText(14)),
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoneyAdd01),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

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

  Widget buildEmptyState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
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
    );
  }

  Widget buildExpenseList(MonthDetailProvider prov) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: prov.expenses.length,
      itemBuilder: (context, index) {
        final expense = prov.expenses[index];
        final category = prov.getCategoryById(expense.categoryId);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
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
                    onTap: () => prov.goToEditExpense(expense),
                    title: "Edit",
                    icon: CupertinoIcons.pen,
                    itemTheme: PullDownMenuItemTheme(textStyle: regularText(14)),
                  ),
                  PullDownMenuItem(
                    onTap: () => prov.showDeleteExpenseDialog(expense.id),
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
      },
    );
  }

  Widget buildCategoryTotal(MonthDetailProvider prov) {
    if (prov.selectedFilterCategoryId == "All") {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "${prov.selectedFilterOption} Total : ${prov.formatter.format(prov.filteredExpenseTotal)}",
          style: regularText(14, color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  // MARK: Shimmer Loader

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
