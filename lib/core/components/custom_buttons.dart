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
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabledOrange,
          disabledForegroundColor: Colors.white70,
          minimumSize: Size(width ?? 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: padding ?? AppSpacing.horizontalXXL,
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
      ),
    );
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

  const SecondaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.backgroundColor = AppColors.darkBlue,
    this.foregroundColor = Colors.white,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.width,
    this.borderRadius = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.7),
          minimumSize: Size(width ?? 0, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          // Use smaller vertical padding so short buttons (e.g., height 40)
          // render text without clipping.
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      ),
    );
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
    return SizedBox(
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor, width: borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size(width ?? 0, height),
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ),
    );
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
    final button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      color: color ?? AppColors.orange,
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
