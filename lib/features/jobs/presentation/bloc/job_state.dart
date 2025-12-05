import 'package:meta/meta.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/artisan_invitation.dart';

@immutable
abstract class JobState {
  const JobState();
}

class JobStateInitial extends JobState {
  const JobStateInitial();
}

class JobStateLoading extends JobState {
  const JobStateLoading();
}

class JobStateLoaded extends JobState {
  final List<Job> jobs;

  const JobStateLoaded({required this.jobs});
}

class JobStateError extends JobState {
  final String message;

  const JobStateError({required this.message});
}

class JobStateApplying extends JobState {
  const JobStateApplying();
}

/// State for when accepting an agreement is in progress
class JobStateAcceptingAgreement extends JobState {
  final String jobId;

  const JobStateAcceptingAgreement({required this.jobId});
}

/// State for when requesting changes is in progress
class JobStateRequestingChange extends JobState {
  final String jobId;

  const JobStateRequestingChange({required this.jobId});
}

class JobStateAppliedSuccess extends JobState {
  final List<Job> jobs;
  final String jobId;

  const JobStateAppliedSuccess({required this.jobs, required this.jobId});
}

/// State emitted when a project agreement is accepted for an application.
/// Mirrors JobStateAppliedSuccess but provides clearer intent for agreement flow.
class JobStateAgreementAccepted extends JobState {
  final List<Job> jobs;
  final String jobId;

  const JobStateAgreementAccepted({required this.jobs, required this.jobId});
}

class JobStateChangeRequested extends JobState {
  final List<Job> jobs;
  final String jobId;

  const JobStateChangeRequested({required this.jobs, required this.jobId});
}

/// State for completed jobs loaded
class JobStateCompletedLoaded extends JobState {
  final List<Job> completedJobs;

  const JobStateCompletedLoaded({required this.completedJobs});
}

/// State for ongoing jobs loaded
class JobStateOngoingLoaded extends JobState {
  final List<Job> ongoingJobs;

  const JobStateOngoingLoaded({required this.ongoingJobs});
}

/// State for when pausing a job is in progress
class JobStatePausing extends JobState {
  final String jobId;

  const JobStatePausing({required this.jobId});
}

/// State for when completing a job is in progress
class JobStateCompleting extends JobState {
  final String jobId;

  const JobStateCompleting({required this.jobId});
}

/// State for when submitting progress is in progress
class JobStateSubmittingProgress extends JobState {
  final String jobId;

  const JobStateSubmittingProgress({required this.jobId});
}

/// State for when progress is submitted successfully
class JobStateProgressSubmitted extends JobState {
  final String jobId;
  final String message;

  const JobStateProgressSubmitted({required this.jobId, required this.message});
}

/// State for job invitations loaded
class JobStateInvitationsLoaded extends JobState {
  final List<Job> invitations;

  const JobStateInvitationsLoaded({required this.invitations});
}

/// State for when responding to job invitation is in progress
class JobStateRespondingToInvitation extends JobState {
  final String invitationId;

  const JobStateRespondingToInvitation({required this.invitationId});
}

/// State for when invitation response is successful (LEGACY)
class JobStateInvitationResponseSuccess extends JobState {
  final String invitationId;
  final bool accepted;
  final String message;

  const JobStateInvitationResponseSuccess({
    required this.invitationId,
    required this.accepted,
    required this.message,
  });
}

/// State for artisan invitations loaded (v1)
class JobStateArtisanInvitationsLoaded extends JobState {
  final List<ArtisanInvitation> invitations;

  const JobStateArtisanInvitationsLoaded({required this.invitations});
}

/// State for when responding to artisan invitation is in progress
class JobStateRespondingToArtisanInvitation extends JobState {
  final int invitationId;

  const JobStateRespondingToArtisanInvitation({required this.invitationId});
}

/// State for when artisan invitation response is successful
class JobStateArtisanInvitationResponseSuccess extends JobState {
  final int invitationId;
  final bool accepted;
  final String message;

  const JobStateArtisanInvitationResponseSuccess({
    required this.invitationId,
    required this.accepted,
    required this.message,
  });
}
