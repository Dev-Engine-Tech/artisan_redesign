import '../repositories/job_repository.dart';
import '../entities/job_application.dart';

/// Use case to apply to a job.
class ApplyToJob {
  final JobRepository repository;

  ApplyToJob(this.repository);

  Future<bool> call(JobApplication application) {
    return repository.applyToJob(application);
  }
}
