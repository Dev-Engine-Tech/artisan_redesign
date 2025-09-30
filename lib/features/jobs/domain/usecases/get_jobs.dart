import '../entities/job.dart';
import '../repositories/job_repository.dart';

/// Use case to fetch jobs with pagination support.
class GetJobs {
  final JobRepository repository;

  GetJobs(this.repository);

  Future<List<Job>> call({
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
  }) {
    return repository.getJobs(
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
  }
}
