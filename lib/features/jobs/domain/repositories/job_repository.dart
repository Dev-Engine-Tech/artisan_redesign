import '../entities/job.dart';
import '../entities/job_application.dart';
import '../entities/artisan_invitation.dart';

abstract class JobRepository {
  /// Fetches a page/list of available jobs.
  /// Implementations may throw exceptions on network or parsing failures.
  Future<List<Job>> getJobs({
    int page = 1,
    int limit = 20,
    String? search,
    bool? saved,
    bool? match,
    String? postedDate,
    String? workMode,
    String? budgetType,
    String? duration,
    String? category,
    String? state,
    String? lgas,
  });

  /// Fetches applied jobs/applications from the API.
  Future<List<Job>> getApplications({int page = 1, int limit = 20});

  /// Apply to a job with full payload (returns true on success).
  Future<bool> applyToJob(JobApplication application);

  /// Request changes for an application (returns true on success).
  /// `reason` should contain the explanation for the requested changes.
  Future<bool> requestChange(String jobId, {required String reason});

  /// Accept agreement for a project/application by project id.
  Future<bool> acceptAgreement(String projectId);

  /// Fetches job invitations from clients (LEGACY)
  Future<List<Job>> getJobInvitations({int page = 1, int limit = 20});

  /// Respond to a job invitation (LEGACY)
  Future<bool> respondToJobInvitation(String invitationId,
      {required bool accept});

  /// Fetches artisan invitations from clients (v1 endpoints)
  Future<List<ArtisanInvitation>> getArtisanInvitations(
      {int page = 1, int limit = 20});

  /// Fetches recent artisan invitations (top 5 most recent)
  Future<List<ArtisanInvitation>> getRecentArtisanInvitations();

  /// Fetch single artisan invitation detail by ID
  Future<ArtisanInvitation> getArtisanInvitationDetail(int invitationId);

  /// Respond to an artisan invitation with status and optional rejection reason
  Future<bool> respondToArtisanInvitation(int invitationId,
      {required String status, String? rejectionReason});
}
