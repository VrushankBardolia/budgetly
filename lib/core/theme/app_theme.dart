import 'package:budgetly/core/import_to_export.dart';

ThemeData themeData = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
  scaffoldBackgroundColor: AppColors.black,

  colorScheme: const ColorScheme.dark(
    primary: AppColors.brand,
    onPrimary: Colors.white,
    secondary: AppColors.brandDark,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: Colors.white,
    error: AppColors.error,
  ),

  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.surfaceLight, width: 1),
    ),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.black,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.brand,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.all(16),
    hintStyle: const TextStyle(color: AppColors.hintColor),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.surfaceLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.focusedBorderColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.focusedBorderColor),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderColor),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.brandDark,
    foregroundColor: Colors.white,
    elevation: 2,
  ),

  dividerTheme: const DividerThemeData(
    color: AppColors.surfaceLight,
    thickness: 1,
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    modalBackgroundColor: AppColors.surface,
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.brand),
  ),
);
