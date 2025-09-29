import 'package:dio/dio.dart';
import '../models/job_model.dart';
import '../../../../core/api/endpoints.dart';
import '../../domain/entities/job_application.dart';

abstract class JobRemoteDataSource {
  /// Fetches jobs from remote API.
  Future<List<JobModel>> fetchJobs({int page = 1, int limit = 20});

  /// Loads applied jobs from remote API.
  Future<List<JobModel>> loadApplications({int page = 1, int limit = 20});

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
    print('DEBUG: Fetching jobs - page: $page, limit: $limit');

    try {
      final response = await dio.get(
        ApiEndpoints.jobs,
        queryParameters: {'page': page, 'limit': limit},
      );

      print('DEBUG: Jobs API response status: ${response.statusCode}');
      print('DEBUG: Jobs API response data type: ${response.data.runtimeType}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        print('DEBUG: Jobs API entering success parsing block');
        final data = response.data;
        print('DEBUG: Jobs API response type: ${data.runtimeType}');

        List<JobModel> jobs = [];

        if (data is List) {
          print('DEBUG: Jobs data is List with ${data.length} items');
          jobs = data
              .map((e) {
                try {
                  final jobData = e as Map<String, dynamic>;
                  print('DEBUG: Parsing job: ${jobData['id']} - ${jobData['title']}');
                  return JobModel.fromJson(jobData, isFromApplications: false);
                } catch (e) {
                  print('DEBUG: Error parsing job: $e');
                  return null;
                }
              })
              .where((job) => job != null)
              .cast<JobModel>()
              .toList();
        } else if (data is Map && data['data'] is List) {
          final dataList = data['data'] as List;
          print('DEBUG: Jobs data.data is List with ${dataList.length} items');
          jobs = dataList
              .map((e) {
                try {
                  final jobData = e as Map<String, dynamic>;
                  print('DEBUG: Parsing job: ${jobData['id']} - ${jobData['title']}');
                  return JobModel.fromJson(jobData, isFromApplications: false);
                } catch (e) {
                  print('DEBUG: Error parsing job: $e');
                  return null;
                }
              })
              .where((job) => job != null)
              .cast<JobModel>()
              .toList();
        } else if (data is Map && data['results'] is List) {
          final resultsList = data['results'] as List;
          print('DEBUG: Jobs data.results is List with ${resultsList.length} items');
          jobs = resultsList
              .map((e) {
                try {
                  final jobData = e as Map<String, dynamic>;
                  print('DEBUG: Parsing job: ${jobData['id']} - ${jobData['title']}');
                  return JobModel.fromJson(jobData, isFromApplications: false);
                } catch (e) {
                  print('DEBUG: Error parsing job: $e');
                  return null;
                }
              })
              .where((job) => job != null)
              .cast<JobModel>()
              .toList();
        } else {
          print('DEBUG: Jobs unexpected data format: ${data.runtimeType}');
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

        print('DEBUG: Successfully parsed ${jobs.length} jobs');
        return jobs;
      } else {
        print('DEBUG: Jobs API error - Status: ${response.statusCode}');
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
    } catch (e) {
      print('DEBUG: Jobs API exception: $e');
      rethrow;
    }
  }

  @override
  Future<List<JobModel>> loadApplications({int page = 1, int limit = 20}) async {
    print('DEBUG: Loading applications - page: $page, limit: $limit');

    final response = await dio.get(
      ApiEndpoints.appliedJobs,
      queryParameters: {'page': page, 'limit': limit},
    );

    print('DEBUG: Applications API response status: ${response.statusCode}');

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data;
      print('DEBUG: Applications API response type: ${data.runtimeType}');

      List<JobModel> jobs = [];

      if (data is List) {
        print('DEBUG: Applications data is List with ${data.length} items');
        jobs = data
            .map((e) {
              try {
                final appData = e as Map<String, dynamic>;
                final jobData = appData['job'] ?? appData;
                print('DEBUG: Parsing application job: ${jobData['id']} - ${jobData['title']}');
                return JobModel.fromJson(jobData, isFromApplications: true);
              } catch (e) {
                print('DEBUG: Error parsing application: $e');
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();
      } else if (data is Map && data['data'] is List) {
        final dataList = data['data'] as List;
        print('DEBUG: Applications data.data is List with ${dataList.length} items');
        jobs = dataList
            .map((e) {
              try {
                final appData = e as Map<String, dynamic>;
                final jobData = appData['job'] ?? appData;
                print('DEBUG: Parsing application job: ${jobData['id']} - ${jobData['title']}');
                return JobModel.fromJson(jobData, isFromApplications: true);
              } catch (e) {
                print('DEBUG: Error parsing application: $e');
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();
      } else if (data is Map && data['results'] is List) {
        final resultsList = data['results'] as List;
        print('DEBUG: Applications data.results is List with ${resultsList.length} items');
        jobs = resultsList
            .map((e) {
              try {
                final appData = e as Map<String, dynamic>;
                final jobData = appData['job'] ?? appData;
                print('DEBUG: Parsing application job: ${jobData['id']} - ${jobData['title']}');
                return JobModel.fromJson(jobData, isFromApplications: true);
              } catch (e) {
                print('DEBUG: Error parsing application: $e');
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();
      } else {
        print('DEBUG: Applications unexpected data format: ${data.runtimeType}');
        return []; // Return empty list if no applications found
      }

      print('DEBUG: Successfully parsed ${jobs.length} applications');
      return jobs;
    } else {
      print('DEBUG: Applications API error - Status: ${response.statusCode}');
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Failed to load applications',
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
    final applicationData = application.toJson();
    print('DEBUG: Applying to job with data: $applicationData');
    print('DEBUG: Apply to job endpoint: ${ApiEndpoints.applyToJob}');

    try {
      final response = await dio.post(ApiEndpoints.applyToJob, data: applicationData);

      print('DEBUG: Apply to job response status: ${response.statusCode}');
      print('DEBUG: Apply to job response data: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        // Accept both { "success": true } and 2xx without body
        final data = response.data;
        if (data == null) {
          return true;
        }
        if (data is Map &&
            (data['success'] == true || data['status'] == 'ok' || data['detail'] != null)) {
          return true;
        }
        return true; // optimistic on 2xx
      } else {
        print('DEBUG: Apply to job failed with status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('DEBUG: Apply to job DioException: ${e.response?.statusCode} ${e.message}');
      final data = e.response?.data;
      String message = 'Failed to apply to job';
      if (data is Map) {
        // Try common error shapes
        message = (data['detail'] ?? data['message'] ?? data['error'] ?? message).toString();
      }
      throw Exception(message);
    } catch (e) {
      print('DEBUG: Apply to job exception: $e');
      throw Exception('Failed to apply to job: $e');
    }
  }

  @override
  Future<bool> requestChange(String jobId, {required String reason}) async {
    final payload = <String, dynamic>{'reason': reason};

    final response = await dio.post(ApiEndpoints.jobRequestChangeById(jobId), data: payload);

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
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
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data;
      if (data == null) {
        return true;
      }
      if (data is Map &&
          (data['success'] == true || data['status'] == 'ok' || data['detail'] != null)) {
        return true;
      }
      return true; // optimistic
    }
    return false;
  }
}
