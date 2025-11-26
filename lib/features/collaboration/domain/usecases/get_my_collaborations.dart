import '../entities/collaboration.dart';
import '../repositories/collaboration_repository.dart';

/// Use case for getting user's collaborations
class GetMyCollaborations {
  final CollaborationRepository repository;

  GetMyCollaborations(this.repository);

  Future<CollaborationListResult> call({
    CollaborationStatus? status,
    CollaborationRole? role,
    int page = 1,
    int pageSize = 10,
  }) {
    return repository.getMyCollaborations(
      status: status,
      role: role,
      page: page,
      pageSize: pageSize,
    );
  }
}
