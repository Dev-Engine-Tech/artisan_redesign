import 'package:flutter/material.dart';
import 'package:artisans_circle/core/components/cards/app_card.dart';

/// Information card for displaying static information with an icon
///
/// Commonly used for displaying stats, metrics, or informational items
///
/// Usage:
/// ```dart
/// InfoCard(
///   icon: Icons.attach_money,
///   title: 'Total Earnings',
///   value: '\$1,234',
///   subtitle: 'This month',
/// )
/// ```
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    this.icon,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.valueColor,
    super.key,
  });

  /// The title/label of the information
  final String title;

  /// The main value to display
  final String value;

  /// Optional icon
  final IconData? icon;

  /// Optional subtitle/description
  final String? subtitle;

  /// Optional tap handler
  final VoidCallback? onTap;

  /// Color for the icon
  final Color? iconColor;

  /// Color for the value text
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }
}
