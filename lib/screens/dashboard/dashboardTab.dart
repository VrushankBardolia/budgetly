import 'package:animated_digit/animated_digit.dart';
import 'package:budgetly/screens/months/monthDetailsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/category_controller.dart';
import '../../controller/expense_controller.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List<int> _availableYears = [];
  bool _isLoading = true;
  bool showMonthly = true;

  // Color Palette
  final Color _backgroundColor = const Color(0xFF121212);
  final Color _cardColor = const Color(0xFF1E1E1E);
  final Color _primaryColor = const Color(0xFF2196F3);
  final Color _accentColor = const Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    final expenseController = Get.find<ExpenseController>();
    final years = await expenseController.getYearsWithExpenses();

    if (mounted) {
      setState(() {
        _availableYears = years;
        _isLoading = false;
      });
    }

    if (years.isNotEmpty) {
      if (!years.contains(expenseController.selectedYear)) {
        expenseController.setSelectedYear(years.first);
      }
      await expenseController.loadExpenses(expenseController.selectedYear);
      await expenseController.loadBudgets(expenseController.selectedYear);
    }
  }

  Future<void> _changeYear(int year) async {
    final expenseController = Get.find<ExpenseController>();
    expenseController.setSelectedYear(year);
    await expenseController.loadExpenses(year);
    await expenseController.loadBudgets(year);
  }

  void toggleMonthlyYearly() {
    setState(() {
      showMonthly = !showMonthly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: Text('Budgetly', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeIn,
        child: _isLoading
            ? _buildShimmerLoader()
            : _availableYears.isEmpty
            ? _buildEmptyState()
            : Obx(() {
                final expenseController = Get.find<ExpenseController>();
                final categoryController = Get.find<CategoryController>();

                final categoryTotals = expenseController.getCategoryTotals(expenseController.selectedYear);
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildYearSelector(expenseController),
                      const SizedBox(height: 20),
                      _buildTotalCard(categoryTotals),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Top Categories'),
                      const SizedBox(height: 16),
                      _buildCategoryList(categoryController, categoryTotals),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Analytics'),
                      const SizedBox(height: 16),
                      _buildCharts(categoryController, categoryTotals, expenseController),
                      // const SizedBox(height: 150),
                    ],
                  ),
                );
              }),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    final Color baseColor = const Color(0xFF1E1E1E);
    final Color highlightColor = const Color(0xFF2C2C2C); // Slightly lighter for shine
    final Color backgroundColor = const Color(0xFF121212);
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
              // Year Selector Shimmer
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

              // Total Card Shimmer
              Container(
                height: 180,
                decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(height: 24),

              // Categories Header Shimmer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 120, height: 20, color: baseColor),
                  Container(width: 60, height: 20, color: baseColor),
                ],
              ),
              const SizedBox(height: 16),

              // Category List Items Shimmer (3 items)
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

              // Analytics Header
              Container(width: 100, height: 20, color: baseColor),
              const SizedBox(height: 16),

              // Pie Chart Placeholder
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
            decoration: BoxDecoration(color: _cardColor, shape: BoxShape.circle),
            child: Icon(Icons.receipt_long, size: 60, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text(
            'No expenses yet',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text('Start tracking your expenses to see data here.', style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildYearSelector(ExpenseController expenseController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Year: ", style: TextStyle(color: Colors.grey)),
              DropdownButton<int>(
                value: expenseController.selectedYear,
                dropdownColor: _cardColor,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                underline: const SizedBox(),
                isDense: true,
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                items: _availableYears.map((year) {
                  return DropdownMenuItem(value: year, child: Text(year.toString()));
                }).toList(),
                onChanged: (year) {
                  if (year != null) _changeYear(year);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(Map<String, double> categoryTotals) {
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    final controller = Get.find<ExpenseController>();
    final year = controller.selectedYear;
    final month = DateTime.now().month;
    final monthName = DateFormat.MMMM().format(DateTime.now());
    final currentMonthExpense = controller.getTotalExpenseForMonth(year, month);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF1565C0), const Color(0xFF1E88E5)]),
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

              Spacer(),

              GestureDetector(onTap: toggleMonthlyYearly, child: Text(showMonthly ? "Show Yearly" : "Monthly")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            spacing: 4,
            children: [
              Text('₹', style: GoogleFonts.plusJakartaSans(fontSize: 40, color: Colors.white, height: 1.0)),
              AnimatedDigitWidget(
                value: showMonthly ? currentMonthExpense : total,
                textStyle: GoogleFonts.plusJakartaSans(fontSize: 40, fontStyle: FontStyle.italic, fontWeight: FontWeight.w800, color: Colors.white, height: 1.0, letterSpacing: -2),
                enableSeparator: true,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  final slideAnimation = Tween<Offset>(begin: Offset(-0.1, 0), end: Offset.zero).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slideAnimation, child: child),
                  );
                },
                child: Text(showMonthly ? 'For $monthName $year' : 'For $year', key: ValueKey(showMonthly), style: GoogleFonts.plusJakartaSans(fontSize: 16)),
              ),

              Spacer(),
              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: showMonthly ? 1 : 0,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => MonthDetailScreen(year: year, month: month),
                    ),
                  ),
                  child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight03),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(CategoryController categoryController, Map<String, double> categoryTotals) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (categoryTotals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16)),
        child: const Text(
          'No expenses recorded',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final sortedEntries = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final showOnly3 = sortedEntries.length > 3 ? true : false;

    final displayedEntries = showOnly3 ? sortedEntries.take(3).toList() : sortedEntries;

    final maxVal = sortedEntries.isNotEmpty ? sortedEntries.first.value : 0.0;

    return Column(
      children: displayedEntries.map((entry) {
        final category = categoryController.getCategoryById(entry.key);
        final percentage = maxVal > 0 ? (entry.value / maxVal) : 0.0;

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: _backgroundColor, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(category?.emoji ?? '📦', style: GoogleFonts.plusJakartaSans(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category?.name ?? 'Unknown',
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        Text(
                          formatter.format(entry.value),
                          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: percentage, backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation<Color>(_primaryColor), minHeight: 6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCharts(CategoryController categoryController, Map<String, double> categoryTotals, ExpenseController expenseController) {
    if (categoryTotals.isEmpty) return const SizedBox();

    return Column(children: [_buildPieChart(categoryController, categoryTotals), const SizedBox(height: 20), _buildMonthlyChart(expenseController)]);
  }

  Widget _buildPieChart(CategoryController categoryController, Map<String, double> categoryTotals) {
    if (categoryTotals.isEmpty) return const SizedBox();

    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    // Sort descending
    final sortedEntries = categoryTotals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      const Color(0xFF42A5F5), // Blue
      const Color(0xFF26C6DA), // Cyan
      const Color(0xFF66BB6A), // Green
      const Color(0xFFFFA726), // Orange
      const Color(0xFFEF5350), // Red
      const Color(0xFFAB47BC), // Purple
      const Color(0xFF7E57C2), // Deep Purple
      const Color(0xFFEC407A), // Pink
      const Color(0xFF5C6BC0), // Indigo
      const Color(0xFFFFCA28), // Amber
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            spacing: 8,
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedPieChart08, size: 20, color: _accentColor),
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
                sections: sortedEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final value = data.value;
                  final percentage = (value / total * 100);
                  final color = colors[index % colors.length];

                  return PieChartSectionData(
                    color: color,
                    value: value,
                    title: percentage > 10 ? '${percentage.toStringAsFixed(0)}%' : '',
                    radius: 70,
                    titleStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    // badgePositionPercentageOffset: .98,
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final data = entry.value;
              final categoryId = data.key;
              final category = categoryController.getCategoryById(categoryId)?.name ?? "";
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
                  Text(category, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(ExpenseController expenseController) {
    final monthlyData = <int, double>{};

    for (var i = 1; i <= 12; i++) {
      monthlyData[i] = expenseController.getTotalExpenseForMonth(expenseController.selectedYear, i);
    }

    final maxY = monthlyData.values.isEmpty ? 10000.0 : monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.2; // Add 20% headroom

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedChartEvaluation, size: 20, color: _accentColor),
              const SizedBox(width: 8),
              Text(
                'Monthly Trend',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          // const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.white.withValues(alpha: 0.1), strokeWidth: 1, dashArray: [5, 5]);
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final month = value.toInt();
                        if (month >= 1 && month <= 12) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(month.toString(), style: GoogleFonts.plusJakartaSans(color: Colors.grey[600], fontSize: 12)),
                          );
                        }
                        return const SizedBox();
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
                    color: _primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [_primaryColor.withValues(alpha: 0.3), _primaryColor.withValues(alpha: 0.0)],
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
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final monthIndex = touchedSpot.x.toInt() - 1;
                        final monthName = (monthIndex >= 0 && monthIndex < 12) ? months[monthIndex] : '';

                        return LineTooltipItem('$monthName  •  ₹${touchedSpot.y.toInt()}', GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold));
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
}
