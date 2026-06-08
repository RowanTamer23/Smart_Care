import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A3C34);       // Dark green
  static const Color primaryLight = Color(0xFF2D5A4E);
  static const Color accent = Color(0xFFF5A623);        // Amber/gold
  static const Color accentLight = Color(0xFFFFC85A);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color stable = Color(0xFF10B981);
  static const Color stableLight = Color(0xFFD1FAE5);
  static const Color critical = Color(0xFFEF4444);
  static const Color criticalLight = Color(0xFFFEE2E2);
  static const Color followUp = Color(0xFFF5A623);
  static const Color followUpLight = Color(0xFFFEF3C7);
  static const Color urgent = Color(0xFFEF4444);
  static const Color urgentLight = Color(0xFFFEE2E2);
  static const Color border = Color(0xFFE5E7EB);
  static const Color cardShadow = Color(0x0A000000);
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color tealLight = Color(0xFF4DB6A1);
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
