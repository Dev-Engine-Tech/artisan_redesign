import 'dart:convert';
import 'package:artisans_circle/core/network/api_client.dart';
import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobModel>> getJobs({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  });

  Future<List<JobModel>> getApplications({
    int page = 1,
    int limit = 20,
  });

  Future<JobModel> getJobDetails(String jobId);

  Future<bool> applyToJob(JobApplication application);

  Future<bool> acceptAgreement(String jobId);

  Future<bool> requestChange({
    required String jobId,
    required String reason,
  });

  Future<bool> saveJob(String jobId);
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  final ApiClient apiClient;

  JobsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<JobModel>> getJobs({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category.isNotEmpty) 'category': category,
    };

    final response = await apiClient.get(
      ApiEndpoints.jobs,
      queryParams: queryParams,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> jobsJson =
          jsonData['results'] ?? jsonData['data'] ?? [];

      return jobsJson.map((json) => JobModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load jobs: ${response.statusCode}');
    }
  }

  @override
  Future<List<JobModel>> getApplications({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    final response = await apiClient.get(
      ApiEndpoints.appliedJobs,
      queryParams: queryParams,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> applicationsJson =
          jsonData['results'] ?? jsonData['data'] ?? [];

      return applicationsJson.map((json) {
        // Applications might have job nested inside
        final jobData = json['job'] ?? json;
        // Mark as coming from applications so parsing avoids current user fields
        return JobModel.fromJson(jobData, isFromApplications: true);
      }).toList();
    } else {
      throw Exception('Failed to load applications: ${response.statusCode}');
    }
  }

  @override
  Future<JobModel> getJobDetails(String jobId) async {
    final response = await apiClient.get('${ApiEndpoints.jobs}$jobId/');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return JobModel.fromJson(jsonData);
    } else if (response.statusCode == 404) {
      throw Exception('Job not found');
    } else {
      throw Exception('Failed to load job details: ${response.statusCode}');
    }
  }

  @override
  Future<bool> applyToJob(JobApplication application) async {
    final requestBody = {
      'job': application.job,
      'duration': application.duration,
      'proposal': application.proposal,
      'payment_type': application.paymentType,
      'desired_pay': application.desiredPay,
      'milestones': application.milestones,
      'materials': application.materials,
      'attachments': application.attachments,
    };

    final response = await apiClient.post(
      ApiEndpoints.jobApplications,
      body: requestBody,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> acceptAgreement(String jobId) async {
    final response = await apiClient.post(
      ApiEndpoints.acceptAgreementByProjectId(jobId),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> requestChange({
    required String jobId,
    required String reason,
  }) async {
    final requestBody = {
      'job_id': jobId,
      'reason': reason,
      'change_type': 'request_modification',
    };

    final response = await apiClient.post(
      '${ApiEndpoints.jobs}$jobId/request-change/',
      body: requestBody,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> saveJob(String jobId) async {
    final response = await apiClient.patch(
      ApiEndpoints.saveOrUnsaveJobById(jobId),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
