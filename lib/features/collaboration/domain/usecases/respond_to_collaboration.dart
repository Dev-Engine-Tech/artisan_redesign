import '../entities/collaboration.dart';
import '../repositories/collaboration_repository.dart';

/// Use case for responding to a collaboration invitation
class RespondToCollaboration {
  final CollaborationRepository repository;

  RespondToCollaboration(this.repository);

  Future<Collaboration> call({
    required int collaborationId,
    required CollaborationAction action,
    String? message,
  }) {
    return repository.respondToCollaboration(
      collaborationId: collaborationId,
      action: action,
      message: message,
    );
  }
}
