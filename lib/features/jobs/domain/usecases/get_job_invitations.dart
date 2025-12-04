import '../entities/job.dart';
import '../repositories/job_repository.dart';

class GetJobInvitations {
  final JobRepository repository;

  GetJobInvitations(this.repository);

  Future<List<Job>> call({int page = 1, int limit = 20}) async {
    return await repository.getJobInvitations(page: page, limit: limit);
  }
}
