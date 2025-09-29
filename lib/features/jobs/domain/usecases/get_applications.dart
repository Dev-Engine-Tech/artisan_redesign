import '../entities/job.dart';
import '../repositories/job_repository.dart';

/// Use case to fetch applied jobs/applications with pagination support.
class GetApplications {
  final JobRepository repository;

  GetApplications(this.repository);

  Future<List<Job>> call({int page = 1, int limit = 20}) {
    return repository.getApplications(page: page, limit: limit);
  }
}