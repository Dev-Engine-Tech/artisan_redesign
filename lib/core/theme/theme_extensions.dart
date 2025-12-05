import 'package:flutter/material.dart';
import '../theme.dart';

/// Theme extension utilities for consistent spacing, colors, and styling
/// Use these instead of hardcoding values
extension AppThemeExtension on BuildContext {
  /// Get the current theme
  ThemeData get theme => Theme.of(this);

  /// Get the current color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get the current text theme
  TextTheme get textTheme => theme.textTheme;

  // Color getters - theme-aware colors
  bool get isDarkMode => theme.brightness == Brightness.dark;

  Color get primaryColor => AppColors.orange;
  Color get lightPeachColor => isDarkMode ? colorScheme.surfaceContainerHighest : AppColors.lightPeach;
  Color get softPinkColor => isDarkMode ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.7) : AppColors.softPink;
  Color get cardBackgroundColor => colorScheme.surface;
  Color get brownHeaderColor => isDarkMode ? const Color(0xFFD4A574) : AppColors.brownHeader;
  Color get darkBlueColor => isDarkMode ? const Color(0xFF8FA3B8) : AppColors.darkBlue;
  Color get dangerColor => AppColors.danger;
  Color get subtleBorderColor => colorScheme.outlineVariant;
  Color get softPeachColor => isDarkMode ? const Color(0xFF2D2522) : AppColors.softPeach;
  Color get softBorderColor => colorScheme.outlineVariant;
  Color get disabledOrangeColor => AppColors.disabledOrange;
  Color get badgeBackgroundColor => isDarkMode ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : AppColors.badgeBackground;

  // Spacing constants
  EdgeInsets get padding4 => AppSpacing.paddingXS;
  EdgeInsets get padding6 => const EdgeInsets.all(6);
  EdgeInsets get padding8 => AppSpacing.paddingSM;
  EdgeInsets get padding10 => const EdgeInsets.all(10);
  EdgeInsets get padding12 => AppSpacing.paddingMD;
  EdgeInsets get padding14 => const EdgeInsets.all(14);
  EdgeInsets get padding16 => AppSpacing.paddingLG;
  EdgeInsets get padding18 => const EdgeInsets.all(18);
  EdgeInsets get padding20 => AppSpacing.paddingXL;
  EdgeInsets get padding24 => AppSpacing.paddingXXL;

  // Horizontal padding
  EdgeInsets get paddingH8 => AppSpacing.horizontalSM;
  EdgeInsets get paddingH12 => AppSpacing.horizontalMD;
  EdgeInsets get paddingH16 => AppSpacing.horizontalLG;
  EdgeInsets get paddingH18 => const EdgeInsets.symmetric(horizontal: 18);
  EdgeInsets get paddingH20 => AppSpacing.horizontalXL;

  // Vertical padding
  EdgeInsets get paddingV4 => AppSpacing.verticalXS;
  EdgeInsets get paddingV6 => const EdgeInsets.symmetric(vertical: 6);
  EdgeInsets get paddingV8 => AppSpacing.verticalSM;
  EdgeInsets get paddingV12 => AppSpacing.verticalMD;
  EdgeInsets get paddingV16 => AppSpacing.verticalLG;
  EdgeInsets get paddingV20 => AppSpacing.verticalXL;

  // Border radius
  BorderRadius get borderRadius4 => AppRadius.radiusSM;
  BorderRadius get borderRadius6 => BorderRadius.circular(6);
  BorderRadius get borderRadius8 => AppRadius.radiusMD;
  BorderRadius get borderRadius10 => BorderRadius.circular(10);
  BorderRadius get borderRadius12 => AppRadius.radiusLG;
  BorderRadius get borderRadius16 => AppRadius.radiusXL;
  BorderRadius get borderRadius20 => AppRadius.radiusXXL;

  // Size helpers
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Spacing constants - use these instead of hardcoding EdgeInsets
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Padding presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);

  // Horizontal padding
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(horizontal: xxl);

  // Vertical padding
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: xxl);

  // SizedBox helpers
  static const SizedBox spaceXS = SizedBox(height: xs, width: xs);
  static const SizedBox spaceSM = SizedBox(height: sm, width: sm);
  static const SizedBox spaceMD = SizedBox(height: md, width: md);
  static const SizedBox spaceLG = SizedBox(height: lg, width: lg);
  static const SizedBox spaceXL = SizedBox(height: xl, width: xl);
  static const SizedBox spaceXXL = SizedBox(height: xxl, width: xxl);
  static const SizedBox spaceXXXL = SizedBox(height: xxxl, width: xxxl);
}

/// Border radius constants
class AppRadius {
  AppRadius._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;

  static BorderRadius get radiusSM => BorderRadius.circular(sm);
  static BorderRadius get radiusMD => BorderRadius.circular(md);
  static BorderRadius get radiusLG => BorderRadius.circular(lg);
  static BorderRadius get radiusXL => BorderRadius.circular(xl);
  static BorderRadius get radiusXXL => BorderRadius.circular(xxl);
  static BorderRadius get radiusXXXL => BorderRadius.circular(xxxl);
}
