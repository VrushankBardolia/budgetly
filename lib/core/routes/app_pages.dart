import 'package:budgetly/core/import_to_export.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.INITIAL, page: () => const InitialScreen()),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: Routes.MONTH_DETAILS,
      page: () => const MonthDetailScreen(),
      binding: BindingsBuilder(() {
        Get.put(MonthDetailController());
      }),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationScreen(),
      binding: BindingsBuilder(() {
        Get.put(NotificationController());
      }),
    ),
    GetPage(
      name: Routes.EXPENSE_FORM,
      page: () => const ExpenseFormScreen(),
      binding: BindingsBuilder(() {
        Get.put(ExpenseFormController());
      }),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    GetPage(
      name: Routes.CATEGORY_DETAILS,
      page: () => const CategoryDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.put(CategoryDetailsController());
      }),
    ),
    GetPage(
      name: Routes.SHEET_DETAIL,
      page: () => const SheetDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.put(SheetDetailsController());
      }),
    ),
    GetPage(
      name: Routes.SHEET_RECORD_FORM,
      page: () => const SheetRecordFormScreen(),
      binding: BindingsBuilder(() {
        Get.put(SheetRecordFormController());
      }),
    ),
  ];
}
