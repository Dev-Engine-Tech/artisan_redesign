import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/agreement_modal.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/change_request_status_modal.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/services/job_share_service.dart';

/// Polished job card aiming to match the provided designs:
/// - soft rounded container with subtle border
/// - left thumbnail, title/category/address, budget/duration row
/// - action row with prominent Apply button and lightweight Reviews button
class JobCard extends StatelessWidget {
  final Job job;
  final void Function()? onTap;
  final String? primaryLabel;
  final VoidCallback? primaryAction;
  final String? secondaryLabel;
  final VoidCallback? secondaryAction;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.primaryLabel,
    this.primaryAction,
    this.secondaryLabel,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final budgetText = job.minBudget == job.maxBudget
        ? '₦${job.maxBudget.toString()}'
        : '₦${job.minBudget.toString()} - ₦${job.maxBudget.toString()}';
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.w600);
    final subtitleStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.subtleBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.softPink,
                        image: job.thumbnailUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                    sanitizeImageUrl(job.thumbnailUrl)),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: job.thumbnailUrl.isEmpty
                          ? const Center(
                              child: Icon(Icons.home_repair_service_outlined,
                                  color: AppColors.orange, size: 28))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Title + category + address + status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(job.title, style: titleStyle)),
                              if (job.applied) _buildStatusIndicator(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(job.category, style: subtitleStyle),
                          if (job.applied) ...[
                            const SizedBox(height: 4),
                            _buildApplicationStatus(),
                          ],
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              job.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.brownHeader),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // share and menu icons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => JobShareService.shareJob(job),
                          icon: const Icon(Icons.share_outlined,
                              size: 20, color: Colors.black54),
                          tooltip: 'Share Job',
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert,
                              size: 20, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // budget & duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(budgetText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.subtleBorder),
                      ),
                      child: Text(job.duration,
                          style: Theme.of(context).textTheme.bodyMedium),
                    )
                  ],
                ),

                const SizedBox(height: 12),

                // description snippet
                Text(
                  job.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // actions (primary larger, secondary smaller)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              primaryAction ?? _getPrimaryAction(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getPrimaryButtonColor(),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(primaryLabel ?? _getPrimaryLabel(),
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed:
                              secondaryAction ?? _getSecondaryAction(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.softPeach,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            foregroundColor: AppColors.brownHeader,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.reviews,
                                  size: 16, color: AppColors.orange),
                              const SizedBox(width: 6),
                              Text(secondaryLabel ?? _getSecondaryLabel(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.brownHeader)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a small circular status indicator based on application status
  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;

    if (job.status == JobStatus.accepted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (job.agreement != null) {
      statusColor = Colors.orange;
      statusIcon = Icons.assignment;
    } else if (job.changeRequest != null) {
      statusColor = Colors.blue;
      statusIcon = Icons.change_circle;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.pending;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Icon(
        statusIcon,
        size: 14,
        color: statusColor,
      ),
    );
  }

  /// Builds the application status text
  Widget _buildApplicationStatus() {
    final status = job.applicationStatus;
    Color statusColor;

    if (status == 'Accepted') {
      statusColor = Colors.green;
    } else if (status == 'Review Agreement') {
      statusColor = Colors.orange;
    } else if (status == 'Change request sent') {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border:
            Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Gets the primary action based on application status
  VoidCallback? _getPrimaryAction(BuildContext context) {
    if (!job.applied) {
      return () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          // Ensure pushed route has access to the same JobBloc instance.
          JobBloc bloc;
          try {
            bloc = BlocProvider.of<JobBloc>(context);
          } catch (_) {
            bloc = getIt<JobBloc>();
          }
          return BlocProvider.value(
            value: bloc,
            child: JobDetailsPage(job: job),
          );
        }));
      };
    }

    // If there's an agreement, show agreement modal directly
    if (job.agreement != null) {
      return () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, controller) => AgreementModal(
              job: job,
              agreement: job.agreement!,
            ),
          ),
        );
      };
    }

    // If there's a change request, show change request status modal
    if (job.changeRequest != null) {
      return () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ChangeRequestStatusModal(
            job: job,
            changeRequest: job.changeRequest!,
          ),
        );
      };
    }

    // No agreement yet - waiting state, button should be disabled
    return null;
  }

  /// Gets the primary button label based on application status
  String _getPrimaryLabel() {
    if (!job.applied) {
      return 'Apply';
    }

    if (job.status == JobStatus.accepted) {
      return 'View Project';
    } else if (job.agreement != null) {
      return 'Accept Agreement';
    } else if (job.changeRequest != null) {
      return 'View Changes';
    } else {
      // No agreement yet - waiting
      return 'Waiting Agreement';
    }
  }

  /// Gets the primary button color based on application status
  Color _getPrimaryButtonColor() {
    if (!job.applied) {
      return AppColors.orange;
    }

    if (job.status == JobStatus.accepted) {
      return Colors.green;
    } else if (job.agreement != null) {
      return Colors.orange;
    } else if (job.changeRequest != null) {
      return Colors.blue;
    } else {
      // No agreement yet - grayed out
      return Colors.grey;
    }
  }

  /// Gets the secondary button label based on application status
  String _getSecondaryLabel() {
    if (job.applied && job.agreement != null) {
      return 'Reject';
    }
    return 'Reviews';
  }

  /// Gets the secondary button action based on application status
  VoidCallback? _getSecondaryAction(BuildContext context) {
    if (job.applied && job.agreement != null) {
      // Return reject action - could show confirmation dialog
      return () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reject Agreement'),
            content:
                const Text('Are you sure you want to reject this agreement?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement reject agreement logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Agreement rejected')),
                  );
                },
                child: const Text('Reject'),
              ),
            ],
          ),
        );
      };
    }
    return () {}; // Default empty action for reviews
  }
}
