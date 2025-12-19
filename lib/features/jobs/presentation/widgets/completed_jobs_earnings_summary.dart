import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Earnings summary card for Completed Jobs page
///
/// Displays:
/// - Total earnings with currency symbol
/// - Number of completed projects
/// - Percentage increase badge
class CompletedJobsEarningsSummary extends StatelessWidget {
  final String totalEarnings;
  final int completedProjectsCount;
  final String percentageIncrease;

  const CompletedJobsEarningsSummary({
    required this.totalEarnings,
    required this.completedProjectsCount,
    required this.percentageIncrease,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.orange,
            AppColors.brownHeader.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: AppRadius.radiusXXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          AppSpacing.spaceSM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalEarnings,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.spaceXS,
                  Text(
                    'From $completedProjectsCount completed projects',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: AppRadius.radiusLG,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: colorScheme.onPrimary,
                      size: 16,
                    ),
                    AppSpacing.spaceXS,
                    Text(
                      percentageIncrease,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
