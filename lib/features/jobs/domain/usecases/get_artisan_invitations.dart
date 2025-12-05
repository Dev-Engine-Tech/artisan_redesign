import '../entities/artisan_invitation.dart';
import '../repositories/job_repository.dart';

/// Use case for fetching artisan invitations from clients
/// Uses the new v1 invitation endpoints
class GetArtisanInvitations {
  final JobRepository repository;

  GetArtisanInvitations(this.repository);

  Future<List<ArtisanInvitation>> call({int page = 1, int limit = 20}) async {
    return await repository.getArtisanInvitations(page: page, limit: limit);
  }
}
