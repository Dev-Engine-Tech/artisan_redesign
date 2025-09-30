import 'package:meta/meta.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';

@immutable
abstract class JobEvent {}

class LoadJobs extends JobEvent {
  final int page;
  final int limit;
  final String? search;
  final bool? saved;
  final bool? match;
  final String? postedDate;
  final String? workMode;
  final String? budgetType;
  final String? duration;
  final String? category;
  final String? state;
  final String? lgas;

  LoadJobs({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.saved,
    this.match,
    this.postedDate,
    this.workMode,
    this.budgetType,
    this.duration,
    this.category,
    this.state,
    this.lgas,
  });
}

class RefreshJobs extends JobEvent {
  final int limit;

  RefreshJobs({this.limit = 20});
}

class LoadApplications extends JobEvent {
  final int page;
  final int limit;

  LoadApplications({this.page = 1, this.limit = 20});
}

class ApplyToJobEvent extends JobEvent {
  final JobApplication application;

  ApplyToJobEvent({required this.application});
}

/// Event representing acceptance of a project agreement for an application.
class AcceptAgreementEvent extends JobEvent {
  final String jobId;

  AcceptAgreementEvent({required this.jobId});
}

/// Event representing a request for changes to an application/agreement.
class RequestChangeEvent extends JobEvent {
  final String jobId;
  final String reason;

  RequestChangeEvent({required this.jobId, required this.reason});
}

/// Event to load completed jobs
class LoadCompletedJobs extends JobEvent {
  final int page;
  final int limit;

  LoadCompletedJobs({this.page = 1, this.limit = 20});
}

/// Event to load ongoing jobs
class LoadOngoingJobs extends JobEvent {
  final int page;
  final int limit;

  LoadOngoingJobs({this.page = 1, this.limit = 20});
}

/// Event to pause a job
class PauseJobEvent extends JobEvent {
  final String jobId;

  PauseJobEvent({required this.jobId});
}

/// Event to complete a job
class CompleteJobEvent extends JobEvent {
  final String jobId;

  CompleteJobEvent({required this.jobId});
}

/// Event to submit progress update
class SubmitProgressEvent extends JobEvent {
  final String jobId;
  final String description;
  final int progressPercentage;
  final List<String>? images;

  SubmitProgressEvent({
    required this.jobId,
    required this.description,
    required this.progressPercentage,
    this.images,
  });
}
