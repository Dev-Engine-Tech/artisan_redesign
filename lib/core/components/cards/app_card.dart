import 'package:flutter/material.dart';

/// Base card component for consistent styling across the app
///
/// This widget provides a reusable card foundation with:
/// - Consistent padding, border radius, and shadows
/// - Optional tap handler
/// - Customizable background color
/// - Support for title and trailing widgets
///
/// Usage:
/// ```dart
/// AppCard(
///   onTap: () => print('Card tapped'),
///   title: 'Card Title',
///   child: Text('Card content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.border,
    super.key,
  });

  /// The main content of the card
  final Widget child;

  /// Optional title displayed at the top of the card
  final String? title;

  /// Optional widget displayed at the top-right of the card
  final Widget? trailing;

  /// Callback when the card is tapped (makes card interactive)
  final VoidCallback? onTap;

  /// Internal padding (default: EdgeInsets.all(16))
  final EdgeInsetsGeometry? padding;

  /// Background color (default: theme surface color)
  final Color? backgroundColor;

  /// Border radius (default: 12)
  final BorderRadius? borderRadius;

  /// Card elevation/shadow depth (default: 2)
  final double? elevation;

  /// Optional border
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);
    final effectivePadding = padding ?? const EdgeInsets.all(16);
    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface;

    Widget cardContent = Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: border,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: elevation ?? 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: effectivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || trailing != null) _buildHeader(context),
            if (title != null || trailing != null) const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (title != null)
          Expanded(
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
