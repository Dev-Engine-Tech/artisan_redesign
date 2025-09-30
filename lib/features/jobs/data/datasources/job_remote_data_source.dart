import 'package:dio/dio.dart';
import '../models/job_model.dart';
import '../../../../core/api/endpoints.dart';
import '../../domain/entities/job_application.dart';

abstract class JobRemoteDataSource {
  /// Fetches jobs from remote API.
  Future<List<JobModel>> fetchJobs({
    int page = 1,
    int limit = 20,
    String? search,
    bool? saved,
    bool? match,
    String? postedDate,
    String? workMode,
    String? budgetType,
    String? duration,
    String? category,
    String? state,
    String? lgas,
  });

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
  Future<List<JobModel>> fetchJobs({
    int page = 1,
    int limit = 20,
    String? search,
    bool? saved,
    bool? match,
    String? postedDate,
    String? workMode,
    String? budgetType,
    String? duration,
    String? category,
    String? state,
    String? lgas,
  }) async {
    try {
      final qp = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (search != null && search.isNotEmpty) qp['search'] = search;
      if (match != null) qp['match'] = match;
      if (saved != null) qp['saved'] = saved;
      if (postedDate != null && postedDate.isNotEmpty)
        qp['posted_date'] = postedDate;
      if (workMode != null && workMode.isNotEmpty) qp['work_mode'] = workMode;
      if (budgetType != null && budgetType.isNotEmpty)
        qp['budget_type'] = budgetType;
      if (duration != null && duration.isNotEmpty) qp['duration'] = duration;
      if (category != null && category.isNotEmpty) {
        // Prefer sub_categories for jobs (CSV of subcategory IDs)
        qp['sub_categories'] = category;
        // Some backends accept categories, or only a single category
        qp['categories'] = category;
        final firstCat = category.split(',').first;
        qp['category'] = firstCat;
        qp['sub_category'] = firstCat;
      }
      if (state != null && state.isNotEmpty) {
        final isStateId = int.tryParse(state) != null;
        if (isStateId) {
          qp['state_id'] = state;
        } else {
          qp['state'] = state; // state name
        }
      }
      if (lgas != null && lgas.isNotEmpty) {
        // Determine if CSV is IDs or names
        final tokens = lgas.split(',');
        final allNumeric = tokens.every((t) => int.tryParse(t.trim()) != null);
        if (allNumeric) {
          qp['lga_ids'] = lgas; // CSV of IDs
          qp['lgas'] = lgas; // some backends accept 'lgas' as ids
        } else {
          // Likely names
          qp['local_government'] = lgas; // CSV of names
          qp['lgas'] = lgas;
        }
      }

      final response = await dio.get(
        ApiEndpoints.jobs,
        queryParameters: qp,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;

        List<JobModel> jobs = [];

        if (data is List) {
          jobs = data
              .map((e) {
                try {
                  final jobData = e as Map<String, dynamic>;
                  return JobModel.fromJson(jobData, isFromApplications: false);
                } catch (e) {
                  return null;
                }
              })
              .where((job) => job != null)
              .cast<JobModel>()
              .toList();
        } else if (data is Map && data['data'] is List) {
          final dataList = data['data'] as List;
          jobs = dataList
              .map((e) {
                try {
                  final jobData = e as Map<String, dynamic>;
                  return JobModel.fromJson(jobData, isFromApplications: false);
                } catch (e) {
                  return null;
                }
              })
              .where((job) => job != null)
              .cast<JobModel>()
              .toList();
        } else if (data is Map && data['results'] is List) {
          final resultsList = data['results'] as List;
          jobs = resultsList
              .map((e) {
                try {
                  final jobData = e as Map<String, dynamic>;
                  return JobModel.fromJson(jobData, isFromApplications: false);
                } catch (e) {
                  return null;
                }
              })
              .where((job) => job != null)
              .cast<JobModel>()
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

        return jobs;
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<JobModel>> loadApplications(
      {int page = 1, int limit = 20}) async {
    final response = await dio.get(
      ApiEndpoints.appliedJobs,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;

      List<JobModel> jobs = [];

      if (data is List) {
        jobs = data
            .map((e) {
              try {
                final appData = e as Map<String, dynamic>;
                final jobData = appData['job'] ?? appData;
                return JobModel.fromJson(jobData, isFromApplications: true);
              } catch (e) {
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();
      } else if (data is Map && data['data'] is List) {
        final dataList = data['data'] as List;
        jobs = dataList
            .map((e) {
              try {
                final appData = e as Map<String, dynamic>;
                final jobData = appData['job'] ?? appData;
                return JobModel.fromJson(jobData, isFromApplications: true);
              } catch (e) {
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();
      } else if (data is Map && data['results'] is List) {
        final resultsList = data['results'] as List;
        jobs = resultsList
            .map((e) {
              try {
                final appData = e as Map<String, dynamic>;
                final jobData = appData['job'] ?? appData;
                return JobModel.fromJson(jobData, isFromApplications: true);
              } catch (e) {
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();
      } else {
        return []; // Return empty list if no applications found
      }

      return jobs;
    } else {
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

    try {
      final response =
          await dio.post(ApiEndpoints.applyToJob, data: applicationData);

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
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Failed to apply to job';
      if (data is Map) {
        // Try common error shapes
        message =
            (data['detail'] ?? data['message'] ?? data['error'] ?? message)
                .toString();
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to apply to job: $e');
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
