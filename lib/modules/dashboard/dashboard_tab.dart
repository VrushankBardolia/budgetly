import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class DashboardTab extends GetView<DashboardController> {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text('Budgetly', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildShimmerLoader();
        if (controller.availableYears.isEmpty) return _buildEmptyState();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildYearSelector(),
              const SizedBox(height: 20),
              _buildTotalCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Top Categories'),
              const SizedBox(height: 16),
              _buildCategoryList(),
              const SizedBox(height: 24),
              _buildSectionTitle('Analytics'),
              const SizedBox(height: 16),
              _buildCharts(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // ─── Year Selector ────────────────────────────────────────────────────────

  Widget _buildYearSelector() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Year: ", style: TextStyle(color: Colors.grey)),
                DropdownButton<int>(
                  value: controller.selectedYear.value,
                  dropdownColor: AppColors.surface,
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 24, color: Colors.white, strokeWidth: 2),
                  underline: const SizedBox(),
                  isDense: true,
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  items: controller.availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                  onChanged: (year) {
                    if (year != null) controller.changeYear(year);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Total Card ───────────────────────────────────────────────────────────

  Widget _buildTotalCard() {
    return Obx(() {
      // final controller = controller;
      final year = controller.selectedYear.value;
      final month = DateTime.now().month;
      final monthName = DateFormat.MMMM().format(DateTime.now());
      final displayValue = controller.showMonthly.value ? controller.currentMonthTotal : controller.yearlyTotal;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1565C0), Color(0xFF1E88E5)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF1565C0).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.wallet, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Total Expenses',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white.withValues(alpha: 0.9), fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: controller.toggleMonthlyYearly,
                  child: Text(controller.showMonthly.value ? "Show Yearly" : "Monthly", style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              spacing: 4,
              children: [
                Text('₹', style: GoogleFonts.plusJakartaSans(fontSize: 40, color: Colors.white, height: 1.0)),
                AnimatedDigitWidget(
                  value: displayValue,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 40,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                  enableSeparator: true,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(-0.1, 0), end: Offset.zero).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    controller.showMonthly.value ? 'For $monthName $year' : 'For $year',
                    key: ValueKey(controller.showMonthly.value),
                    style: GoogleFonts.plusJakartaSans(fontSize: 16),
                  ),
                ),
                const Spacer(),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: controller.showMonthly.value ? 1 : 0,
                  child: GestureDetector(
                    onTap: () => Get.toNamed(Routes.MONTH_DETAILS, arguments: {'year': year, 'month': month}),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight03),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // ─── Category List ────────────────────────────────────────────────────────

  Widget _buildCategoryList() {
    return Obx(() {
      final totals = controller.categoryTotals;
      final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

      if (totals.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: const Text(
            'No expenses recorded',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
      }

      final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final displayed = sorted.length > 3 ? sorted.take(3).toList() : sorted;
      final maxVal = sorted.first.value;

      return Column(
        children: displayed.map((entry) {
          final category = controller.getCategoryById(entry.key);
          final percentage = maxVal > 0 ? entry.value / maxVal : 0.0;
          final txCount = controller.transactionCountForCategory(entry.key);

          return CategoryTile(
            margin: const EdgeInsets.only(top: 12),
            emoji: category?.emoji ?? '📦',
            name: category?.name ?? 'Unknown',
            showProgress: true,
            percentage: percentage,
            formattedAmount: formatter.format(entry.value),
            transactionCount: txCount,
          );
        }).toList(),
      );
    });
  }

  // ─── Charts ───────────────────────────────────────────────────────────────

  Widget _buildCharts() {
    return Obx(() {
      if (controller.categoryTotals.isEmpty) return const SizedBox();
      return Column(children: [_buildPieChart(), const SizedBox(height: 20), _buildMonthlyChart()]);
    });
  }

  Widget _buildPieChart() {
    // final controller = controller;
    final totals = controller.categoryTotals;
    if (totals.isEmpty) return const SizedBox();

    final total = totals.values.fold(0.0, (sum, v) => sum + v);
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    const colors = [
      Color(0xFF42A5F5),
      Color(0xFF26C6DA),
      Color(0xFF66BB6A),
      Color(0xFFFFA726),
      Color(0xFFEF5350),
      Color(0xFFAB47BC),
      Color(0xFF7E57C2),
      Color(0xFFEC407A),
      Color(0xFF5C6BC0),
      Color(0xFFFFCA28),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedPieChart08, size: 20, color: AppColors.accent),
              Text(
                'Distribution',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: sorted.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value.value;
                  final percentage = value / total * 100;
                  final color = colors[index % colors.length];

                  return PieChartSectionData(
                    color: color,
                    value: value,
                    title: percentage > 10 ? '${percentage.toStringAsFixed(0)}%' : '',
                    radius: 70,
                    titleStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sorted.asMap().entries.map((entry) {
              final index = entry.key;
              final categoryId = entry.value.key;
              final name = controller.getCategoryById(categoryId)?.name ?? '';
              final color = colors[index % colors.length];

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final monthlyData = controller.monthlyTotals;
    final maxY = monthlyData.values.isEmpty ? 10000.0 : monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedChartEvaluation, size: 20, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Monthly Trend',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.surfaceLight, strokeWidth: 1, dashArray: [5, 5]),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final m = value.toInt();
                        if (m < 1 || m > 12) return const SizedBox();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(m.toString(), style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 12)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 12,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppColors.brand,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppColors.brand.withValues(alpha: 0.3), AppColors.brand.withValues(alpha: 0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (touchedSpots) {
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                      return touchedSpots.map((spot) {
                        final monthIndex = spot.x.toInt() - 1;
                        final name = (monthIndex >= 0 && monthIndex < 12) ? months[monthIndex] : '';
                        return LineTooltipItem('$name  •  ₹${spot.y.toInt()}', GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold));
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long, size: 60, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          const Text(
            'No expenses yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text('Start tracking your expenses to see data here.', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    const baseColor = Color(0xFF1E1E1E);
    const highlightColor = Color(0xFF2C2C2C);
    const backgroundColor = Color(0xFF121212);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(30)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 120, height: 20, color: baseColor),
                  Container(width: 60, height: 20, color: baseColor),
                ],
              ),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(width: 100, height: 14, color: baseColor),
                              const SizedBox(height: 8),
                              Container(width: 60, height: 14, color: baseColor),
                            ],
                          ),
                        ),
                        Container(width: 80, height: 20, margin: const EdgeInsets.only(right: 16), color: baseColor),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(width: 100, height: 20, color: baseColor),
              const SizedBox(height: 16),
              Container(
                height: 250,
                decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
