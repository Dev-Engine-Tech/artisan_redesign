import 'package:dio/dio.dart';
import '../models/client_profile_model.dart';

abstract class ClientRemoteDataSource {
  Future<ClientProfileModel> getClientProfile(int clientId);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  final Dio dio;

  ClientRemoteDataSourceImpl({required this.dio});

  @override
  Future<ClientProfileModel> getClientProfile(int clientId) async {
    try {
      final endpoint = '/client/api/about/client/$clientId/';
      // ignore: avoid_print
      print('[ClientRemoteDataSource] Fetching client profile: $endpoint');

      final response = await dio.get(endpoint);

      // ignore: avoid_print
      print('[ClientRemoteDataSource] Response status: ${response.statusCode}');
      // ignore: avoid_print
      print(
          '[ClientRemoteDataSource] Response data type: ${response.data.runtimeType}');
      // ignore: avoid_print
      print('[ClientRemoteDataSource] Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle different response formats
        dynamic data = response.data;

        // If response is wrapped in a data field
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          data = data['data'];
        }

        // Ensure we have a Map
        if (data is! Map<String, dynamic>) {
          throw Exception(
              'Invalid response format: expected Map but got ${data.runtimeType}');
        }

        return ClientProfileModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to load client profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // ignore: avoid_print
      print(
          '[ClientRemoteDataSource] DioException: ${e.message}, Response: ${e.response?.data}');

      // Provide more detailed error message
      if (e.response?.statusCode == 500) {
        throw Exception(
            'Server error (500): The client profile endpoint is not available or encountered an error');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Client profile not found');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[ClientRemoteDataSource] Error: $e');
      throw Exception('Failed to load client profile: $e');
    }
  }
}
