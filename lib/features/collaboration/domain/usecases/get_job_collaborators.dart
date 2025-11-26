import '../entities/collaboration.dart';
import '../repositories/collaboration_repository.dart';

/// Use case for getting all collaborators for a specific job
class GetJobCollaborators {
  final CollaborationRepository repository;

  GetJobCollaborators(this.repository);

  Future<List<Collaboration>> call({
    required int jobApplicationId,
  }) {
    return repository.getJobCollaborators(
      jobApplicationId: jobApplicationId,
    );
  }
}
