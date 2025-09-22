import 'package:dio/dio.dart';
import '../models/job_model.dart';
import '../../../../core/api/endpoints.dart';
import '../../domain/entities/job_application.dart';

abstract class JobRemoteDataSource {
  /// Fetches jobs from remote API.
  Future<List<JobModel>> fetchJobs({int page = 1, int limit = 20});

  /// Apply to a job remotely.
  Future<bool> applyToJob(JobApplication application);

  /// Request changes for an application remotely.
  Future<bool> requestChange(String jobId, {required String reason});

  /// Accept agreement for project/application
  Future<bool> acceptAgreement(String projectId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio dio;

  JobRemoteDataSourceImpl(this.dio);

  @override
  Future<List<JobModel>> fetchJobs({int page = 1, int limit = 20}) async {
    final response = await dio.get(
      ApiEndpoints.jobs,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data is List) {
        return data
            .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data['results'] is List) {
        return (data['results'] as List)
            .map((e) => JobModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Unexpected response format',
          response: Response(
              requestOptions: response.requestOptions,
              statusCode: response.statusCode,
              data: response.data),
          type: DioExceptionType.badResponse,
        );
      }
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Failed to fetch jobs',
        response: Response(
            requestOptions: response.requestOptions,
            statusCode: response.statusCode,
            data: response.data),
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<bool> applyToJob(JobApplication application) async {
    final response =
        await dio.post(ApiEndpoints.applyToJob, data: application.toJson());

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      // Accept both { "success": true } and 2xx without body
      final data = response.data;
      if (data == null) {
        return true;
      }
      if (data is Map &&
          (data['success'] == true ||
              data['status'] == 'ok' ||
              data['detail'] != null)) {
        return true;
      }
      return true; // optimistic on 2xx
    } else {
      return false;
    }
  }

  @override
  Future<bool> requestChange(String jobId, {required String reason}) async {
    final payload = <String, dynamic>{'reason': reason};

    final response =
        await dio.post(ApiEndpoints.jobRequestChangeById(jobId), data: payload);

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data == null) {
        return true;
      }
      if (data is Map && (data['success'] == true || data['status'] == 'ok')) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  @override
  Future<bool> acceptAgreement(String projectId) async {
    final url = ApiEndpoints.acceptAgreementByProjectId(projectId);
    final response = await dio.post(url);
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data == null) {
        return true;
      }
      if (data is Map &&
          (data['success'] == true ||
              data['status'] == 'ok' ||
              data['detail'] != null)) {
        return true;
      }
      return true; // optimistic
    }
    return false;
  }
}
