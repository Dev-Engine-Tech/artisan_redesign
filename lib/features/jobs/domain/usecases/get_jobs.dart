import '../entities/job.dart';
import '../repositories/job_repository.dart';

/// Use case to fetch jobs with pagination support.
class GetJobs {
  final JobRepository repository;

  GetJobs(this.repository);

  Future<List<Job>> call({int page = 1, int limit = 20}) {
    return repository.getJobs(page: page, limit: limit);
  }
}
