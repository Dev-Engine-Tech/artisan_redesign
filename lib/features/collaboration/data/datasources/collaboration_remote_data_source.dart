import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
import '../../domain/entities/collaboration.dart';
import '../../domain/entities/artisan_search_result.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../models/collaboration_model.dart';
import '../models/artisan_search_result_model.dart';

abstract class CollaborationRemoteDataSource {
  /// Search for artisans
  Future<List<ArtisanSearchResult>> searchArtisans(String query);

  Future<CollaborationModel> inviteCollaborator({
    required int jobApplicationId,
    required int collaboratorId,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    String? message,
  });

  Future<CollaborationListResultModel> getMyCollaborations({
    CollaborationStatus? status,
    CollaborationRole? role,
    int page = 1,
    int pageSize = 10,
  });

  Future<CollaborationModel> respondToCollaboration({
    required int collaborationId,
    required CollaborationAction action,
    String? message,
  });

  Future<List<CollaborationModel>> getJobCollaborators({
    required int jobApplicationId,
  });
}

class CollaborationRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CollaborationRemoteDataSource {
  CollaborationRemoteDataSourceImpl(super.dio);

  @override
  Future<List<ArtisanSearchResult>> searchArtisans(String query) async {
    final response = await dio.get(
      ApiEndpoints.searchArtisans,
      queryParameters: {'q': query},
    );

    // Handle different response formats
    final data = response.data;
    if (data is Map && data['data'] is List) {
      final results = data['data'] as List;
      return results
          .map((json) => ArtisanSearchResultModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<CollaborationModel> inviteCollaborator({
    required int jobApplicationId,
    required int collaboratorId,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    String? message,
  }) async {
    final body = {
      'job_application_id': jobApplicationId,
      'collaborator_id': collaboratorId,
      'payment_method': paymentMethod.name,
      'payment_amount': paymentAmount,
      if (message != null) 'message': message,
    };

    return post(
      ApiEndpoints.collaborationInvite,
      fromJson: (json) {
        // API returns data in 'data' field
        final data = json['data'] as Map<String, dynamic>;
        return CollaborationModel.fromJson(data);
      },
      data: body,
    );
  }

  @override
  Future<CollaborationListResultModel> getMyCollaborations({
    CollaborationStatus? status,
    CollaborationRole? role,
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (status != null) 'status': status.name,
      if (role != null) 'role': role.value,
    };

    return get(
      ApiEndpoints.myCollaborations,
      fromJson: CollaborationListResultModel.fromJson,
      queryParams: queryParams,
    );
  }

  @override
  Future<CollaborationModel> respondToCollaboration({
    required int collaborationId,
    required CollaborationAction action,
    String? message,
  }) async {
    final body = {
      'action': action.value,
      if (message != null) 'message': message,
    };

    return post(
      ApiEndpoints.collaborationRespond(collaborationId),
      fromJson: (json) {
        // API returns data in 'data' field
        final data = json['data'] as Map<String, dynamic>;
        return CollaborationModel.fromJson(data);
      },
      data: body,
    );
  }

  @override
  Future<List<CollaborationModel>> getJobCollaborators({
    required int jobApplicationId,
  }) async {
    final response = await dio.get(
      ApiEndpoints.jobCollaborators(jobApplicationId),
    );

    // API returns data with 'collaborators' array
    final data = response.data['data'] as Map<String, dynamic>;
    final collaboratorsList = data['collaborators'] as List;
    return collaboratorsList
        .cast<Map<String, dynamic>>()
        .map((c) => CollaborationModel.fromJson(c))
        .toList();
  }
}
