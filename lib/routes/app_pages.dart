import 'package:get/get.dart';

import '../modules/home.dart';
import '../modules/onboarding.dart';
import '../modules/auth/view/login_screen.dart';
import '../modules/auth/view/signup_screen.dart';
import '../modules/months/month_details_screen.dart';
import '../controller/month_details_controller.dart';
import '../main.dart';
import '../modules/settings/view/notification_screen.dart';

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.INITIAL, page: () => const InitialScreen()),
    GetPage(name: Routes.HOME, page: () => const HomeScreen()),
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingScreen()),
    GetPage(name: Routes.LOGIN, page: () => const LoginScreen()),
    GetPage(name: Routes.SIGNUP, page: () => const SignupScreen()),
    GetPage(
      name: Routes.MONTH_DETAILS,
      page: () => const MonthDetailScreen(),
      binding: BindingsBuilder(() {
        Get.put(MonthDetailController());
      }),
    ),
    GetPage(name: Routes.NOTIFICATIONS, page: () => const NotificationScreen()),
  ];
}
