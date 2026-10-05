import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFF4F4F4);
  static const ink = Color(0xFF111111);
  static const coral = Color(0xFFF2694D);
  static const blue = Color(0xFF4C84F0);
  static const yellow = Color(0xFFFFC043);
  static const teal = Color(0xFF4CBFBF);
  static const red = Color(0xFFF0685A);
  static const muted = Color(0xFF8C8C8C);
  static const chip = Color(0xFFEAEAEA);
}

/// Bold black outline + hard offset shadow, as in the reference cards.
BoxDecoration neoBox({Color color = Colors.white, double radius = 16}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.ink, width: 1.5),
    boxShadow: const [BoxShadow(color: AppColors.ink, offset: Offset(0, 4))],
  );
}

class AppTheme {
  static OutlineInputBorder _border(Color c, [double w = 1.5]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        primary: AppColors.coral,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
        errorStyle: GoogleFonts.poppins(fontSize: 11, color: AppColors.red),
        border: _border(AppColors.ink),
        enabledBorder: _border(AppColors.ink),
        focusedBorder: _border(AppColors.coral, 2),
        errorBorder: _border(AppColors.red),
        focusedErrorBorder: _border(AppColors.red, 2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
