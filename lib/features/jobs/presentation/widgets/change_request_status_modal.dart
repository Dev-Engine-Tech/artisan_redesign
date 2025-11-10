import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/entities/change_request.dart';
import '../../domain/entities/job.dart';

/// Modal for displaying change request status and details
/// Shows when a change request has been submitted but not yet processed
class ChangeRequestStatusModal extends StatelessWidget {
  final Job job;
  final ChangeRequest changeRequest;

  const ChangeRequestStatusModal({
    required this.job,
    required this.changeRequest,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: AppSpacing.verticalMD,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: AppSpacing.horizontalXL,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Change Request Status',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Padding(
            padding: AppSpacing.paddingXL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  padding: AppSpacing.paddingLG,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      AppSpacing.spaceMD,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Request Submitted',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue.shade700,
                                  ),
                            ),
                            Text(
                              'Waiting for client response',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.blue.shade600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.spaceXL,

                // Job info
                Text(
                  'Project',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                ),
                AppSpacing.spaceXS,
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),

                AppSpacing.spaceLG,

                // Change request details
                Text(
                  'Requested Changes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                ),
                AppSpacing.spaceXS,
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Text(
                    changeRequest.proposedChange,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                AppSpacing.spaceLG,

                // Reason
                Text(
                  'Reason',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                ),
                AppSpacing.spaceXS,
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Text(
                    changeRequest.reason,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                AppSpacing.spaceXL,

                // Info section
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.grey.shade600, size: 20),
                      AppSpacing.spaceSM,
                      Expanded(
                        child: Text(
                          'The client will review your request and provide feedback. You will be notified once they respond.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.spaceXXL,

                // Close button
                PrimaryButton(
                  text: 'Got it',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
