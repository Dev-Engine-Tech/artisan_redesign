import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/features/jobs/domain/entities/artisan_invitation.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/home/presentation/widgets/empty_state_widget.dart';

/// Separate widget for Job Invite tab - displays job invitations from clients
class JobInviteTabContent extends StatefulWidget {
  const JobInviteTabContent({
    required this.onJobTap,
    super.key,
  });

  final Function(Job) onJobTap;

  @override
  State<JobInviteTabContent> createState() => _JobInviteTabContentState();
}

class _JobInviteTabContentState extends State<JobInviteTabContent> {
  @override
  void initState() {
    super.initState();
    // Load recent artisan invitations when widget initializes (top 5 most recent)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final state = context.read<JobBloc>().state;
        if (state is! JobStateArtisanInvitationsLoaded) {
          context.read<JobBloc>().add(LoadRecentArtisanInvitations());
        }
      } catch (_) {
        // JobBloc not available, ignore
      }
    });
  }

  void _handleAccept(ArtisanInvitation invitation) {
    // Convert invitation to Job and navigate to job details page
    // The job details page will show "Accept Invite" button which redirects to application form
    JobStatus jobStatus;
    switch (invitation.invitationStatus.toLowerCase()) {
      case 'pending':
        jobStatus = JobStatus.pending;
        break;
      case 'accepted':
        jobStatus = JobStatus.inProgress;
        break;
      case 'rejected':
        jobStatus = JobStatus.rejected;
        break;
      default:
        jobStatus = JobStatus.pending;
    }

    final job = Job(
      id: invitation.jobId.toString(),
      title: invitation.jobTitle,
      category: invitation.jobCategory ?? 'Job Invitation',
      description: invitation.jobDescription ?? '',
      address: invitation.address ?? invitation.clientName ?? 'Client',
      minBudget: invitation.minBudget ?? 0,
      maxBudget: invitation.maxBudget ?? 0,
      duration: invitation.duration ?? 'Not specified',
      applied: false,
      status: jobStatus,
      clientName: invitation.clientName,
      clientId: invitation.clientId?.toString(),
      invitationId: invitation.id,
    );

    // Navigate to job details page
    widget.onJobTap(job);
  }

  void _handleReject(ArtisanInvitation invitation) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Job Invitation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please provide a reason for declining this invitation:',
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: reasonController,
              hint: 'e.g., Busy with other projects',
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () {
              reasonController.dispose();
              Navigator.pop(ctx);
            },
          ),
          TextAppButton(
            text: 'Decline',
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for declining'),
                  ),
                );
                return;
              }
              reasonController.dispose();
              Navigator.pop(ctx);
              context.read<JobBloc>().add(
                    RejectArtisanInvitation(
                      invitationId: invitation.id,
                      reason: reason,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobStateArtisanInvitationResponseSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
          // Refresh the list (recent invitations)
          context.read<JobBloc>().add(LoadRecentArtisanInvitations());
        } else if (state is JobStateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<JobBloc, JobState>(
        builder: (context, state) {
          if (state is JobStateLoading ||
              state is JobStateRespondingToArtisanInvitation) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JobStateError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: context.dangerColor,
                  ),
                  AppSpacing.spaceLG,
                  Text(
                    'Failed to load job invitations',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  AppSpacing.spaceSM,
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: () {
                      context
                          .read<JobBloc>()
                          .add(LoadRecentArtisanInvitations());
                    },
                  ),
                ],
              ),
            );
          }

          if (state is JobStateArtisanInvitationsLoaded) {
            final invitations = state.invitations;

            if (invitations.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.mail_outline,
                title: 'No Job Invitations',
                subtitle: 'Job invitations from clients will appear here',
              );
            }

            // Performance: Use ListView.builder for lazy loading with optimizations
            return RefreshIndicator(
              onRefresh: () async {
                context.read<JobBloc>().add(LoadRecentArtisanInvitations());
              },
              child: ListView.builder(
                itemCount: invitations.length,
                padding: AppSpacing.verticalSM,
                physics:
                    const AlwaysScrollableScrollPhysics(), // Smooth scrolling behavior
                cacheExtent:
                    400, // Cache more items offscreen for smoother scrolling
                addAutomaticKeepAlives:
                    true, // Keep list items alive for better performance
                addRepaintBoundaries: true, // Isolate repaints for performance
                itemBuilder: (context, index) {
                  final invitation = invitations[index];
                  // Convert ArtisanInvitation to Job for display
                  // Map invitation status to JobStatus for display
                  JobStatus jobStatus;
                  switch (invitation.invitationStatus.toLowerCase()) {
                    case 'pending':
                      jobStatus = JobStatus.pending;
                      break;
                    case 'accepted':
                      jobStatus = JobStatus.inProgress;
                      break;
                    case 'rejected':
                      jobStatus = JobStatus.rejected;
                      break;
                    default:
                      jobStatus = JobStatus.pending;
                  }

                  final job = Job(
                    id: invitation.jobId.toString(),
                    title: invitation.jobTitle,
                    category: invitation.jobCategory ?? 'Job Invitation',
                    description: invitation.jobDescription ?? '',
                    address:
                        invitation.address ?? invitation.clientName ?? 'Client',
                    minBudget: invitation.minBudget ?? 0,
                    maxBudget: invitation.maxBudget ?? 0,
                    duration: invitation.duration ?? 'Not specified',
                    applied: false,
                    status: jobStatus,
                    clientName: invitation.clientName,
                    clientId: invitation.clientId?.toString(),
                    invitationId: invitation.id,
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: JobCard(
                      job: job,
                      onTap: () => widget.onJobTap(job),
                      primaryLabel: 'Accept',
                      secondaryLabel: 'Decline',
                      primaryAction: () => _handleAccept(invitation),
                      secondaryAction: () => _handleReject(invitation),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
