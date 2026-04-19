import 'package:budgetly/core/import_to_export.dart';

class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;

  final screens = [DashboardTab(), MonthsTab(), CategoriesTab(), SheetsTab(), SettingsTab()];

  @override
  void onInit() {
    super.onInit();
    NotificationService.consumeInitialNotification();
  }

  void changeIndex(int index) {
    switch (index) {
      case 0: // DASHBOARD TAB
        Get.find<DashboardController>().loadData();
        break;
      case 1: // MONTHS TAB
        Get.find<MonthController>().loadData();
        break;
      case 2: // CATEGORIES TAB
        Get.find<CategoryController>().loadCategories();
        break;
      case 3: // SHEETS TAB
        Get.find<SheetsController>().loadSheets();
        break;
      case 4: // SETTINGS TAB
        Get.find<SettingController>().loadUserData();
        break;
    }
    currentIndex.value = index;
  }
}
