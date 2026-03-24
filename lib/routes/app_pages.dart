import 'package:budgetly/core/import_to_export.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.INITIAL, page: () => const InitialScreen()),
    GetPage(name: Routes.HOME, page: () => const HomeScreen()),
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingScreen()),
    GetPage(
      name: Routes.MONTH_DETAILS,
      page: () => const MonthDetailScreen(),
      binding: BindingsBuilder(() {
        Get.put(MonthDetailController());
      }),
    ),
    GetPage(name: Routes.NOTIFICATIONS, page: () => const NotificationScreen()),
    GetPage(
      name: Routes.EXPENSE_FORM,
      page: () => const ExpenseFormScreen(),
      binding: BindingsBuilder(() {
        Get.put(ExpenseFormController());
      }),
    ),
  ];
}
