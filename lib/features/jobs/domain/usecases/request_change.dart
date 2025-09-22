import 'package:artisans_circle/features/jobs/domain/repositories/job_repository.dart';

class RequestChange {
  final JobRepository repository;

  RequestChange(this.repository);

  /// Requests a change for the given jobId with a required reason.
  /// Returns true on success.
  Future<bool> call({required String jobId, required String reason}) async {
    return await repository.requestChange(jobId, reason: reason);
  }
}
