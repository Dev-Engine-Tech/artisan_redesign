import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';

/// Reusable empty state widget following DRY principle
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: context.darkBlueColor.withValues(alpha: 0.3),
          ),
          AppSpacing.spaceLG,
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.darkBlueColor,
            ),
          ),
          AppSpacing.spaceSM,
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: context.darkBlueColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
