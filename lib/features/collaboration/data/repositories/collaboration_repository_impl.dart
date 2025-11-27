import '../../domain/entities/collaboration.dart';
import '../../domain/entities/artisan_search_result.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../datasources/collaboration_remote_data_source.dart';

class CollaborationRepositoryImpl implements CollaborationRepository {
  final CollaborationRemoteDataSource remoteDataSource;

  CollaborationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ArtisanSearchResult>> searchArtisans(String query) async {
    return remoteDataSource.searchArtisans(query);
  }

  @override
  Future<Collaboration> inviteCollaborator({
    required int jobApplicationId,
    required int collaboratorId,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    String? message,
  }) async {
    final result = await remoteDataSource.inviteCollaborator(
      jobApplicationId: jobApplicationId,
      collaboratorId: collaboratorId,
      paymentMethod: paymentMethod,
      paymentAmount: paymentAmount,
      message: message,
    );
    return result.toEntity();
  }

  @override
  Future<CollaborationListResult> getMyCollaborations({
    CollaborationStatus? status,
    CollaborationRole? role,
    int page = 1,
    int pageSize = 10,
  }) async {
    final result = await remoteDataSource.getMyCollaborations(
      status: status,
      role: role,
      page: page,
      pageSize: pageSize,
    );
    return result; // Already extends CollaborationListResult
  }

  @override
  Future<Collaboration> respondToCollaboration({
    required int collaborationId,
    required CollaborationAction action,
    String? message,
  }) async {
    final result = await remoteDataSource.respondToCollaboration(
      collaborationId: collaborationId,
      action: action,
      message: message,
    );
    return result.toEntity();
  }

  @override
  Future<List<Collaboration>> getJobCollaborators({
    required int jobApplicationId,
  }) async {
    final results = await remoteDataSource.getJobCollaborators(
      jobApplicationId: jobApplicationId,
    );
    return results.map((model) => model.toEntity()).toList();
  }
}
