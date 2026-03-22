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
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      if (authController.isLoading.value) {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (FirebaseHelper.currentUser != null) {
        if (PreferenceHelper.isEnabledBiometric) {
          return const AppLockScreen();
        }
        return const HomeScreen();
      }
      return const OnboardingScreen();
    });
  }
}

void initControllers() {
  Get.put(AuthController());
  Get.put(CategoryController());
  Get.put(ExpenseController());
  Get.put(DashboardController());
  Get.put(SettingController());
  Get.lazyPut(() => NotificationController(), fenix: true);
  Get.put(MonthController());
  Get.put(HomeController());
  Get.put(OnboardingController());
}
