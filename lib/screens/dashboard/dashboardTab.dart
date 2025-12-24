import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../provider/CategoryProvider.dart';
import '../../provider/ExpenseProvider.dart';
import 'categoriesScreen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  List<int> _availableYears = [];
  bool _isLoading = true;

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
    final expenseProvider = context.read<ExpenseProvider>();
    final years = await expenseProvider.getYearsWithExpenses();

    if (mounted) {
      setState(() {
        _availableYears = years;
        _isLoading = false;
      });
    }

    if (years.isNotEmpty) {
      if (!years.contains(expenseProvider.selectedYear)) {
        expenseProvider.setSelectedYear(years.first);
      }
      await expenseProvider.loadExpenses(expenseProvider.selectedYear);
      await expenseProvider.loadBudgets(expenseProvider.selectedYear);
    }
  }

  Future<void> _changeYear(int year) async {
    final expenseProvider = context.read<ExpenseProvider>();
    expenseProvider.setSelectedYear(year);
    await expenseProvider.loadExpenses(year);
    await expenseProvider.loadBudgets(year);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        title: const Text('Budgetly',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : _availableYears.isEmpty
          ? _buildEmptyState()
          : Consumer2<ExpenseProvider, CategoryProvider>(
              builder: (context, expenseProvider, categoryProvider, _) {
                final categoryTotals = expenseProvider.getCategoryTotals(
                  expenseProvider.selectedYear,
                );

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      _buildYearSelector(expenseProvider),
                      const SizedBox(height: 20),
                      _buildTotalCard(categoryTotals),
                      const SizedBox(height: 30),
                      // _buildSectionTitle('Top Categories'),
                      // const SizedBox(height: 16),
                      _buildCategoryList(categoryProvider, categoryTotals),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Analytics'),
                      const SizedBox(height: 16),
                      _buildCharts(
                        categoryProvider,
                        categoryTotals,
                        expenseProvider,
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long, size: 60, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text('No expenses yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text('Start tracking your expenses to see data here.',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(ExpenseProvider expenseProvider) {
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
                value: expenseProvider.selectedYear,
                dropdownColor: _cardColor,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                ),
                underline: const SizedBox(),
                isDense: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                items: _availableYears.map((year) {
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
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
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
              Text('Total Expenses',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(formatter.format(total),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text('for ${context.read<ExpenseProvider>().selectedYear}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    CategoryProvider categoryProvider,
    Map<String, double> categoryTotals,
  ) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (categoryTotals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('No expenses recorded',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final showOnly3 = sortedEntries.length > 3 ? true : false;

    final displayedEntries = showOnly3
        ? sortedEntries.take(3).toList()
        : sortedEntries;

    final maxVal = sortedEntries.isNotEmpty ? sortedEntries.first.value : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text("Top Categories",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if(showOnly3)
              TextButton(
                onPressed: ()=>Navigator.push(context, CupertinoPageRoute(builder: (_)=>CategoriesScreen())),
                style: TextButton.styleFrom(
                  foregroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                ),
                child: Text("View all »"),
              )
          ],
        ),
        const SizedBox(height: 16),

        Column(
          children: displayedEntries.map((entry) {
            final category = categoryProvider.getCategoryById(entry.key);
            final percentage = maxVal > 0 ? (entry.value / maxVal) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category?.emoji ?? '📦',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(category?.name ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(formatter.format(entry.value),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Visual bar indicating expense magnitude relative to highest
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCharts(
    CategoryProvider categoryProvider,
    Map<String, double> categoryTotals,
    ExpenseProvider expenseProvider,
  ) {
    if (categoryTotals.isEmpty) return const SizedBox();

    return Column(
      children: [
        _buildPieChart(categoryProvider, categoryTotals),
        const SizedBox(height: 20),
        _buildMonthlyChart(expenseProvider),
      ],
    );
  }

  Widget _buildPieChart(
    CategoryProvider categoryProvider,
    Map<String, double> categoryTotals,
  ) {
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    final colors = [
      const Color(0xFF42A5F5),
      const Color(0xFF26C6DA),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFFEF5350),
      const Color(0xFFAB47BC),
      const Color(0xFF7E57C2),
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
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_outline, size: 20, color: _accentColor),
              const SizedBox(width: 8),
              const Text('Distribution',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(enabled: true),
                centerSpaceRadius: 40,
                sectionsSpace: 4,
                sections: categoryTotals.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value.value;
                  final percentage = (value / total * 100);
                  final isLargeEnough = percentage > 5;

                  return PieChartSectionData(
                    value: value,
                    title: isLargeEnough
                        ? '${percentage.toStringAsFixed(0)}%'
                        : '',
                    color: colors[index % colors.length],
                    radius: isLargeEnough ? 60 : 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    badgeWidget: isLargeEnough
                        ? null
                        : _buildMiniBadge(colors[index % colors.length]),
                    badgePositionPercentageOffset: .98,
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Wrap(
            spacing: 16,
            runSpacing: 10,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: categoryTotals.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final categoryId = entry.value.key;
              final category = categoryProvider.getCategoryById(categoryId)?.name??"";

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(category,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildMonthlyChart(ExpenseProvider expenseProvider) {
    final monthlyData = <int, double>{};

    for (var i = 1; i <= 12; i++) {
      monthlyData[i] = expenseProvider.getTotalExpenseForMonth(
        expenseProvider.selectedYear,
        i,
      );
    }

    final maxY = monthlyData.values.isEmpty
        ? 10000.0
        : monthlyData.values.reduce((a, b) => a > b ? a : b) *
              1.2; // Add 20% headroom

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
              Icon(Icons.show_chart_rounded, size: 20, color: _accentColor),
              const SizedBox(width: 8),
              const Text(
                'Monthly Trend',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: 0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
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
                            child: Text(month.toString(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),

                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 12,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData.entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: _primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _primaryColor.withValues(alpha: 0.3),
                          _primaryColor.withValues(alpha: 0.0),
                        ],
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
                      const months = [
                        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                      ];
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final monthIndex = touchedSpot.x.toInt() - 1;
                        final monthName = (monthIndex >= 0 && monthIndex < 12)
                            ? months[monthIndex]
                            : '';

                        return LineTooltipItem('$monthName  •  ₹${touchedSpot.y.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
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