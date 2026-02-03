import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:get/get.dart';

import 'catregories/categoriesTab.dart';
import 'dashboard/dashboardTab.dart';
import 'months/monthsTab.dart';
import 'settings/settingTab.dart';
import '../controller/category_controller.dart';
import '../controller/expense_controller.dart';
import '../helper/notification_service.dart';

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
    final categoryController = Get.find<CategoryController>();
    final expenseController = Get.find<ExpenseController>();

    await categoryController.loadCategories();
    // expenseController.selectedYear is an int, passing it to loadExpenses
    await expenseController.loadExpenses(expenseController.selectedYear);
    await expenseController.loadBudgets(expenseController.selectedYear);

    // Check for pending notification navigation
    NotificationService.consumeInitialNotification();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [DashboardTab(), MonthsTab(), CategoriesTab(), SettingsTab()];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(splashColor: Colors.transparent, highlightColor: Colors.transparent),
        child: BottomNavigationBar(
          onTap: (value) {
            HapticFeedback.heavyImpact();
            setState(() => _currentIndex = value);
          },
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 14),
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
              icon: HugeIcon(icon: HugeIcons.strokeRoundedLeftToRightListDash),
              label: 'Categories',
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
