import 'package:artisans_circle/features/jobs/data/datasources/job_remote_data_source.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';
import 'package:artisans_circle/features/jobs/domain/entities/artisan_invitation.dart';
import 'package:artisans_circle/features/jobs/domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> applyToJob(JobApplication application) async {
    try {
      return await remoteDataSource.applyToJob(application);
    } catch (_) {
      rethrow;
    }
  }

  @override
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
  }) async {
    try {
      final models = await remoteDataSource.fetchJobs(
        page: page,
        limit: limit,
        search: search,
        saved: saved,
        match: match,
        postedDate: postedDate,
        workMode: workMode,
        budgetType: budgetType,
        duration: duration,
        category: category,
        state: state,
        lgas: lgas,
      );
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<Job>> getApplications({int page = 1, int limit = 20}) async {
    try {
      final models =
          await remoteDataSource.loadApplications(page: page, limit: limit);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> requestChange(String jobId, {required String reason}) async {
    try {
      return await remoteDataSource.requestChange(jobId, reason: reason);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> acceptAgreement(String projectId) async {
    try {
      return await remoteDataSource.acceptAgreement(projectId);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<Job>> getJobInvitations({int page = 1, int limit = 20}) async {
    try {
      final models = await remoteDataSource.fetchJobInvitations(page: page, limit: limit);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> respondToJobInvitation(String invitationId, {required bool accept}) async {
    try {
      return await remoteDataSource.respondToJobInvitation(invitationId, accept: accept);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<ArtisanInvitation>> getArtisanInvitations({int page = 1, int limit = 20}) async {
    try {
      final models = await remoteDataSource.fetchArtisanInvitations(page: page, limit: limit);
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<ArtisanInvitation>> getRecentArtisanInvitations() async {
    try {
      final models = await remoteDataSource.fetchRecentArtisanInvitations();
      return models.map((m) => m.toEntity()).toList();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<ArtisanInvitation> getArtisanInvitationDetail(int invitationId) async {
    try {
      final model = await remoteDataSource.fetchArtisanInvitationDetail(invitationId);
      return model.toEntity();
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> respondToArtisanInvitation(int invitationId, {required String status, String? rejectionReason}) async {
    try {
      return await remoteDataSource.respondToArtisanInvitation(
        invitationId,
        status: status,
        rejectionReason: rejectionReason,
      );
    } catch (_) {
      rethrow;
    }
  }
}
