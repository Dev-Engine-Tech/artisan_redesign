import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Duration pill widget for job details
class JobDurationPill extends StatelessWidget {
  final String duration;

  const JobDurationPill({
    required this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Text(
        'Duration: $duration',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.brownHeader),
      ),
    );
  }
}
