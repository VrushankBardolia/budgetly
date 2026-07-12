import 'package:flutter/material.dart';

class AppColors {
  // Neutrals & Backgrounds
  static const Color white = Colors.white;
  static const Color black = Color(0xFF0F1115);
  static const Color grey = Color(0xFF8B909A);
  static const Color background = Color(0xFFF7F6F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inverseSurface = Color(0xFF14151A);

  // Brand / Main Colors
  static const Color brand = Color(0xFF14532D);
  static const Color accent = Color(0xFF22C55E);
  static const Color brandDark = Color(0xFF14532D);
  static const Color secondaryAccent = Color(0xFFC9A227);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F1115);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Functional Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);

  // Surface & Borders
  static const Color surfaceLight = Color(0xFFF7F6F3);
  static const Color borderColor = Color(0xFFE8E7E3);
  static const Color hintColor = Color(0xFF9CA3AF);
  static const Color focusedBorderColor = Color(0xFF14532D);

  static LinearGradient get mainCardGradient => const LinearGradient(
    colors: [Color(0xFF14532D), Color(0xFF1B6A3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
