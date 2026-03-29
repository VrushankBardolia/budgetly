import 'package:budgetly/core/import_to_export.dart';

class MonthsTab extends GetView<MonthController> {
  const MonthsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text('Monthly Overview', style: boldText(24)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoader();
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: controller.monthSummaries.length,
          itemBuilder: (ctx, index) => MonthCard(
            summary: controller.monthSummaries[index],
            onTap: () => controller.navigateToMonth(
              controller.monthSummaries[index].month,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildShimmerLoader() {
    const baseColor = Color(0xFF1E1E1E);
    const highlightColor = Color(0xFF2C2C2C);
    const backgroundColor = AppColors.black;

    return Container(
      color: backgroundColor,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
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
                color: baseColor,
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
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
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
          border: summary.isCurrent
              ? Border.all(color: AppColors.brand, width: 2)
              : Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  summary.monthName,
                  style: GoogleFonts.plusJakartaSans(
                    color: summary.isCurrent ? AppColors.brand : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (summary.hasData)
                  HugeIcon(
                    icon: summary.statusIcon,
                    color: summary.statusColor,
                    size: 20,
                  ),
              ],
            ),

            const Spacer(),

            // ── Body ────────────────────────────────────────────────────────
            if (summary.hasData) ...[
              Text(
                summary.statusLabel,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${summary.difference.abs().toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  color: summary.statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: summary.progressValue,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    summary.statusColor,
                  ),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Spent: ₹${summary.expense.toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ] else ...[
              Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendarMinus02,
                  strokeWidth: 1.5,
                  color: Colors.grey.shade800,
                  size: 36,
                ),
              ),
              const Spacer(),
              Text(
                'No Data',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
