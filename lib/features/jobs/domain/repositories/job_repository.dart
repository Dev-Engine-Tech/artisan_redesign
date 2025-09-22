import '../entities/job.dart';
import '../entities/job_application.dart';

abstract class JobRepository {
  /// Fetches a page/list of available jobs.
  /// Implementations may throw exceptions on network or parsing failures.
  Future<List<Job>> getJobs({int page = 1, int limit = 20});

  /// Apply to a job with full payload (returns true on success).
  Future<bool> applyToJob(JobApplication application);

  /// Request changes for an application (returns true on success).
  /// `reason` should contain the explanation for the requested changes.
  Future<bool> requestChange(String jobId, {required String reason});

  /// Accept agreement for a project/application by project id.
  Future<bool> acceptAgreement(String projectId);
}
