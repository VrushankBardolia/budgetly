import 'package:budgetly/core/import_to_export.dart';

class MonthsTab extends ConsumerWidget {
  const MonthsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthStateAsync = ref.watch(monthStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Monthly Overview', style: serifText(20))),
      body: monthStateAsync.when(
        loading: () => _buildShimmerLoader(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading months: $err', style: boldText(14)),
            ],
          ),
        ),
        data: (state) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(expensesProvider(state.selectedYear));
            ref.invalidate(budgetsProvider(state.selectedYear));
          },
          color: AppColors.brand,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: state.monthSummaries.length,
            itemBuilder: (ctx, index) => MonthCard(
              summary: state.monthSummaries[index],
              onTap: () async {
                await appRouter.pushNamed(
                  Routes.MONTH_DETAILS,
                  extra: {'year': state.selectedYear, 'month': state.monthSummaries[index].month},
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: AppColors.background,
      highlightColor: AppColors.surface,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: 12,
        itemBuilder: (ctx, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 60, height: 16, color: Colors.white),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ],
                ),
                const Spacer(),
                Container(width: 50, height: 10, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: 80, height: 20, color: Colors.white),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(width: 60, height: 10, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Month Card ───────────────────────────────────────────────────────────────

class MonthCard extends StatelessWidget {
  final MonthSummary summary;
  final VoidCallback onTap;

  const MonthCard({super.key, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: summary.isCurrent ? AppColors.secondaryAccent : AppColors.surface,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(summary.monthName, style: boldText(16)),
                if (summary.hasData)
                  HugeIcon(icon: summary.statusIcon, color: summary.statusColor, size: 20),
              ],
            ),

            const Spacer(),

            // ── Body ────────────────────────────────────────────────────────
            if (summary.hasData) ...[
              Text(summary.statusLabel, style: regularText(12, color: AppColors.grey)),
              Text(
                '₹${summary.difference.abs().toStringAsFixed(0)}',
                style: boldText(20, color: summary.statusColor),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: summary.progressValue,
                  backgroundColor: AppColors.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(summary.statusColor),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Spent: ₹${summary.expense.toStringAsFixed(0)}',
                style: regularText(12, color: AppColors.grey),
              ),
            ] else ...[
              Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendarMinus02,
                  strokeWidth: 1,
                  color: AppColors.grey,
                  size: 32,
                ),
              ),
              const Spacer(),
              Text('No Data', style: regularText(12, color: AppColors.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }
}
