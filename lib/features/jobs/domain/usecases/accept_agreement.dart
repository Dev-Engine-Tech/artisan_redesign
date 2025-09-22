import '../repositories/job_repository.dart';

/// Use case to accept an agreement for a project/application.
class AcceptAgreement {
  final JobRepository repository;

  AcceptAgreement(this.repository);

  Future<bool> call(String projectId) {
    return repository.acceptAgreement(projectId);
  }
}
