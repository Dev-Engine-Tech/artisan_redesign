import 'package:flutter/material.dart';
import '../theme.dart';

/// Primary button with orange background - use for main CTAs
///
/// Example:
/// ```dart
/// PrimaryButton(
///   text: 'Login',
///   onPressed: () => _handleLogin(),
/// )
/// ```
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.width,
    this.borderRadius = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(builder: (context, constraints) {
      final button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: AppColors.disabledOrange,
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: padding ?? AppSpacing.horizontalXXL,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      AppSpacing.spaceSM,
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      );
      if (width != null) {
        return SizedBox(height: height, width: width, child: button);
      }
      // Avoid forcing infinite width in unbounded contexts (e.g., inside Row)
      if (constraints.hasBoundedWidth) {
        return SizedBox(height: height, width: double.infinity, child: button);
      }
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: button,
      );
    });
  }
}

/// Secondary button with custom background color
///
/// Example:
/// ```dart
/// SecondaryButton(
///   text: 'Accept Agreement',
///   backgroundColor: Colors.green,
///   onPressed: () => _handleAccept(),
/// )
/// ```
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  SecondaryButton({
    required this.text,
    super.key,
    this.onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.width,
    this.borderRadius = 12,
    this.padding,
  })  : backgroundColor = backgroundColor ?? AppColors.darkBlue,
        foregroundColor = foregroundColor ?? AppColors.darkBlue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      AppSpacing.spaceSM,
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      );
      if (width != null) {
        return SizedBox(height: height, width: width, child: button);
      }
      if (constraints.hasBoundedWidth) {
        return SizedBox(height: height, width: double.infinity, child: button);
      }
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: button,
      );
    });
  }
}

/// Outlined button with border - use for secondary actions
///
/// Example:
/// ```dart
/// OutlinedAppButton(
///   text: 'Request Changes',
///   onPressed: () => _handleRequestChanges(),
/// )
/// ```
class OutlinedAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color foregroundColor;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;

  const OutlinedAppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.borderColor = AppColors.orange,
    this.foregroundColor = AppColors.orange,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.width,
    this.borderRadius = 12,
    this.borderWidth = 1.5,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 20),
                      AppSpacing.spaceSM,
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
      );
      if (width != null) {
        return SizedBox(height: height, width: width, child: button);
      }
      if (constraints.hasBoundedWidth) {
        return SizedBox(height: height, width: double.infinity, child: button);
      }
      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: height),
        child: button,
      );
    });
  }
}

/// Text button with no background - use for tertiary actions
///
/// Example:
/// ```dart
/// TextAppButton(
///   text: 'Cancel',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class TextAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color foregroundColor;
  final bool isLoading;
  final IconData? icon;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const TextAppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.foregroundColor = AppColors.orange,
    this.isLoading = false,
    this.icon,
    this.height,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
              ),
            )
          : icon != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20),
                    AppSpacing.spaceSM,
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
    );

    if (height != null || width != null) {
      return SizedBox(
        height: height,
        width: width,
        child: button,
      );
    }

    return button;
  }
}

/// Icon button with consistent styling
///
/// Example:
/// ```dart
/// AppIconButton(
///   icon: Icons.close,
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;

  const AppIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.iconSize = 24,
    this.padding,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      color: color ?? colorScheme.primary,
      padding: padding ?? EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      style: backgroundColor != null
          ? IconButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
              ),
            )
          : null,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
