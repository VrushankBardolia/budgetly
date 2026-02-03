import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import 'controller/auth_controller.dart';
import 'controller/category_controller.dart';
import 'controller/expense_controller.dart';
import '/screens/home.dart';
import '/screens/onboarding.dart';
import 'helper/notification_service.dart';
import 'helper/firebase_options.dart';
import 'core/app_colors.dart';
import 'core/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();

  // Initialize Controllers
  Get.put(AuthController());
  Get.put(CategoryController());
  Get.put(ExpenseController());
  Get.put(Globals());

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

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
        scaffoldBackgroundColor: const Color(0xFF121212),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF42A5F5),
          onPrimary: Colors.white,
          secondary: Color(0xFF001F42),
          onSecondary: Colors.white,
          surface: Color(0xFF1E1E1E),
          onSurface: Color(0xFFE0E0E0),
          background: Color(0xFF121212),
          onBackground: Color(0xFFE0E0E0),
          error: Color(0xFFCF6679),
        ),

        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.white),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brand,
            foregroundColor: AppColors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          contentPadding: const EdgeInsets.all(16),
          hintStyle: const TextStyle(color: Color(0xFF757575)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C2C2C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFA8A8A8), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCF6679)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFA8A8A8), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF707070)),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Color(0xFF001F42), foregroundColor: Colors.white, elevation: 2),

        dividerTheme: const DividerThemeData(color: Color(0xFF2C2C2C), thickness: 1),

        bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Color(0xFF1E1E1E), modalBackgroundColor: Color(0xFF1E1E1E)),

        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: Colors.white)),
      ),
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We can access AuthController because it was put in main
    final AuthController authController = Get.find<AuthController>();

    // Use Obx to listen to reactive changes
    return Obx(() {
      if (authController.isLoading) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return authController.user != null ? const HomeScreen() : const OnboardingScreen();
    });
  }
}
