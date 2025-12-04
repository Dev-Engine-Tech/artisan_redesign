import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/theme_extensions.dart';

export 'theme/theme_extensions.dart';

class AppColors {
  // refined palette to better match the design screenshots
  static const Color orange = Color(0xFFE9692D);
  static const Color lightPeach = Color(0xFFF9E3E0);
  static const Color softPink = Color(0xFFF5DCDC);
  static const Color cardBackground =
      Color(0xFFFFF6F5); // slightly lighter for cards
  static const Color brownHeader =
      Color(0xFF6A2F1A); // warmer brown similar to design
  static const Color darkBlue = Color(0xFF213447);
  static const Color danger = Color(0xFFE64A3A);
  static const Color subtleBorder = Color(0xFFF0D9D5);

  // Additional design tokens used by discover/other widgets
  static const Color softPeach = Color(0xFFFFF2EF);
  static const Color softBorder = Color(0xFFF7E7E5);
  static const Color disabledOrange = Color(0xFFB85A38);
  static const Color badgeBackground = Color(0xFFFFECE8);

  // Status and semantic colors
  static const Color green = Color(0xFF2E8B57);
  static const Color blue = Color(0xFF3B82F6);
  static const Color cyan = Color(0xFF0EA5E9);
  static const Color purple = Color(0xFF6B4CD6);
  static const Color pink = Color(0xFFE91E63);
  static const Color amber = Color(0xFFFFC107);
  static const Color grey = Color(0xFF9E9E9E);

  // Light variants for backgrounds
  static const Color lightBlue = Color(0xFFE8F4FD);
  static const Color lightCyan = Color(0xFFF0F9FF);
  static const Color lightOrange = Color(0xFFFEF3E2);
  static const Color lightGrey = Color(0xFFF5F5F5);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

class AppThemes {
  static ThemeData lightTheme() {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightPeach,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        // Primary colors
        primary: AppColors.orange,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFFFEBE5),
        onPrimaryContainer: Color(0xFF3A1100),

        // Secondary colors
        secondary: AppColors.darkBlue,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD4E3F3),
        onSecondaryContainer: Color(0xFF0C1B2A),

        // Tertiary colors
        tertiary: Color(0xFF705E4D),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFF9E2CD),
        onTertiaryContainer: Color(0xFF271A0E),

        // Error colors
        error: AppColors.danger,
        onError: Colors.white,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),

        // Surface colors
        surface: AppColors.cardBackground,
        onSurface: Color(0xFF1F1B19),
        surfaceContainerHighest: Color(0xFFE8E1DD),
        onSurfaceVariant: Color(0xFF524441),

        // Outline and shadow
        outline: Color(0xFF857370),
        outlineVariant: Color(0xFFD7C2BD),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),

        // Inverse colors
        inverseSurface: Color(0xFF34302E),
        onInverseSurface: Color(0xFFF9EFE8),
        inversePrimary: Color(0xFFFFB59B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brownHeader,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.orange,
          side: const BorderSide(color: AppColors.subtleBorder),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        // Slightly larger title for better visual hierarchy, and adjusted body sizes
        titleLarge: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.brownHeader),
        bodyLarge: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
        headlineLarge: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.brownHeader),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.subtleBorder),
          borderRadius: AppRadius.radiusMD,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF1E1B18),
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        // Primary colors
        primary: AppColors.orange,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF5A2310),
        onPrimaryContainer: Color(0xFFFFDDD1),

        // Secondary colors
        secondary: AppColors.darkBlue,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF1A2A39),
        onSecondaryContainer: Color(0xFFD4E3F3),

        // Tertiary colors
        tertiary: Color(0xFFB8A88F),
        onTertiary: Color(0xFF2E2619),
        tertiaryContainer: Color(0xFF453C2E),
        onTertiaryContainer: Color(0xFFD5C7A9),

        // Error colors
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),

        // Surface colors
        surface: Color(0xFF2A2623),
        onSurface: Color(0xFFE8E1DD),
        surfaceContainerHighest: Color(0xFF3C3733),
        onSurfaceVariant: Color(0xFFD2C4BF),

        // Outline and shadow
        outline: Color(0xFF9B8E89),
        outlineVariant: Color(0xFF524441),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),

        // Inverse colors
        inverseSurface: Color(0xFFE8E1DD),
        onInverseSurface: Color(0xFF322F2C),
        inversePrimary: AppColors.orange,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brownHeader,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2A2623),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMD,
          ),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2623),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: AppRadius.radiusMD,
        ),
      ),
    );
  }
}
