import 'package:flutter/material.dart';
import 'package:artisans_circle/core/components/cards/app_card.dart';

/// List item card for displaying items in a list with optional actions
///
/// Commonly used for list views with title, subtitle, and optional metadata
///
/// Usage:
/// ```dart
/// ListCard(
///   title: 'Job Title',
///   subtitle: 'Description of the job',
///   leading: Icon(Icons.work),
///   trailing: Text('\$500'),
///   metadata: ['Remote', 'Full-time'],
///   onTap: () => print('Card tapped'),
/// )
/// ```
class ListCard extends StatelessWidget {
  const ListCard({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.metadata,
    this.badge,
    this.onTap,
    super.key,
  });

  /// Main title
  final String title;

  /// Optional subtitle/description
  final String? subtitle;

  /// Optional leading widget (icon, image, avatar)
  final Widget? leading;

  /// Optional trailing widget (price, icon, etc.)
  final Widget? trailing;

  /// Optional metadata tags/chips
  final List<String>? metadata;

  /// Optional badge (status indicator)
  final Widget? badge;

  /// Tap handler
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      badge!,
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (metadata != null && metadata!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: metadata!
                        .map((tag) => _MetadataChip(label: tag))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 11,
        ),
      ),
    );
  }
}
