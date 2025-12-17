import 'package:budgetly/provider/AuthProvider.dart';
import 'package:budgetly/provider/CategoryProvider.dart';
import 'package:budgetly/provider/ExpenseProvider.dart';
import 'package:budgetly/screens/home.dart';
import 'package:budgetly/screens/onboarding.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

        // STRICT DARK & GREY THEME WITH NAVY ACCENTS
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,

          fontFamily: GoogleFonts.plusJakartaSans().fontFamily,

          // 1. Backgrounds: Pure Neutral Dark Grays
          // Darker than standard material dark for that "OLED" feel
          scaffoldBackgroundColor: const Color(0xFF121212),

          colorScheme: const ColorScheme.dark(
            // PRIMARY: Deep Navy Blue (Used for buttons/active states)
            // primary: Color(0xFF001F42), // Rich Deep Blue
            primary: Color(0xFF42A5F5), // Rich Deep Blue
            onPrimary: Colors.white,    // White text on blue buttons

            // SECONDARY: Subtle Gray-Blue (For secondary accents/toggles)
            // secondary: Color(0xFF42A5F5),
            secondary: Color(0xFF001F42),
            onSecondary: Colors.white,

            // SURFACE: Neutral Dark Gray (No blue tint)
            surface: Color(0xFF1E1E1E),
            onSurface: Color(0xFFE0E0E0), // Light Gray text (easier on eyes than pure white)

            // BACKGROUND
            background: Color(0xFF121212),
            onBackground: Color(0xFFE0E0E0),

            error: Color(0xFFCF6679),
          ),

          // 2. Card Theme: Distinct Gray to separate from black background
          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E1E),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              // A thin dark gray border defines the edges without using color
              side: const BorderSide(color: Color(0xFF2C2C2C), width: 1),
            ),
          ),

          // 3. AppBar: Blends into the background (Clean look)
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF121212),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),

          // 4. Buttons: The "Pop" of Navy Blue
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF42A5F5), // The Navy Accent
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Slightly boxier for a "Tech" feel
              ),
              textStyle: TextStyle(
                fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 5. Text Fields: Dark Gray background, Focused border gets the Navy Blue
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1E1E1E), // Matches Cards
            contentPadding: const EdgeInsets.all(16),
            hintStyle: const TextStyle(color: Color(0xFF757575)), // Medium Gray

            // Default border (Idle)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2C2C2C)), // Dark Gray border
            ),
            // Focused border (Active) -> This is where color appears
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFA8A8A8), width: 2), // Navy Blue glow
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

          // 6. Floating Action Button: High Visibility Navy
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF001F42),
            foregroundColor: Colors.white,
            elevation: 2,
          ),

          // 7. Divider: Very subtle gray line
          dividerTheme: const DividerThemeData(
            color: Color(0xFF2C2C2C),
            thickness: 1,
          ),

          // 8. Bottom Sheet
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
