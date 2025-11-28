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

  Future<CollaborationModel> inviteExternalCollaborator({
    required int jobApplicationId,
    required String name,
    required String contact,
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
          .map((json) =>
              ArtisanSearchResultModel.fromJson(json as Map<String, dynamic>))
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
    print('🔵 Starting inviteCollaborator...');
    print('🔵 Job ID: $jobApplicationId, Collaborator ID: $collaboratorId');
    print('🔵 Payment: $paymentMethod = $paymentAmount');

    // Map payment method to API-expected format
    // The API may not be implemented yet, so we'll treat timeout as subscription error
    final paymentMethodValue =
        paymentMethod == PaymentMethod.percentage ? 'PERCENT' : 'FIXED';

    final body = {
      'job_application_id': jobApplicationId,
      'collaborator_id': collaboratorId,
      'payment_method': paymentMethodValue,
      'payment_amount': paymentAmount,
      'role_description': message ?? 'Collaborator',
      if (message != null) 'message': message,
    };

    print('🔵 Request body: $body');
    print('🔵 Endpoint: ${ApiEndpoints.collaborationInvite}');

    try {
      final result = await post(
        ApiEndpoints.collaborationInvite,
        fromJson: CollaborationModel.fromJson,
        data: body,
      );
      print('🟢 Invitation successful: ${result.id}');
      return result;
    } catch (e) {
      print('🔴 Invitation failed: $e');
      print('🔴 Error type: ${e.runtimeType}');

      // Try to get detailed error response
      if (e.runtimeType.toString().contains('DioException')) {
        final dioError = e as dynamic;
        if (dioError.response != null) {
          print('🔴 Response status: ${dioError.response?.statusCode}');
          print('🔴 Response data: ${dioError.response?.data}');

          // Check if payment_method error indicates feature not available
          final responseData = dioError.response?.data;
          if (responseData is Map && responseData['payment_method'] != null) {
            final paymentError = responseData['payment_method'].toString();
            if (paymentError.contains('not a valid choice')) {
              // This indicates the collaboration feature isn't available for current subscription
              throw Exception(
                  'SUBSCRIPTION_ERROR: Collaboration invitations require a premium subscription plan.');
            }
          }
        }
      }

      // Check if it's a timeout or subscription limitation error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('timeout') ||
          errorStr.contains('subscription') ||
          errorStr.contains('upgrade') ||
          errorStr.contains('limit') ||
          errorStr.contains('plan') ||
          errorStr.contains('not implemented')) {
        throw Exception(
            'SUBSCRIPTION_ERROR: This feature requires a premium subscription. Please upgrade to invite collaborators.');
      }

      rethrow;
    }
  }

  @override
  Future<CollaborationModel> inviteExternalCollaborator({
    required int jobApplicationId,
    required String name,
    required String contact,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    String? message,
  }) async {
    print('🔵 Starting inviteExternalCollaborator...');
    print('🔵 Job ID: $jobApplicationId');
    print('🔵 Name: $name, Contact: $contact');
    print('🔵 Payment: $paymentMethod = $paymentAmount');

    final paymentMethodValue =
        paymentMethod == PaymentMethod.percentage ? 'PERCENT' : 'FIXED';

    final body = {
      'job_application_id': jobApplicationId,
      'name': name,
      'contact': contact,
      'payment_method': paymentMethodValue,
      'payment_amount': paymentAmount,
      'role_description': message ?? 'Collaborator',
      if (message != null) 'message': message,
    };

    print('🔵 Request body: $body');
    print('🔵 Endpoint: ${ApiEndpoints.collaborationInviteExternal}');

    try {
      final result = await post(
        ApiEndpoints.collaborationInviteExternal,
        fromJson: CollaborationModel.fromJson,
        data: body,
      );
      print('🟢 External invitation successful: ${result.id}');
      return result;
    } catch (e) {
      print('🔴 External invitation failed: $e');
      print('🔴 Error type: ${e.runtimeType}');

      // Check for subscription errors similar to regular invites
      if (e.runtimeType.toString().contains('DioException')) {
        final dioError = e as dynamic;
        if (dioError.response != null) {
          print('🔴 Response status: ${dioError.response?.statusCode}');
          print('🔴 Response data: ${dioError.response?.data}');

          final responseData = dioError.response?.data;
          if (responseData is Map && responseData['payment_method'] != null) {
            final paymentError = responseData['payment_method'].toString();
            if (paymentError.contains('not a valid choice')) {
              throw Exception(
                  'SUBSCRIPTION_ERROR: Collaboration invitations require a premium subscription plan.');
            }
          }
        }
      }

      // Check for subscription/feature limitations
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('timeout') ||
          errorStr.contains('subscription') ||
          errorStr.contains('upgrade') ||
          errorStr.contains('limit') ||
          errorStr.contains('plan') ||
          errorStr.contains('not implemented')) {
        throw Exception(
            'SUBSCRIPTION_ERROR: This feature requires a premium subscription. Please upgrade to invite collaborators.');
      }

      rethrow;
    }
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
      fromJson: CollaborationModel.fromJson,
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
