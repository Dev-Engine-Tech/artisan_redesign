import 'package:flutter/material.dart';

/// Responsive utility for handling different screen sizes
/// Provides breakpoints and helper methods for mobile, tablet, and desktop layouts
class Responsive {
  // Breakpoint constants
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1025;

  // Tablet-specific breakpoints
  static const double tabletSmallMaxWidth = 768;
  static const double tabletLargeMinWidth = 769;

  /// Check if current device is mobile (width < 600)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxWidth;

  /// Check if current device is tablet (600 <= width <= 1024)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width <= tabletMaxWidth;
  }

  /// Check if current device is small tablet (600 <= width <= 768)
  static bool isSmallTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width <= tabletSmallMaxWidth;
  }

  /// Check if current device is large tablet (768 < width <= 1024)
  static bool isLargeTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > tabletSmallMaxWidth && width <= tabletMaxWidth;
  }

  /// Check if current device is desktop (width > 1024)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMaxWidth;

  /// Check if device is tablet or larger
  static bool isTabletOrDesktop(BuildContext context) => !isMobile(context);

  /// Get screen width
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Get screen height
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Get value based on screen size
  /// Returns mobile value for mobile, tablet for tablet, desktop for desktop
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }

  /// Get responsive horizontal padding
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 48;
    if (isTablet(context)) return 32;
    return 16;
  }

  /// Get responsive vertical padding
  static double verticalPadding(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 20;
    return 12;
  }

  /// Get grid cross axis count based on screen size
  static int gridCrossAxisCount(
    BuildContext context, {
    int mobile = 2,
    int? tablet,
    int? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double baseFontSize) {
    if (isDesktop(context)) return baseFontSize * 1.2;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize;
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) return baseSize * 1.3;
    if (isTablet(context)) return baseSize * 1.15;
    return baseSize;
  }

  /// Get responsive border radius
  static double borderRadius(BuildContext context, double baseRadius) {
    if (isDesktop(context)) return baseRadius * 1.2;
    if (isTablet(context)) return baseRadius * 1.1;
    return baseRadius;
  }

  /// Get maximum content width for centered layouts
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isLargeTablet(context)) return 900;
    if (isSmallTablet(context)) return 700;
    return double.infinity;
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get responsive spacing
  static double spacing(BuildContext context, double baseSpacing) {
    if (isDesktop(context)) return baseSpacing * 1.5;
    if (isTablet(context)) return baseSpacing * 1.25;
    return baseSpacing;
  }

  /// Get number of columns for responsive grid
  static int columns(BuildContext context) {
    if (isDesktop(context)) return 12;
    if (isLargeTablet(context)) return 8;
    if (isSmallTablet(context)) return 6;
    return 4;
  }

  /// Get card elevation based on screen size
  static double cardElevation(BuildContext context) {
    if (isTabletOrDesktop(context)) return 2;
    return 1;
  }

  /// Get dialog max width
  static double dialogMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 600;
    if (isTablet(context)) return 500;
    return width(context) * 0.9;
  }

  /// Get modal bottom sheet max height
  static double modalMaxHeight(BuildContext context) {
    return height(context) * (isTablet(context) ? 0.7 : 0.85);
  }
}

/// Extension on BuildContext for easier access to responsive methods
extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isSmallTablet => Responsive.isSmallTablet(this);
  bool get isLargeTablet => Responsive.isLargeTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isTabletOrDesktop => Responsive.isTabletOrDesktop(this);
  bool get isLandscape => Responsive.isLandscape(this);
  bool get isPortrait => Responsive.isPortrait(this);

  double get screenWidth => Responsive.width(this);
  double get screenHeight => Responsive.height(this);
  double get maxContentWidth => Responsive.maxContentWidth(this);

  EdgeInsets get responsivePadding => Responsive.padding(this);
  double get horizontalPadding => Responsive.horizontalPadding(this);
  double get verticalPadding => Responsive.verticalPadding(this);

  int gridColumns({int mobile = 2, int? tablet, int? desktop}) =>
      Responsive.gridCrossAxisCount(this,
          mobile: mobile, tablet: tablet, desktop: desktop);

  double responsiveFontSize(double base) => Responsive.fontSize(this, base);
  double responsiveIconSize(double base) => Responsive.iconSize(this, base);
  double responsiveBorderRadius(double base) =>
      Responsive.borderRadius(this, base);
  double responsiveSpacing(double base) => Responsive.spacing(this, base);
}

/// Responsive builder widget for complex layouts
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
      mobile;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      tablet;
  final Widget Function(BuildContext context, BoxConstraints constraints)?
      desktop;

  const ResponsiveBuilder({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > Responsive.tabletMaxWidth &&
            desktop != null) {
          return desktop!(context, constraints);
        }
        if (constraints.maxWidth >= Responsive.mobileMaxWidth &&
            tablet != null) {
          return tablet!(context, constraints);
        }
        return mobile(context, constraints);
      },
    );
  }
}

/// Responsive layout widget with automatic layout switching
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > Responsive.tabletMaxWidth &&
            desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= Responsive.mobileMaxWidth &&
            tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Centered content with max width for tablet and desktop
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContent({
    required this.child,
    super.key,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? Responsive.maxContentWidth(context);
    final effectivePadding = padding ?? Responsive.padding(context);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        padding: effectivePadding,
        child: child,
      ),
    );
  }
}

/// Responsive grid view with automatic column count
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    required this.children,
    super.key,
    this.mobileColumns = 2,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridCrossAxisCount(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns ?? (mobileColumns * 1.5).round(),
      desktop: desktopColumns ?? (mobileColumns * 2),
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: children,
    );
  }
}
