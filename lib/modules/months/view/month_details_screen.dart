import 'package:budgetly/core/import_to_export.dart';
import 'package:flutter/cupertino.dart';

class MonthDetailScreen extends ConsumerWidget {
  const MonthDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final stateAsync = ref.watch(monthDetailStateProvider(args));
    final controller = ref.read(monthDetailControllerProvider(args));

    // Automatically check budget when data finishes loading
    ref.listen<AsyncValue<MonthDetailState>>(monthDetailStateProvider(args), (previous, next) {
      next.whenOrNull(
        data: (state) {
          if (previous == null || previous.isLoading) {
            controller.checkBudgetAndShowDialog(state);
          }
        },
      );
    });

    return stateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('Loading...', style: TextStyle(fontSize: 16)),
        ),
        body: _buildShimmerLoader(),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(elevation: 0, centerTitle: true, title: const Text('Error')),
        body: Center(child: Text('Error loading month details: $err')),
      ),
      data: (state) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(state.formattedMonth, style: serifText(20)),
          actions: [
            IconButton(
              tooltip: "Export to PDF",
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedPdf02),
              onPressed: () => controller.exportToPdf(state),
            ),
            IconButton(
              tooltip: "Change Budget",
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedEdit04),
              onPressed: () => controller.showBudgetDialog(state),
            ),
          ],
        ),
        body: _buildBody(ref, state, controller),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.goToAddExpense,
          label: Text("Add Expense", style: mediumText(14, color: AppColors.white)),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedMoneyAdd01),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildBody(WidgetRef ref, MonthDetailState state, MonthDetailController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopCards(state),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => controller.showSortDialog(state, const [
                  'Date (Newest first)',
                  'Date (Oldest first)',
                  'Amount (High to Low)',
                  'Amount (Low to High)',
                ]),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowUpDown,
                  color: AppColors.brand,
                  size: 18,
                ),
                label: Text('Sort by', style: boldText(14, color: AppColors.brand)),
              ),
              TextButton.icon(
                onPressed: () => controller.showCategoryFilterDialog(state),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedFilter,
                  color: AppColors.brand,
                  size: 18,
                ),
                label: Text('Category Filter', style: boldText(14, color: AppColors.brand)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Transactions", style: serifText(18)),
                Text(
                  "${state.filteredExpenses.length}",
                  style: regularText(14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (state.filteredExpenses.isEmpty)
            buildEmptyState()
          else ...[
            buildExpenseList(ref, state, controller),
            buildCategoryTotal(state),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTopCards(MonthDetailState state) {
    return Container(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  "Budget",
                  state.formatter.format(state.budget),
                  AppColors.textPrimary,
                  icon: HugeIcons.strokeRoundedWallet01,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInfoCard(
                  "Spent",
                  state.formatter.format(state.totalExpense),
                  AppColors.textPrimary,
                  icon: HugeIcons.strokeRoundedMoney01,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.isCurrent) ...[
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    state.statusLabel,
                    state.formatter.format(state.remaining),
                    state.statusColor,
                    icon: state.statusIcon,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoCard(
                    "Safe / Day",
                    state.formatter.format(state.remainPerDay),
                    AppColors.info,
                    icon: HugeIcons.strokeRoundedCoins01,
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildInfoCard(
              state.statusLabel,
              state.formatter.format(state.remaining),
              state.statusColor,
              icon: state.statusIcon,
              isFullWidth: true,
            ),
          ],
        ],
      ),
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
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: regularText(14, color: AppColors.textSecondary)),
                HugeIcon(
                  icon: icon,
                  size: 20,
                  color: valueColor == AppColors.textPrimary ? AppColors.brand : valueColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: boldText(24, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 50,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text('No transactions', style: regularText(14, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget buildExpenseList(WidgetRef ref, MonthDetailState state, MonthDetailController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.filteredExpenses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final expense = state.filteredExpenses[index];
        final category = state.getCategoryById(expense.categoryId);
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
            child: ExpenseTile(
              expense: expense,
              category:
                  category ?? Category(id: 'unknown', name: 'Unknown', emoji: '📦', userId: ''),
            ),
          ),
        );
      },
    );
  }

  Widget buildCategoryTotal(MonthDetailState state) {
    if (state.selectedFilterCategoryId == "All") {
      return const SizedBox();
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "${state.selectedFilterOptionName} Total : ${state.formatter.format(state.filteredExpenseTotal)}",
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
            delegate: SliverChildListDelegate(
              List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildShimmerExpenseTile(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
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
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 24,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
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
            decoration: const BoxDecoration(color: AppColors.surfaceLight, shape: BoxShape.circle),
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
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 18,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
