import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF1A3C34);       // Deep teal-green
  static const Color primaryDark = Color(0xFF0F2620);
  static const Color accent = Color(0xFFF5A623);        // Amber gold
  static const Color accentLight = Color(0xFFFFF3DC);

  // Backgrounds
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F1B2D);
  static const Color textSecondary = Color(0xFF5E6878);
  static const Color textMuted = Color(0xFF9BA5B4);

  // Status
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFDCFCE7);
  static const Color red = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFEE2E2);
  static const Color orange = Color(0xFFEA580C);
  static const Color orangeLight = Color(0xFFFFEDD5);
  static const Color teal = Color(0xFF0D9488);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color blueLight = Color(0xFFDBEAFE);

  // Borders
  static const Color border = Color(0xFFE8ECF2);
  static const Color divider = Color(0xFFF0F2F7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3C34), Color(0xFF0F2620)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5A623), Color(0xFFE8920F)],
  );
}

class AppText {
  static const String font = 'Helvetica Neue';

  static TextStyle display(double size, {Color? color, FontWeight? weight}) => TextStyle(
    fontSize: size,
    fontWeight: weight ?? FontWeight.w700,
    color: color ?? AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle body(double size, {Color? color, FontWeight? weight}) => TextStyle(
    fontSize: size,
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle label({Color? color, double size = 11, FontWeight? weight}) => TextStyle(
    fontSize: size,
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? AppColors.textMuted,
    letterSpacing: 0.4,
  );
}

ThemeData buildTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      background: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
  );
}
