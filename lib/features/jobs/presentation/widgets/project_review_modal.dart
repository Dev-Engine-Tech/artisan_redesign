import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

class ProjectReviewModal extends StatelessWidget {
  final Job job;

  const ProjectReviewModal({
    required this.job,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXL,
      ),
      child: Container(
        padding: AppSpacing.paddingXXL,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusXL,
          color: AppColors.cardBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.rate_review,
                  color: AppColors.orange,
                  size: 24,
                ),
                AppSpacing.spaceSM,
                const Text(
                  'Client Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownHeader,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMD,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.spaceXL,

            // Project Info
            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(color: AppColors.softBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.brownHeader,
                    ),
                  ),
                  AppSpacing.spaceXS,
                  Text(
                    job.category,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  if (job.clientName != null) ...[
                    AppSpacing.spaceSM,
                    Row(
                      children: [
                        const Icon(Icons.person,
                            size: 16, color: Colors.black54),
                        AppSpacing.spaceXS,
                        Text(
                          'Client: ${job.clientName}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            AppSpacing.spaceXL,

            // Rating Section
            if (job.rating != null) ...[
              const Text(
                'Rating',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.brownHeader,
                ),
              ),
              AppSpacing.spaceSM,
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < (job.rating ?? 0).floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: AppColors.amber,
                      size: 24,
                    );
                  }),
                  AppSpacing.spaceSM,
                  Text(
                    '${job.rating?.toStringAsFixed(1)} out of 5',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.brownHeader,
                    ),
                  ),
                ],
              ),
              AppSpacing.spaceXL,
            ],

            // Review Text
            if (job.clientReview != null) ...[
              const Text(
                'Review',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.brownHeader,
                ),
              ),
              AppSpacing.spaceSM,
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: Text(
                  job.clientReview!,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingXXL,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: AppRadius.radiusLG,
                  border: Border.all(color: AppColors.softBorder),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: AppColors.subtleBorder,
                    ),
                    AppSpacing.spaceSM,
                    Text(
                      'No review provided yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            AppSpacing.spaceXXL,

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedAppButton(
                    text: 'Share Review',
                    icon: Icons.share,
                    onPressed: () => _shareReview(context),
                  ),
                ),
                AppSpacing.spaceMD,
                Expanded(
                  child: PrimaryButton(
                    text: 'Respond',
                    icon: Icons.reply,
                    onPressed: () => _respondToReview(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareReview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Review shared successfully'),
        backgroundColor: AppColors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  void _respondToReview(BuildContext context) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Respond to Review'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Thank you for your feedback...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          PrimaryButton(
            text: 'Send',
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Response sent successfully'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
