import 'package:dio/dio.dart';
import '../models/job_model.dart';
import '../models/artisan_invitation_model.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
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

  /// Fetches job invitations from clients (LEGACY - use fetchArtisanInvitations instead)
  Future<List<JobModel>> fetchJobInvitations({int page = 1, int limit = 20});

  /// Respond to a job invitation (LEGACY - use respondToArtisanInvitation instead)
  Future<bool> respondToJobInvitation(String invitationId, {required bool accept});

  /// Fetches artisan invitations using v1 endpoint (/invitation/api/artisan-invitations/)
  Future<List<ArtisanInvitationModel>> fetchArtisanInvitations({int page = 1, int limit = 20});

  /// Fetches recent artisan invitations (top 5) using v1 endpoint (/invitation/api/recent-artisan-invitations/)
  Future<List<ArtisanInvitationModel>> fetchRecentArtisanInvitations();

  /// Fetch single artisan invitation detail by ID
  Future<ArtisanInvitationModel> fetchArtisanInvitationDetail(int invitationId);

  /// Respond to artisan invitation using v1 PATCH endpoint with status and optional rejection_reason
  Future<bool> respondToArtisanInvitation(int invitationId, {required String status, String? rejectionReason});
}

class JobRemoteDataSourceImpl extends BaseRemoteDataSource
    implements JobRemoteDataSource {
  JobRemoteDataSourceImpl(super.dio);

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
        // Some backends expect page_size instead of limit. Send both.
        'page_size': limit,
      };
      if (search != null && search.isNotEmpty) qp['search'] = search;
      if (match != null) qp['match'] = match;
      if (saved != null) qp['saved'] = saved;
      if (postedDate != null && postedDate.isNotEmpty) {
        qp['posted_date'] = postedDate;
      }
      if (workMode != null && workMode.isNotEmpty) qp['work_mode'] = workMode;
      if (budgetType != null && budgetType.isNotEmpty) {
        qp['budget_type'] = budgetType;
      }
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
        final body = response.data;

        List listFromBody(dynamic b) {
          if (b is List) return b;
          if (b is Map) {
            // Handle common paginated shapes, including nested maps
            const keys = ['results', 'data', 'items', 'jobs', 'records'];
            for (final k in keys) {
              final v = b[k];
              if (v is List) return v;
              if (v is Map) {
                for (final kk in keys) {
                  final vv = v[kk];
                  if (vv is List) return vv;
                }
              }
            }
          }
          return const [];
        }

        final list = listFromBody(body);
        if (list.isEmpty && body is Map) {
          // If backend returns empty structure without list key, treat as empty set
          // instead of throwing, to avoid blocking UI entirely.
        }

        final jobs = list
            .map((e) {
              try {
                final jobData = Map<String, dynamic>.from(e as Map);
                return JobModel.fromJson(jobData, isFromApplications: false);
              } catch (_) {
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();

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
      // Support both limit and page_size naming
      queryParameters: {'page': page, 'limit': limit, 'page_size': limit},
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final body = response.data;

      List listFromBody(dynamic b) {
        if (b is List) return b;
        if (b is Map) {
          // Common keys for applications collections (support nested under data)
          const keys = ['applications', 'results', 'data', 'items', 'records'];
          for (final k in keys) {
            final v = b[k];
            if (v is List) return v;
            if (v is Map) {
              for (final kk in keys) {
                final vv = v[kk];
                if (vv is List) return vv;
              }
            }
          }
        }
        return const [];
      }

      final list = listFromBody(body);
      if (list.isEmpty && body is Map) {
        // Treat as empty applications rather than erroring
      }

      final jobs = list
          .map((e) {
            try {
              final appData = Map<String, dynamic>.from(e as Map);
              final jobData = appData['job'] is Map
                  ? Map<String, dynamic>.from(appData['job'] as Map)
                  : appData;
              return JobModel.fromJson(jobData, isFromApplications: true);
            } catch (_) {
              return null;
            }
          })
          .where((job) => job != null)
          .cast<JobModel>()
          .toList();

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
    final Map<String, dynamic> applicationData = application.toJson();
    // Ensure timeline field variants are present for different backends
    if (applicationData['duration'] is String &&
        (applicationData['project_timeline'] == null ||
            (applicationData['project_timeline'] as String?)?.isEmpty ==
                true)) {
      applicationData['project_timeline'] = applicationData['duration'];
    }

    // Helper to map human-friendly duration to API codes used in some variants
    String durationCode(String value) {
      final s = value.trim().toLowerCase();
      if (s.contains('24') || s.contains('day')) return '<day';
      if (s.contains('week')) return '<week';
      if (s.contains('1 - 3') || s.contains('1-3')) return '<3months';
      if (s.contains('3+') || s.contains('>3')) return '>3months';
      if (s.contains('less') && s.contains('month')) return '<month';
      // Fallback to generic month bucket
      return '<month';
    }

    try {
      print('🚀 =================================');
      print('🚀 APPLY TO JOB - REQUEST DETAILS');
      print('🚀 =================================');
      print('📍 URL: ${ApiEndpoints.applyToJob}');
      print('📦 Request Body:');
      applicationData.forEach((key, value) {
        print('   $key: $value');
      });
      print('🚀 =================================\n');

      final response =
          await dio.post(ApiEndpoints.applyToJob, data: applicationData);

      print('✅ =================================');
      print('✅ APPLY TO JOB - RESPONSE DETAILS');
      print('✅ =================================');
      print('📊 Status Code: ${response.statusCode}');
      print('📊 Status Message: ${response.statusMessage}');
      print('📦 Response Data Type: ${response.data.runtimeType}');
      print('📦 Response Data: ${response.data}');
      print('✅ =================================\n');

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
      print('❌ =================================');
      print('❌ APPLY TO JOB - ERROR DETAILS');
      print('❌ =================================');
      print('🔴 Error Type: ${e.type}');
      print('🔴 Error Message: ${e.message}');
      print('📊 Response Status Code: ${e.response?.statusCode}');
      print('📊 Response Status Message: ${e.response?.statusMessage}');
      print('📦 Response Data Type: ${e.response?.data.runtimeType}');
      print('📦 Response Data: ${e.response?.data}');
      print('📦 Response Headers: ${e.response?.headers}');
      print('❌ =================================\n');
      final data = e.response?.data;
      String message = 'Failed to apply to job';
      if (data is Map) {
        // Try common error shapes
        final primary = data['detail'] ?? data['message'] ?? data['error'];
        if (primary != null) {
          message = primary.toString();
        } else {
          // Flatten typical DRF field errors: { field: ["msg"], ... }
          final parts = <String>[];
          data.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              parts.add('$key: ${value.first}');
            } else if (value is String) {
              parts.add('$key: $value');
            }
          });
          if (parts.isNotEmpty) {
            message = parts.join('; ');
          }
        }

        // If server rejects duration choice, retry with code-based value for compatibility
        final durationErrors = data['duration'];
        final bool invalidDuration = (durationErrors is List &&
                durationErrors.join(' ').toLowerCase().contains('valid')) ||
            message.toLowerCase().contains('duration') &&
                message.toLowerCase().contains('valid');

        if (invalidDuration && applicationData['duration'] is String) {
          try {
            final Map<String, dynamic> fallbackPayload =
                Map.of(applicationData);
            final current = fallbackPayload['duration'] as String;
            final code = durationCode(current);
            fallbackPayload['duration'] = code;
            // Some backends accept alternate keys; include them defensively.
            fallbackPayload['project_timeline'] = code;
            final r2 =
                await dio.post(ApiEndpoints.applyToJob, data: fallbackPayload);
            if (r2.statusCode != null &&
                r2.statusCode! >= 200 &&
                r2.statusCode! < 300) {
              return true;
            }
          } catch (_) {
            // fall through to throw with original message
          }
        }
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Failed to apply to job: $e');
    }
  }

  @override
  Future<bool> requestChange(String jobId, {required String reason}) async {
    try {
      await postVoid(
        ApiEndpoints.jobRequestChangeById(jobId),
        data: {'reason': reason},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> acceptAgreement(String projectId) async {
    try {
      await postVoid(ApiEndpoints.acceptAgreementByProjectId(projectId));
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<JobModel>> fetchJobInvitations({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.jobInvitations,
        queryParameters: {'page': page, 'limit': limit, 'page_size': limit},
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final body = response.data;

        List listFromBody(dynamic b) {
          if (b is List) return b;
          if (b is Map) {
            const keys = ['results', 'data', 'items', 'invitations', 'records'];
            for (final k in keys) {
              final v = b[k];
              if (v is List) return v;
              if (v is Map) {
                for (final kk in keys) {
                  final vv = v[kk];
                  if (vv is List) return vv;
                }
              }
            }
          }
          return const [];
        }

        final list = listFromBody(body);
        final invitations = list
            .map((e) {
              try {
                final inviteData = Map<String, dynamic>.from(e as Map);
                // Job invitations typically have a 'job' field with job details
                final jobData = inviteData['job'] is Map
                    ? Map<String, dynamic>.from(inviteData['job'] as Map)
                    : inviteData;
                return JobModel.fromJson(jobData, isFromApplications: false);
              } catch (_) {
                return null;
              }
            })
            .where((job) => job != null)
            .cast<JobModel>()
            .toList();

        return invitations;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to fetch job invitations',
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
  Future<bool> respondToJobInvitation(String invitationId, {required bool accept}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.respondToInvitation,
        data: {
          'invitation_id': invitationId,
          'action': accept ? 'accept' : 'decline',
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ArtisanInvitationModel>> fetchArtisanInvitations({int page = 1, int limit = 20}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.artisanInvitations,
        queryParameters: {'page': page, 'limit': limit, 'page_size': limit},
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final body = response.data;

        List listFromBody(dynamic b) {
          if (b is List) return b;
          if (b is Map) {
            const keys = ['results', 'data', 'items', 'invitations', 'records'];
            for (final k in keys) {
              final v = b[k];
              if (v is List) return v;
              if (v is Map) {
                for (final kk in keys) {
                  final vv = v[kk];
                  if (vv is List) return vv;
                }
              }
            }
          }
          return const [];
        }

        final list = listFromBody(body);
        final invitations = list
            .map((e) {
              try {
                final inviteData = Map<String, dynamic>.from(e as Map);
                return ArtisanInvitationModel.fromJson(inviteData);
              } catch (err) {
                // Log parse error but don't fail entire list
                return null;
              }
            })
            .where((invitation) => invitation != null)
            .cast<ArtisanInvitationModel>()
            .toList();

        return invitations;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to fetch artisan invitations',
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
  Future<List<ArtisanInvitationModel>> fetchRecentArtisanInvitations() async {
    try {
      print('🔍 Fetching recent artisan invitations from: ${ApiEndpoints.recentArtisanInvitations}');
      final response = await dio.get(ApiEndpoints.recentArtisanInvitations);

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response data type: ${response.data.runtimeType}');
      print('📦 Response data: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final body = response.data;

        List listFromBody(dynamic b) {
          if (b is List) return b;
          if (b is Map) {
            const keys = ['results', 'data', 'items', 'invitations', 'records'];
            for (final k in keys) {
              final v = b[k];
              if (v is List) return v;
              if (v is Map) {
                for (final kk in keys) {
                  final vv = v[kk];
                  if (vv is List) return vv;
                }
              }
            }
          }
          return const [];
        }

        final list = listFromBody(body);
        print('📋 Extracted list length: ${list.length}');

        final invitations = list
            .map((e) {
              try {
                final inviteData = Map<String, dynamic>.from(e as Map);
                return ArtisanInvitationModel.fromJson(inviteData);
              } catch (err) {
                print('❌ Error parsing invitation: $err');
                return null;
              }
            })
            .where((invitation) => invitation != null)
            .cast<ArtisanInvitationModel>()
            .toList();

        print('✅ Successfully parsed ${invitations.length} invitations');
        return invitations;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to fetch recent artisan invitations',
          response: Response(
              requestOptions: response.requestOptions,
              statusCode: response.statusCode,
              data: response.data),
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      print('💥 Error fetching recent artisan invitations: $e');
      rethrow;
    }
  }

  @override
  Future<ArtisanInvitationModel> fetchArtisanInvitationDetail(int invitationId) async {
    try {
      final response = await dio.get(ApiEndpoints.artisanInvitationDetail(invitationId));

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final body = response.data;
        return ArtisanInvitationModel.fromJson(Map<String, dynamic>.from(body as Map));
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to fetch artisan invitation detail',
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
  Future<bool> respondToArtisanInvitation(int invitationId, {required String status, String? rejectionReason}) async {
    try {
      final data = <String, dynamic>{
        'invitation_status': status, // "Accepted" or "Rejected"
      };

      if (status.toLowerCase() == 'rejected' && rejectionReason != null) {
        data['rejection_reason'] = rejectionReason;
      }

      final response = await dio.patch(
        ApiEndpoints.artisanInvitationStatus(invitationId),
        data: data,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
