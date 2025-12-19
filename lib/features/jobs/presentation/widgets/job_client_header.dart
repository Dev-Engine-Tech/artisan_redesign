import 'package:flutter/material.dart';
import '../../domain/entities/job.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';

/// Job client header card widget
///
/// Displays:
/// - Client avatar
/// - Client name
/// - "Client" label
/// - "View Profile" button (if clientId available)
class JobClientHeader extends StatelessWidget {
  final Job job;
  final VoidCallback? onViewProfile;

  const JobClientHeader({
    required this.job,
    this.onViewProfile,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          AppSpacing.spaceXS,
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.brownHeader),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (job.clientName ?? 'Client'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                AppSpacing.spaceXS,
                Text(
                  'Client',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          if (((job.clientId ?? '').trim()).isNotEmpty)
            PrimaryButton(
              text: 'View Profile',
              onPressed: onViewProfile ?? () {},
            ),
        ],
      ),
    );
  }
}
