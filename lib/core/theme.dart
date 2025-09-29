import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // refined palette to better match the design screenshots
  static const Color orange = Color(0xFFE9692D);
  static const Color lightPeach = Color(0xFFF9E3E0);
  static const Color softPink = Color(0xFFF5DCDC);
  static const Color cardBackground = Color(0xFFFFF6F5); // slightly lighter for cards
  static const Color brownHeader = Color(0xFF6A2F1A); // warmer brown similar to design
  static const Color darkBlue = Color(0xFF213447);
  static const Color danger = Color(0xFFE64A3A);
  static const Color subtleBorder = Color(0xFFF0D9D5);

  // Additional design tokens used by discover/other widgets
  static const Color softPeach = Color(0xFFFFF2EF);
  static const Color softBorder = Color(0xFFF7E7E5);
  static const Color disabledOrange = Color(0xFFB85A38);
  static const Color badgeBackground = Color(0xFFFFECE8);
}

class AppThemes {
  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightPeach,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        brightness: Brightness.light,
        primary: AppColors.orange,
        secondary: AppColors.darkBlue,
        surface: AppColors.cardBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brownHeader,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.orange,
          side: const BorderSide(color: AppColors.subtleBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        // Slightly larger title for better visual hierarchy, and adjusted body sizes
        titleLarge: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.brownHeader),
        bodyLarge: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        headlineLarge: GoogleFonts.poppins(
            fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.brownHeader),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.subtleBorder),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF1E1B18),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        brightness: Brightness.dark,
        primary: AppColors.orange,
        secondary: AppColors.darkBlue,
        surface: const Color(0xFF2A2623),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.brownHeader,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        titleLarge:
            GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2623),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
