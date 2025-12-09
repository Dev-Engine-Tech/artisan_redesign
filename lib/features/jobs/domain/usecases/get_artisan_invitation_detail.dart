import '../entities/artisan_invitation.dart';
import '../repositories/job_repository.dart';

/// Use case for fetching a single artisan invitation detail by ID
/// Uses the /invitation/api/artisan/invitations/<id>/ endpoint
class GetArtisanInvitationDetail {
  final JobRepository repository;

  GetArtisanInvitationDetail(this.repository);

  Future<ArtisanInvitation> call(int invitationId) async {
    return await repository.getArtisanInvitationDetail(invitationId);
  }
}
