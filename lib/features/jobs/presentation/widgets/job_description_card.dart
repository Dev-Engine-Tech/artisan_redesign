import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Description card widget for job details
class JobDescriptionCard extends StatelessWidget {
  final String description;

  const JobDescriptionCard({
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.softBorder),
      ),
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.54),
                ),
          ),
        ],
      ),
    );
  }
}
