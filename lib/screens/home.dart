import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboardTab.dart';
import 'months/monthsTab.dart';
import 'settings/settingTab.dart';
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
    final screens = [DashboardTab(), MonthsTab(), SettingsTab()];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent
        ),
        child: BottomNavigationBar(
          onTap: (value) {
            HapticFeedback.heavyImpact();
            setState(() => _currentIndex = value);
          },
          currentIndex: _currentIndex,
          unselectedItemColor: Colors.grey.shade700,
          backgroundColor: Theme.of(context).colorScheme.background,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: [
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedHome11),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
              label: 'Months',
            ),
            BottomNavigationBarItem(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings01),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
