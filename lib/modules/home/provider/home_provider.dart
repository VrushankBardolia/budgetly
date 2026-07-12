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
    currentIndex = index;
    notifyListeners();
  }
}
