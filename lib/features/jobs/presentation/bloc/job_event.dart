import 'package:meta/meta.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';

@immutable
abstract class JobEvent {}

class LoadJobs extends JobEvent {
  final int page;
  final int limit;

  LoadJobs({this.page = 1, this.limit = 20});
}

class RefreshJobs extends JobEvent {
  final int limit;

  RefreshJobs({this.limit = 20});
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
