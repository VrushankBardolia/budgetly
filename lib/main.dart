import 'package:budgetly/core/import_to_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHelper.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  initControllers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Budgetly',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: themeData,
      initialRoute: Routes.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final onboardingCtrl = Get.find<OnboardingController>();

      // If we are still checking the initial auth state, show the loader
      if (onboardingCtrl.isCheckingAuth.value) {
        return const InitialLoaderScreen();
      }

      // If securely authenticated, proceed to Home/AppLock
      if (FirebaseHelper.currentUser != null) {
        if (PreferenceHelper.isEnabledBiometric) {
          return const AppLockScreen();
        }
        return const HomeScreen();
      }

      // Otherwise, show onboarding screen
      return const OnboardingScreen();
    });
  }
}

void initControllers() {
  Get.put(CategoryController());
  Get.put(DashboardController());
  Get.put(SettingController());
  Get.put(MonthController());
  Get.put(HomeController());
  // Note: OnboardingController is kept here because InitialScreen relies on it
  // immediately at startup before any routes are loaded.
  Get.put(OnboardingController());
}
