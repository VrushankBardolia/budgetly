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

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    final expenseProvider = context.read<ExpenseProvider>();
    final years = await expenseProvider.getYearsWithExpenses();

    setState(() {
      _availableYears = years;
      _isLoading = false;
    });

    // ✅ Always loads expenses for selected/current year
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
      appBar: AppBar(
        title: const Text('Budgetly'),
        actions: [
          TextButton(
            child: const Text("Categories"),
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
          ? const Center(child: CircularProgressIndicator(color: Colors.white,))
          : _availableYears.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Start tracking your expenses',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : Consumer2<ExpenseProvider, CategoryProvider>(
              builder: (context, expenseProvider, categoryProvider, _) {
                final categoryTotals = expenseProvider.getCategoryTotals(
                  expenseProvider.selectedYear,
                );

                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildYearSelector(expenseProvider),
                      const SizedBox(height: 24),
                      _buildTotalCard(categoryTotals),
                      const SizedBox(height: 24),
                      _buildCategoryList(categoryProvider, categoryTotals),
                      const SizedBox(height: 24),
                      _buildCharts(
                        categoryProvider,
                        categoryTotals,
                        expenseProvider,
                      ),
                      SizedBox(height: 120,)
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildYearSelector(ExpenseProvider expenseProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: expenseProvider.selectedYear,
        isExpanded: true,
        style: TextStyle(
          fontSize: 20
        ),
        underline: const SizedBox(),
        items: _availableYears.map((year) {
          return DropdownMenuItem(value: year, child: Text(year.toString()));
        }).toList(),
        onChanged: (year) {
          if (year != null) _changeYear(year);
        },
      ),
    );
  }

  Widget _buildTotalCard(Map<String, double> categoryTotals) {
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Total Expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(total),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF2196F3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    CategoryProvider categoryProvider,
    Map<String, double> categoryTotals,
  ) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (categoryTotals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No expenses in this year', textAlign: TextAlign.center),
        ),
      );
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...sortedEntries.map((entry) {
          final category = categoryProvider.getCategoryById(entry.key);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Text(
                category?.emoji ?? '📦',
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(category?.name ?? 'Unknown'),
              trailing: Text(
                formatter.format(entry.value),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          );
        }),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Charts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        _buildPieChart(categoryProvider, categoryTotals),
        const SizedBox(height: 24),
        _buildMonthlyChart(expenseProvider),
      ],
    );
  }

  Widget _buildPieChart(
    CategoryProvider categoryProvider,
    Map<String, double> categoryTotals,
  ) {
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    final blueColors = [
      const Color(0xFF0D47A1),
      const Color(0xFF1565C0),
      const Color(0xFF1976D2),
      const Color(0xFF1E88E5),
      const Color(0xFF2196F3),
      const Color(0xFF42A5F5),
      const Color(0xFF64B5F6),
      const Color(0xFF90CAF9),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Category Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(enabled: true),
                  sections: categoryTotals.entries.toList().asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final category = categoryProvider
                          .getCategoryById(entry.value.key)
                          ?.name;
                      final value = entry.value.value;
                      final percentage = (value / total * 100).toStringAsFixed(
                        1,
                      );

                      return PieChartSectionData(
                        value: value,
                        title: '$percentage%\n$category',
                        color: blueColors[index % blueColors.length],
                        radius: 100,
                        // showTitle: true,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ).toList(),
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
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
        : monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Monthly Expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return const FlLine(
                        color: Color(0xFF2C2C2C),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return const FlLine(
                        color: Color(0xFF2C2C2C),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value >= 1 && value <= 12) {
                              return Text(value.toInt().toString());
                            }
                            return const SizedBox();
                          }

                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Color(0xFF2C2C2C)),
                  ),
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
                      color: const Color(0xFF2196F3),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF2196F3),
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF1E1E1E),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [Color(0xFF2196F3).withOpacity(0.2),Color(0xFF2196F3).withOpacity(0),],
                          begin: AlignmentGeometry.topCenter,
                          end: AlignmentGeometry.bottomCenter
                        ),
                        // color: const Color(0xFF2196F3).withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
