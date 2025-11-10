import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';

class ApplicationCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onAgreementTap;
  final VoidCallback? onChangeRequestTap;

  const ApplicationCard({
    required this.job,
    super.key,
    this.onTap,
    this.onAgreementTap,
    this.onChangeRequestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLG,
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brownHeader,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.spaceXS,
                        Text(
                          job.category,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.spaceSM,
                  _buildStatusChip(job.status),
                ],
              ),
              AppSpacing.spaceMD,
              Text(
                job.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.spaceMD,
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.black54,
                  ),
                  AppSpacing.spaceXS,
                  Expanded(
                    child: Text(
                      job.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppSpacing.spaceSM,
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.black54,
                  ),
                  AppSpacing.spaceXS,
                  Text(
                    job.duration,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'NGN ${job.minBudget.toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                          (match) => '${match[1]},',
                        )}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brownHeader,
                        ),
                  ),
                ],
              ),
              if (_shouldShowActionButtons()) ...[
                AppSpacing.spaceLG,
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(JobStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case JobStatus.pending:
        backgroundColor = AppColors.softPeach;
        textColor = AppColors.orange;
        statusText = 'Pending';
        break;
      case JobStatus.accepted:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green.shade700;
        statusText = 'Accepted';
        break;
      case JobStatus.rejected:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red.shade700;
        statusText = 'Rejected';
        break;
      case JobStatus.inProgress:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue.shade700;
        statusText = 'In Progress';
        break;
      case JobStatus.completed:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green.shade700;
        statusText = 'Completed';
        break;
      case JobStatus.changeRequested:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange.shade700;
        statusText = 'Changes Requested';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool _shouldShowActionButtons() {
    // Show relevant actions for each status
    if (job.status == JobStatus.pending) {
      // Pending: If an agreement exists, show actions to review/accept or request changes
      return job.agreement != null;
    }
    if (job.status == JobStatus.changeRequested) {
      return true;
    }
    if (job.status == JobStatus.accepted ||
        job.status == JobStatus.inProgress) {
      return true; // allow opening project
    }
    if (job.status == JobStatus.completed) {
      return true; // allow viewing summary
    }
    return false;
  }

  Widget _buildActionButtons(BuildContext context) {
    if (job.status == JobStatus.pending && job.agreement != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedAppButton(
              text: 'Request Changes',
              onPressed: onChangeRequestTap,
            ),
          ),
          AppSpacing.spaceSM,
          Expanded(
            child: PrimaryButton(
              text: 'View Agreement',
              onPressed: onAgreementTap,
            ),
          ),
        ],
      );
    }

    if (job.status == JobStatus.changeRequested) {
      return OutlinedAppButton(
        text: 'View Change Request',
        onPressed: onTap,
      );
    }

    if (job.status == JobStatus.accepted ||
        job.status == JobStatus.inProgress) {
      return PrimaryButton(
        text: 'Open Project',
        onPressed: onTap,
      );
    }

    if (job.status == JobStatus.completed) {
      return OutlinedAppButton(
        text: 'View Summary',
        onPressed: onTap,
      );
    }

    return const SizedBox.shrink();
  }
}
