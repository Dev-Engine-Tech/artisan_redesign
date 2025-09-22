import 'dart:async';

import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/data/datasources/job_remote_data_source.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';

/// Simple in-memory fake remote data source used for development and widget tests.
/// Returns deterministic sample data quickly without network calls.
class JobRemoteDataSourceFake implements JobRemoteDataSource {
  final List<JobModel> _jobs = List.generate(
    8,
    (index) => JobModel(
      id: 'job_$index',
      title: index % 2 == 0 ? 'Electrical Home Wiring' : 'Cushion Chair',
      category: index % 2 == 0 ? 'Electrical Engineering' : 'Furniture',
      description:
          'Lorem ipsum dolor sit amet consectetur. Brief description text used for demo purposes. This is job #$index',
      address: '15a, oladipo diya street, Lekki phase 1, Lagos state.',
      minBudget: 150000,
      maxBudget: 200000,
      duration: 'Less than a month',
      applied: index == 1, // mark second job as applied for demo
      thumbnailUrl: '',
    ),
  );

  @override
  Future<bool> applyToJob(JobApplication application) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _jobs.indexWhere((j) => j.id == application.job.toString());

    // In the fake data source we accept unknown job IDs (e.g., sample 'app_*' ids used
    // by the demo HomePage) as successful operations so the UI flow can proceed
    // during development and widget tests.
    if (idx == -1) {
      return true;
    }

    final model = _jobs[idx];
    _jobs[idx] = JobModel(
      id: model.id,
      title: model.title,
      category: model.category,
      description: model.description,
      address: model.address,
      minBudget: model.minBudget,
      maxBudget: model.maxBudget,
      duration: model.duration,
      applied: true,
      thumbnailUrl: model.thumbnailUrl,
    );
    return true;
  }

  @override
  Future<List<JobModel>> fetchJobs({int page = 1, int limit = 20}) async {
    // simulate small delay
    await Future.delayed(const Duration(milliseconds: 250));
    // simple pagination simulation
    final start = (page - 1) * limit;
    if (start >= _jobs.length) return <JobModel>[];
    final end = (start + limit) > _jobs.length ? _jobs.length : (start + limit);
    return _jobs.sublist(start, end);
  }

  @override
  Future<bool> requestChange(String jobId, {required String reason}) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _jobs.indexWhere((j) => j.id == jobId);

    // For demo/test data, accept requests for unknown job IDs so the change request
    // flow can complete even when HomePage uses sample IDs not present in _jobs.
    if (idx == -1) {
      return true;
    }

    final model = _jobs[idx];
    // mark agreementSent as false to indicate a change request was made (fake behavior)
    _jobs[idx] = JobModel(
      id: model.id,
      title: model.title,
      category: model.category,
      description: model.description,
      address: model.address,
      minBudget: model.minBudget,
      maxBudget: model.maxBudget,
      duration: model.duration,
      applied: model.applied,
      agreementSent: false,
      agreementAccepted: false,
      thumbnailUrl: model.thumbnailUrl,
    );
    return true;
  }

  @override
  Future<bool> acceptAgreement(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _jobs.indexWhere((j) => j.id == projectId);
    if (idx == -1) return true;
    final model = _jobs[idx];
    _jobs[idx] = JobModel(
      id: model.id,
      title: model.title,
      category: model.category,
      description: model.description,
      address: model.address,
      minBudget: model.minBudget,
      maxBudget: model.maxBudget,
      duration: model.duration,
      applied: true,
      agreementSent: true,
      agreementAccepted: true,
      thumbnailUrl: model.thumbnailUrl,
    );
    return true;
  }
}
