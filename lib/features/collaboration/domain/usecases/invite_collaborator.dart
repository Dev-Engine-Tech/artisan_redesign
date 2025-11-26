import '../entities/collaboration.dart';
import '../repositories/collaboration_repository.dart';

/// Use case for inviting a collaborator to a job
class InviteCollaborator {
  final CollaborationRepository repository;

  InviteCollaborator(this.repository);

  Future<Collaboration> call({
    required int jobApplicationId,
    required int collaboratorId,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    String? message,
  }) {
    return repository.inviteCollaborator(
      jobApplicationId: jobApplicationId,
      collaboratorId: collaboratorId,
      paymentMethod: paymentMethod,
      paymentAmount: paymentAmount,
      message: message,
    );
  }
}
