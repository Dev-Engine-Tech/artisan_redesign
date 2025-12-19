import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job.dart';
import '../../domain/entities/job_status.dart';
import '../../../../core/components/components.dart';
import '../../../../core/theme.dart';
import '../../../../core/di.dart';
import '../pages/apply_for_job_page.dart';
import '../pages/change_request_page.dart';
import '../pages/ongoing_jobs_page.dart';
import '../pages/job_summary_page.dart';
import '../widgets/change_request_status_modal.dart';
import '../bloc/job_bloc.dart';

/// Job primary action buttons widget
///
/// Displays contextual action buttons based on job status:
/// - Not applied: "Apply" or "Accept Invite" button
/// - Applied with pending agreement: "Request Changes" + "View Agreement"
/// - Change request exists: "View Change Request"
/// - Accepted/In Progress: "Open Project"
/// - Completed: "View Summary"
/// - Waiting: Disabled "Waiting Agreement" button
class JobActionButtons extends StatelessWidget {
  final Job job;
  final VoidCallback? onAgreementView;

  const JobActionButtons({
    required this.job,
    this.onAgreementView,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this is an invitation (has invitationId) and still pending
    final bool isInvitation = job.invitationId != null;
    final bool isPendingInvitation = isInvitation && job.status == JobStatus.pending;

    // Not applied yet → Apply (or Accept Invite for invitations)
    if (!job.applied) {
      return PrimaryButton(
        text: isPendingInvitation ? 'Accept Invite' : 'Apply',
        onPressed: () {
          // Provide the current JobBloc to the apply sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (c) {
              JobBloc sheetBloc;
              try {
                sheetBloc = BlocProvider.of<JobBloc>(context);
              } catch (_) {
                sheetBloc = getIt<JobBloc>();
              }

              return DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.92,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl)),
                  ),
                  child: BlocProvider.value(
                    value: sheetBloc,
                    child: ApplyForJobPage(job: job),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    // Applied with agreement pending → Request Changes / View Agreement
    if (job.agreement != null && job.status == JobStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedAppButton(
              text: 'Request Changes',
              onPressed: () async {
                // Navigate to request change page
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<JobBloc>(context),
                    child: ChangeRequestPage(job: job),
                  ),
                ));
              },
            ),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: PrimaryButton(
              text: 'View Agreement',
              onPressed: onAgreementView ?? () {},
            ),
          ),
        ],
      );
    }

    // Change request exists → View Change Request
    if (job.changeRequest != null) {
      return OutlinedAppButton(
        text: 'View Change Request',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, controller) => ChangeRequestStatusModal(
                job: job,
                changeRequest: job.changeRequest!,
              ),
            ),
          );
        },
      );
    }

    // Accepted / in progress → Open Project
    if (job.status == JobStatus.accepted ||
        job.status == JobStatus.inProgress) {
      return PrimaryButton(
        text: 'Open Project',
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const OngoingJobsPage(),
          ));
        },
      );
    }

    // Completed → View Summary
    if (job.status == JobStatus.completed) {
      return OutlinedAppButton(
        text: 'View Summary',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => JobSummaryPage(job: job),
            ),
          );
        },
      );
    }

    // Default (applied but waiting) → disable button
    return const PrimaryButton(
      text: 'Waiting Agreement',
      onPressed: null,
    );
  }
}
