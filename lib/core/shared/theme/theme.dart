import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF0D3B38);
  static const Color primaryLight = Color(0xFF1A5C57);
  static const Color accent = Color(0xFFF5C518);
  static const Color accentDark = Color(0xFFD4A90E);
  static const Color background = Color(0xFFF5F7F5);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkCard = Color(0xFF0D3B38);
  static const Color textDark = Color(0xFF0D1F1E);
  static const Color textMedium = Color(0xFF4A6663);
  static const Color textLight = Color(0xFF8FA8A5);
  static const Color teal = Color(0xFF3DB8A8);
  static const Color tealLight = Color(0xFFB8E8E3);
  static const Color border = Color(0xFFE0E8E7);
  static const Color inputBg = Color(0xFFF8FAF9);
}

TextStyle logoStyle = GoogleFonts.dmSans(
  color: AppColors.primary,
  fontWeight: FontWeight.w800,
  fontSize: 18,
);

TextStyle lightHeadline = GoogleFonts.dmSans(
  fontWeight: FontWeight.w800,
  fontSize: 24,
  color: AppColors.textLight,
);

TextStyle darkHeadline = GoogleFonts.dmSans(
  fontWeight: FontWeight.w800,
  fontSize: 24,
  color: AppColors.textDark,
);

TextStyle darkTextBody = GoogleFonts.dmSans(
  fontSize: 14,
  color: AppColors.textDark,
);

TextStyle lightTextBody = GoogleFonts.dmSans(
  color: AppColors.textLight,
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

TextStyle tealBody = GoogleFonts.dmSans(
  color: AppColors.teal,
  fontWeight: FontWeight.w700,
  fontSize: 12,
);

TextStyle textHeadline = GoogleFonts.dmSans(
  fontWeight: FontWeight.w800,
  fontSize: 30,
  color: AppColors.textDark,
  height: 1.15,
);

TextStyle primaryBody = GoogleFonts.dmSans(
  fontWeight: FontWeight.w700,
  fontSize: 11,
  color: AppColors.primary,
  letterSpacing: 1.2,
);

TextStyle splashBody = GoogleFonts.dmSans(
  fontSize: 14,
  color: AppColors.textMedium,
);

class Logo extends StatelessWidget {
  final bool dark;
  const Logo({this.dark = true});

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.primary : AppColors.primary;
    return Row(
      children: [
        Icon(Icons.assignment_outlined, color: color, size: 22),
        const SizedBox(width: 6),
        Text(
          'Smart-Care',
          style: logoStyle,
        ),
      ],
    );
  }
}
