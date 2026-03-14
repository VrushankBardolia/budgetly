import 'package:budgetly/core/import_to_export.dart';

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
