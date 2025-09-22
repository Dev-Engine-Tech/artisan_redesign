import 'package:meta/meta.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

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
