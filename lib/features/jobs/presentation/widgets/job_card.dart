import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/core/components/components.dart';
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
import 'package:artisans_circle/core/utils/currency.dart';

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
    required this.job,
    super.key,
    this.onTap,
    this.primaryLabel,
    this.primaryAction,
    this.secondaryLabel,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetText = job.minBudget == job.maxBudget
        ? Currency.formatNgn(job.maxBudget)
        : '${Currency.formatNgn(job.minBudget)} - ${Currency.formatNgn(job.maxBudget)}';
    final titleStyle =
        theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600);
    final subtitleStyle = theme.textTheme.bodyMedium
        ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.54));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.subtleBorderColor),
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
                    (() {
                      final imgUrl = sanitizeImageUrl(job.thumbnailUrl);
                      final valid = imgUrl.startsWith('http');
                      return Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: context.softPinkColor,
                          image: valid
                              ? DecorationImage(
                                  image: NetworkImage(imgUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !valid
                            ? Center(
                                child: Icon(
                                  Icons.home_repair_service_outlined,
                                  color: context.primaryColor,
                                  size: 28,
                                ),
                              )
                            : null,
                      );
                    })(),
                    AppSpacing.spaceMD,
                    // Title + category + address + status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(job.title, style: titleStyle)),
                              if (job.applied || job.invitationId != null)
                                _buildStatusIndicator(),
                            ],
                          ),
                          AppSpacing.spaceXS,
                          Text(job.category, style: subtitleStyle),
                          if (job.applied || job.invitationId != null) ...[
                            AppSpacing.spaceXS,
                            _buildApplicationStatus(),
                          ],
                          AppSpacing.spaceSM,
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: context.softPinkColor,
                              borderRadius: AppRadius.radiusMD,
                            ),
                            child: Text(
                              job.address,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: context.brownHeaderColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.spaceSM,
                    // share and menu icons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => JobShareService.shareJob(job),
                          icon: Icon(Icons.share_outlined,
                              size: 20,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.54)),
                          tooltip: 'Share Job',
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.more_vert,
                              size: 20,
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.54)),
                        ),
                      ],
                    ),
                  ],
                ),

                AppSpacing.spaceMD,

                // budget & duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(budgetText,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.cardBackgroundColor,
                        borderRadius: AppRadius.radiusMD,
                        border: Border.all(color: context.subtleBorderColor),
                      ),
                      child:
                          Text(job.duration, style: theme.textTheme.bodyMedium),
                    )
                  ],
                ),

                AppSpacing.spaceMD,

                // description snippet
                Text(
                  job.description,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // actions (primary larger, secondary smaller)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: primaryLabel ?? _getPrimaryLabel(),
                        onPressed: primaryAction ?? _getPrimaryAction(context),
                      ),
                    ),
                    AppSpacing.spaceMD,
                    Expanded(
                      flex: 1,
                      child: OutlinedAppButton(
                        text: secondaryLabel ?? _getSecondaryLabel(),
                        onPressed:
                            secondaryAction ?? _getSecondaryAction(context),
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
    return Builder(builder: (context) {
      Color statusColor;
      IconData statusIcon;

      // Check if this is an invitation
      if (job.invitationId != null) {
        switch (job.status) {
          case JobStatus.pending:
            statusColor = context.colorScheme.primary;
            statusIcon = Icons.mail_outline;
            break;
          case JobStatus.rejected:
            statusColor = context.colorScheme.error;
            statusIcon = Icons.cancel_outlined;
            break;
          case JobStatus.inProgress:
            statusColor = context.colorScheme.tertiary;
            statusIcon = Icons.check_circle;
            break;
          default:
            statusColor = context.colorScheme.onSurfaceVariant;
            statusIcon = Icons.pending;
        }
      } else if (job.status == JobStatus.accepted) {
        statusColor = context.colorScheme.tertiary;
        statusIcon = Icons.check_circle;
      } else if (job.agreement != null) {
        statusColor = context.primaryColor;
        statusIcon = Icons.assignment;
      } else if (job.changeRequest != null) {
        statusColor = context.darkBlueColor;
        statusIcon = Icons.change_circle;
      } else {
        statusColor = context.colorScheme.onSurfaceVariant;
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
    });
  }

  /// Builds the application status text
  Widget _buildApplicationStatus() {
    return Builder(builder: (context) {
      String status;
      Color statusColor;

      // Check if this is an invitation
      if (job.invitationId != null) {
        switch (job.status) {
          case JobStatus.pending:
            status = 'Pending Invitation';
            statusColor = context.colorScheme.primary;
            break;
          case JobStatus.rejected:
            status = 'Invitation Declined';
            statusColor = context.colorScheme.error;
            break;
          case JobStatus.inProgress:
            status = 'Invitation Accepted';
            statusColor = context.colorScheme.tertiary;
            break;
          default:
            status = 'Invitation';
            statusColor = context.colorScheme.onSurfaceVariant;
        }
      } else {
        status = job.applicationStatus;
        if (status == 'Accepted') {
          statusColor = context.colorScheme.tertiary;
        } else if (status == 'Review Agreement') {
          statusColor = context.primaryColor;
        } else if (status == 'Change request sent') {
          statusColor = context.darkBlueColor;
        } else {
          statusColor = context.colorScheme.onSurfaceVariant;
        }
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: AppRadius.radiusSM,
          border:
              Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Text(
          status,
          style: context.textTheme.bodySmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
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
        final theme = Theme.of(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.0),
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
        final theme = Theme.of(context);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.0),
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
              TextAppButton(
                text: 'Cancel',
                onPressed: () => Navigator.pop(context),
              ),
              TextAppButton(
                text: 'Reject',
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement reject agreement logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Agreement rejected')),
                  );
                },
              ),
            ],
          ),
        );
      };
    }
    return () {}; // Default empty action for reviews
  }
}
