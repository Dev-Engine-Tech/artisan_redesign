import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Reusable empty state widget for jobs pages
class JobsEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const JobsEmptyState({
    required this.title,
    required this.subtitle,
    this.icon = Icons.work_outline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          AppSpacing.spaceLG,
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.spaceSM,
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
