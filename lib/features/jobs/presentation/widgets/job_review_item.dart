import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Review item widget for job details
class JobReviewItem extends StatelessWidget {
  final String name;
  final String date;
  final String body;

  const JobReviewItem({
    required this.name,
    required this.date,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.person, color: AppColors.brownHeader),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                AppSpacing.spaceXS,
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.45),
                      ),
                ),
                AppSpacing.spaceSM,
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.54),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
