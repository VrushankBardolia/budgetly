import 'package:budgetly/core/import_to_export.dart';
import 'package:intl/intl.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardStateAsync = ref.watch(dashboardStateProvider);

    return dashboardStateAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Budgetly', style: serifText(20))),
        body: _buildShimmerLoader(),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: Text('Budgetly', style: serifText(20))),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading dashboard', style: boldText(16)),
              const SizedBox(height: 8),
              Text(err.toString(), style: regularText(14, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
      data: (state) => Scaffold(
        appBar: AppBar(
          title: Text('Budgetly', style: serifText(20)),
          actions: [_buildYearSelector(ref, state), const SizedBox(width: 16)],
        ),
        body: state.availableYears.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(availableYearsProvider);
                  ref.invalidate(categoriesProvider);
                  ref.invalidate(totalSheetsBalanceProvider);
                  ref.invalidate(expensesProvider(state.selectedYear));
                },
                color: AppColors.brand,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryList(ref, state),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSectionTitle('Top Categories'),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildCategoryList(state),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSectionTitle('Analytics'),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildCharts(ref, state),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ─── Year Selector ────────────────────────────────────────────────────────

  Widget _buildYearSelector(WidgetRef ref, DashboardState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Year: ", style: regularText(14, color: AppColors.textSecondary)),
        DropdownButton<int>(
          value: state.selectedYear,
          dropdownColor: AppColors.surface,
          icon: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 20, strokeWidth: 2),
          ),
          underline: const SizedBox(),
          isDense: true,
          style: semiBoldText(16, color: AppColors.textPrimary),
          items: state.availableYears
              .map(
                (y) => DropdownMenuItem(
                  value: y,
                  child: Text(y.toString(), style: semiBoldText(16, color: AppColors.textPrimary)),
                ),
              )
              .toList(),
          onChanged: (year) {
            if (year != null) {
              ref.read(selectedDashboardYearProvider.notifier).state = year;
            }
          },
        ),
      ],
    );
  }

  Widget _buildSummaryList(WidgetRef ref, DashboardState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
        children: [
          _buildSummaryCard(
            title: '${DateFormat.MMMM().format(DateTime.now())} Expenses',
            value: state.currentMonthTotal.toInt(),
            onTap: () {
              appRouter.pushNamed(
                Routes.MONTH_DETAILS,
                extra: {'year': state.selectedYear, 'month': DateTime.now().month},
              );
            },
          ),
          const Divider(height: 12, indent: 16, endIndent: 16, color: AppColors.borderColor),
          _buildSummaryCard(
            title: '${state.selectedYear} Expenses',
            value: state.yearlyTotal.toInt(),
          ),
          const Divider(height: 12, indent: 16, endIndent: 16, color: AppColors.borderColor),
          _buildSummaryCard(title: 'Total Sheets Balance', value: state.totalSheetsBalance.toInt()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required int value, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: mediumText(16, color: AppColors.textPrimary)),
          ),
          Text(
            '₹$value',
            style: boldText(18, color: AppColors.textPrimary).copyWith(
              decoration: onTap != null ? TextDecoration.underline : null,
              decorationStyle: TextDecorationStyle.dotted,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category List ────────────────────────────────────────────────────────

  Widget _buildCategoryList(DashboardState state) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (state.topCategoryEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'No expenses recorded',
          style: regularText(14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: state.topCategoryEntries.length,
        itemBuilder: (context, index) {
          final entry = state.topCategoryEntries[index];
          final category = state.getCategoryById(entry.key);
          return CategoryTile(
            emoji: category?.emoji ?? '📦',
            name: category?.name ?? 'Unknown',
            showProgress: true,
            percentage: state.categoryPercentage(entry.value),
            formattedAmount: formatter.format(entry.value),
            transactionCount: state.transactionCountForCategory(entry.key),
            onTap: () =>
                appRouter.pushNamed(Routes.CATEGORY_DETAILS, extra: {'category': category}),
          );
        },
      ),
    );
  }

  // ─── Charts ───────────────────────────────────────────────────────────────

  Widget _buildCharts(WidgetRef ref, DashboardState state) {
    if (state.categoryTotals.isEmpty) return const SizedBox();
    return Column(
      children: [_buildPieChart(ref, state), const SizedBox(height: 20), _buildMonthlyChart(state)],
    );
  }

  Widget _buildPieChart(WidgetRef ref, DashboardState state) {
    final entries = state.sortedCategoryEntries;
    if (entries.isEmpty) return const SizedBox();

    const colors = [
      Color(0xFF14532D), // Darkest Green (Green 900)
      Color(0xFF166534), // Green 800
      Color(0xFF15803D), // Green 700
      Color(0xFF16A34A), // Green 600
      Color(0xFF22C55E), // Green 500
      Color(0xFF4ADE80), // Green 400
      Color(0xFF86EFAC), // Green 300
      Color(0xFFBBF7D0), // Green 200
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              spacing: 8,
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedPieChart08,
                  size: 20,
                  color: AppColors.brand,
                ),
                Text('Distribution', style: boldText(16, color: AppColors.textPrimary)),
              ],
            ),
          ),
          SizedBox(
            height: 360,
            child: SfCircularChart(
              palette: colors,
              legend: const Legend(
                isVisible: true,
                isResponsive: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                itemPadding: 8,
                padding: 4,
                textStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Text(
                    state.donutCenterText,
                    style: semiBoldText(18, color: AppColors.textPrimary),
                  ),
                ),
              ],
              series: <CircularSeries>[
                DoughnutSeries<dynamic, String>(
                  animationDuration: 1000,
                  dataSource: entries,
                  xValueMapper: (dynamic entry, _) {
                    final key = (entry as MapEntry<String, double>).key;
                    if (key == 'other') return 'Other';
                    return state.getCategoryById(key)?.name ?? '';
                  },
                  yValueMapper: (dynamic entry, _) => (entry as MapEntry<String, double>).value,
                  innerRadius: '50%',
                  radius: '100%',
                  selectionBehavior: SelectionBehavior(enable: true),
                  dataLabelMapper: (dynamic entry, _) {
                    final pct = state.piePercentage((entry as MapEntry<String, double>).value);
                    return '$pct%';
                  },
                  legendIconType: LegendIconType.seriesType,
                  onPointTap: (ChartPointDetails details) {
                    if (details.pointIndex != null) {
                      final tappedEntry = state.sortedCategoryEntries[details.pointIndex!];
                      final value = tappedEntry.value;
                      final pct = state.piePercentage(value);
                      final currentText = ref.read(donutCenterTextProvider);
                      if ('$pct%' == currentText) {
                        ref.read(donutCenterTextProvider.notifier).state = '';
                      } else {
                        ref.read(donutCenterTextProvider.notifier).state = '$pct%';
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(DashboardState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedChartEvaluation,
                  size: 20,
                  color: AppColors.brand,
                ),
                const SizedBox(width: 8),
                Text('Monthly Trend', style: boldText(16, color: AppColors.textPrimary)),
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
                  borderRadius: 8,
                  canShowMarker: false,
                  borderWidth: 0,
                  color: AppColors.brand,
                  textStyle: regularText(12, color: AppColors.white),
                  format: 'Month point.x \n point.y',
                ),
                markerSettings: const TrackballMarkerSettings(
                  markerVisibility: TrackballVisibilityMode.visible,
                  height: 10,
                  width: 10,
                  color: AppColors.brand,
                  borderColor: Colors.white,
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
                labelStyle: regularText(12, color: AppColors.textSecondary),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: AppColors.borderColor,
                  dashArray: <double>[5, 5],
                ),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(width: 0),
                labelStyle: regularText(12, color: AppColors.textSecondary),
                labelFormat: '₹{value}',
              ),
              series: <CartesianSeries>[
                SplineAreaSeries<MapEntry<int, double>, String>(
                  splineType: SplineType.monotonic,
                  dataSource: state.monthlyTotals.entries.toList(),
                  xValueMapper: (entry, _) => entry.key.toString(),
                  yValueMapper: (entry, _) => entry.value,
                  animationDuration: 1000,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brand.withValues(alpha: 0.15),
                      AppColors.brand.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderColor: AppColors.brand.withValues(alpha: 0.5),
                  borderWidth: 2,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 4,
                    width: 4,
                    shape: DataMarkerType.circle,
                    borderColor: AppColors.brand,
                    color: AppColors.white,
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
    return Text(title, style: GoogleFonts.merriweather(fontSize: 18, color: AppColors.textPrimary));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: const Icon(Icons.receipt_long, size: 60, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Text('No expenses yet', style: boldText(20, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses to see data here.',
            style: regularText(14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  static Widget _buildShimmerLoader() {
    const baseColor = AppColors.borderColor;
    const highlightColor = AppColors.surface;
    const backgroundColor = AppColors.background;

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
              Container(
                height: 150,
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
