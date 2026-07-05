import 'package:budgetly/core/import_to_export.dart';

class HomeProvider extends ChangeNotifier {
  final Ref ref;
  int currentIndex = 0;

  final screens = [
    const DashboardTab(),
    const MonthsTab(),
    const CategoriesTab(),
    const SheetsTab(),
    const SettingsTab(),
  ];

  HomeProvider(this.ref) {
    NotificationService.consumeInitialNotification();
  }

  void changeIndex(int index) {
    switch (index) {
      case 0: // DASHBOARD TAB
        ref.read(dashboardProvider).loadData();
        break;
      case 1: // MONTHS TAB
        ref.read(monthProvider).loadData();
        break;
      case 2: // CATEGORIES TAB
        ref.read(categoryProvider).loadCategories();
        break;
      case 3: // SHEETS TAB
        ref.read(sheetsProvider).loadSheets();
        break;
      case 4: // SETTINGS TAB
        ref.read(settingProvider).loadUserData();
        break;
    }
    currentIndex = index;
    notifyListeners();
  }
}
