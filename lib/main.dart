import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/provider/AuthProvider.dart';
import '/provider/CategoryProvider.dart';
import '/provider/ExpenseProvider.dart';
import '/screens/home.dart';
import '/screens/onboarding.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
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
            color: const Color(0xFF1E1E1E),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
            ),
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF42A5F5),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(
                fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
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

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF001F42),
            foregroundColor: Colors.white,
            elevation: 2,
          ),

          dividerTheme: const DividerThemeData(
            color: Color(0xFF2C2C2C),
            thickness: 1,
          ),

          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Color(0xFF1E1E1E),
            modalBackgroundColor: Color(0xFF1E1E1E),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ),
        home: const InitialScreen(),
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return authProvider.user != null
            ? const HomeScreen()
            : const OnboardingScreen();
      },
    );
  }
}