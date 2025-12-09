import '../entities/artisan_invitation.dart';
import '../repositories/job_repository.dart';

/// Use case for fetching recent artisan invitations (top 5 most recent)
/// Uses the /invitation/api/recent-artisan-invitations/ endpoint
class GetRecentArtisanInvitations {
  final JobRepository repository;

  GetRecentArtisanInvitations(this.repository);

  Future<List<ArtisanInvitation>> call() async {
    return await repository.getRecentArtisanInvitations();
  }
}
