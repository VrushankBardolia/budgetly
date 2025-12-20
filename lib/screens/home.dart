import 'package:budgetly/screens/dashboard/dashboardTab.dart';
import 'package:budgetly/screens/months/monthsTab.dart';
import 'package:budgetly/screens/settings/settingTab.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/CategoryProvider.dart';
import '../provider/ExpenseProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final categoryProvider = context.read<CategoryProvider>();
    final expenseProvider = context.read<ExpenseProvider>();

    await categoryProvider.loadCategories();
    await expenseProvider.loadExpenses(expenseProvider.selectedYear);
    await expenseProvider.loadBudgets(expenseProvider.selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardTab(),
      MonthsTab(),
      SettingsTab(),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[_currentIndex],
      bottomNavigationBar: CrystalNavigationBar(
        borderRadius: 200,
        borderWidth: 1,
        // itemPadding: const EdgeInsets.symmetric(vertical: 8),
        paddingR: EdgeInsets.symmetric(horizontal: 24, ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 10
          ),
        ],
        indicatorColor: Colors.transparent,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        splashColor: Colors.transparent,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          CrystalNavigationBarItem(icon: CupertinoIcons.home, ),
          CrystalNavigationBarItem(icon: CupertinoIcons.calendar),
          CrystalNavigationBarItem(icon: CupertinoIcons.gear),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
