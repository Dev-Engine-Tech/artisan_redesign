import '../repositories/job_repository.dart';

/// Use case for responding to an artisan invitation
/// Supports both accepting and rejecting with optional rejection reason
class RespondToArtisanInvitation {
  final JobRepository repository;

  RespondToArtisanInvitation(this.repository);

  /// Accept an artisan invitation
  Future<bool> accept(int invitationId) async {
    return await repository.respondToArtisanInvitation(
      invitationId,
      status: 'Accepted',
    );
  }

  /// Reject an artisan invitation with a reason
  Future<bool> reject(int invitationId, {required String reason}) async {
    return await repository.respondToArtisanInvitation(
      invitationId,
      status: 'Rejected',
      rejectionReason: reason,
    );
  }

  /// Generic call method for custom status
  Future<bool> call(int invitationId, {required String status, String? rejectionReason}) async {
    return await repository.respondToArtisanInvitation(
      invitationId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }
}
