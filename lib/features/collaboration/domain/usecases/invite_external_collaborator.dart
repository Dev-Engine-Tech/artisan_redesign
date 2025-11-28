import '../entities/collaboration.dart';
import '../repositories/collaboration_repository.dart';

/// Use case for inviting an external collaborator (not yet on platform) to a job
class InviteExternalCollaborator {
  final CollaborationRepository repository;

  InviteExternalCollaborator(this.repository);

  Future<Collaboration> call({
    required int jobApplicationId,
    required String name,
    required String contact,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    String? message,
  }) {
    return repository.inviteExternalCollaborator(
      jobApplicationId: jobApplicationId,
      name: name,
      contact: contact,
      paymentMethod: paymentMethod,
      paymentAmount: paymentAmount,
      message: message,
    );
  }
}
