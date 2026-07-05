import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prov = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text('Budgetly', style: boldText(24)),
      ),
      body: prov.isLoading
          ? _buildShimmerLoader()
          : prov.availableYears.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildYearSelector(prov),
                  ),
                  const SizedBox(height: 20),
                  _buildHeroCarousel(prov),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle('Top Categories'),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCategoryList(prov),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSectionTitle('Analytics'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCharts(prov),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ─── Year Selector ────────────────────────────────────────────────────────

  Widget _buildYearSelector(DashboardProvider prov) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Year: ", style: regularText(14, color: AppColors.grey)),
              DropdownButton<int>(
                value: prov.selectedYear,
                dropdownColor: AppColors.surface,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  size: 24,
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
                underline: const SizedBox(),
                isDense: true,
                style: semiBoldText(16, color: AppColors.white),
                items: prov.availableYears
                    .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                    .toList(),
                onChanged: (year) {
                  if (year != null) prov.changeYear(year);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCarousel(DashboardProvider prov) {
    return Column(
      children: [
        Stack(
          children: [
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: _buildTotalCard(prov),
            ),
            Positioned.fill(
              child: PageView(
                controller: PageController(initialPage: prov.currentCarouselIndex),
                physics: const BouncingScrollPhysics(),
                onPageChanged: prov.onCarouselPageChanged,
                children: [_buildTotalCard(prov), _buildTotalSheetsCard(prov)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            2,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: prov.currentCarouselIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: prov.currentCarouselIndex == index
                    ? AppColors.brand
                    : AppColors.grey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Total Card ───────────────────────────────────────────────────────────

  Widget _buildTotalCard(DashboardProvider prov) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.wallet, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Total Expenses',
                style: semiBoldText(18, color: Colors.white.withValues(alpha: 0.9)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: prov.toggleMonthlyYearly,
                child: Text(
                  prov.showMonthly ? "Show Yearly" : "Monthly",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          Row(
            spacing: 4,
            children: [
              Text('₹', style: regularText(40)),
              AnimatedDigitWidget(
                value: prov.displayTotal,
                textStyle: customText(40, FontWeight.w800),
                enableSeparator: true,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
            ],
          ),
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  prov.displayPeriodLabel,
                  key: ValueKey(prov.showMonthly),
                  style: regularText(16),
                ),
              ),
              const Spacer(),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: prov.showMonthly ? 1 : 0,
                child: GestureDetector(
                  onTap: () {
                    if (prov.showMonthly) {
                      appRouter.pushNamed(
                        Routes.MONTH_DETAILS,
                        extra: {'year': prov.selectedYear, 'month': DateTime.now().month},
                      );
                    }
                  },
                  child: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight03),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSheetsCard(DashboardProvider prov) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandDark, AppColors.black],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const HugeIcon(icon: HugeIcons.strokeRoundedFiles01, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Sheets Balance',
                style: semiBoldText(18, color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          Row(
            spacing: 4,
            children: [
              Text('₹', style: regularText(40)),
              AnimatedDigitWidget(
                value: prov.totalSheetsBalance,
                textStyle: customText(40, FontWeight.w800),
                enableSeparator: true,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
            ],
          ),
          Text('Across all your sheets', style: regularText(16)),
        ],
      ),
    );
  }

  // ─── Category List ────────────────────────────────────────────────────────

  Widget _buildCategoryList(DashboardProvider prov) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (prov.topCategoryEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'No expenses recorded',
          style: regularText(14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: prov.topCategoryEntries.map((entry) {
        final category = prov.getCategoryById(entry.key);
        return CategoryTile(
          margin: const EdgeInsets.only(top: 12),
          emoji: category?.emoji ?? '📦',
          name: category?.name ?? 'Unknown',
          showProgress: true,
          percentage: prov.categoryPercentage(entry.value),
          formattedAmount: formatter.format(entry.value),
          transactionCount: prov.transactionCountForCategory(entry.key),
          onTap: () => appRouter.pushNamed(Routes.CATEGORY_DETAILS, extra: {'category': category}),
        );
      }).toList(),
    );
  }

  // ─── Charts ───────────────────────────────────────────────────────────────

  Widget _buildCharts(DashboardProvider prov) {
    if (prov.categoryTotals.isEmpty) return const SizedBox();
    return Column(
      children: [_buildPieChart(prov), const SizedBox(height: 20), _buildMonthlyChart(prov)],
    );
  }

  Widget _buildPieChart(DashboardProvider prov) {
    final entries = prov.sortedCategoryEntries;
    if (entries.isEmpty) return const SizedBox();

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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor),
        gradient: LinearGradient(
          colors: [AppColors.brandDark.withValues(alpha: 0.5), AppColors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.5],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              spacing: 8,
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedPieChart08,
                  size: 20,
                  color: AppColors.accent,
                ),
                Text('Distribution', style: boldText(16, color: Colors.white)),
              ],
            ),
          ),
          SizedBox(
            height: 360,
            child: SfCircularChart(
              palette: colors,
              legend: Legend(
                isVisible: true,
                isResponsive: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                itemPadding: 8,
                padding: 4,
                textStyle: regularText(12, color: Colors.white),
              ),
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Text(prov.donutCenterText, style: semiBoldText(18)),
                ),
              ],
              series: <CircularSeries>[
                DoughnutSeries<dynamic, String>(
                  animationDuration: 1000,
                  dataSource: entries,
                  xValueMapper: (dynamic entry, _) =>
                      prov.getCategoryById((entry as MapEntry<String, double>).key)?.name ?? '',
                  yValueMapper: (dynamic entry, _) => (entry as MapEntry<String, double>).value,
                  innerRadius: '50%',
                  radius: '100%',
                  selectionBehavior: SelectionBehavior(enable: true),
                  dataLabelMapper: (dynamic entry, _) {
                    final pct = prov.piePercentage((entry as MapEntry<String, double>).value);
                    return '$pct%';
                  },
                  legendIconType: LegendIconType.seriesType,
                  onPointTap: prov.onDonutSectionTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(DashboardProvider prov) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor),
        gradient: LinearGradient(
          colors: [AppColors.brandDark.withValues(alpha: 0.5), AppColors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.5],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedChartEvaluation,
                  size: 20,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
                Text('Monthly Trend', style: boldText(16, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 360,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              trackballBehavior: TrackballBehavior(
                enable: true,
                activationMode: ActivationMode.singleTap,
                lineType: TrackballLineType.vertical,
                tooltipSettings: InteractiveTooltip(
                  enable: true,
                  borderColor: AppColors.brand.withValues(alpha: 0.5),
                  borderRadius: 12,
                  canShowMarker: false,
                  borderWidth: 2,
                  color: AppColors.brandDark,
                  textStyle: regularText(12, color: Colors.white),
                  format: 'Month point.x \n point.y',
                ),
                markerSettings: const TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  height: 10,
                  width: 10,
                  color: AppColors.brand,
                  borderColor: AppColors.brandDark,
                  borderWidth: 2,
                ),
              ),
              primaryXAxis: CategoryAxis(
                labelPlacement: LabelPlacement.onTicks,
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                desiredIntervals: 10,
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                labelStyle: regularText(12, color: AppColors.grey),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: AppColors.borderColor,
                  dashArray: <double>[5, 5],
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                labelStyle: regularText(12, color: AppColors.grey),
                labelFormat: '₹{value}',
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<MapEntry<int, double>, String>(
                  splineType: SplineType.cardinal,
                  dataSource: prov.monthlyTotals.entries.toList(),
                  xValueMapper: (entry, _) => entry.key.toString(),
                  yValueMapper: (entry, _) => entry.value,
                  animationDuration: 1000,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.2),
                      AppColors.accent.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderColor: AppColors.accent,
                  borderWidth: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 8,
                    width: 8,
                    shape: DataMarkerType.circle,
                    borderWidth: 2,
                    borderColor: AppColors.accent,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(title, style: semiBoldText(18, color: Colors.white70));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long, size: 60, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text('No expenses yet', style: boldText(20, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses to see data here.',
            style: regularText(14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static Widget _buildShimmerLoader() {
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
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(20),
                ),
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
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                        Container(
                          width: 80,
                          height: 20,
                          margin: const EdgeInsets.only(right: 16),
                          color: baseColor,
                        ),
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
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
