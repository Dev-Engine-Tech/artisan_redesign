import 'dart:async';

import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/data/datasources/job_remote_data_source.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_application.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/features/jobs/domain/entities/agreement.dart';

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
      applied: index == 1 ||
          index == 3 ||
          index == 5, // mark multiple jobs as applied for demo
      thumbnailUrl: '',
    ),
  );

  // Create some sample applied jobs with different statuses
  final List<JobModel> _appliedJobs = [
    // Job with pending status and agreement - should show "Request Changes" and "View Agreement" buttons
    JobModel(
      id: 'app_1',
      title: 'Kitchen Cabinet Installation',
      category: 'Carpentry',
      description:
          'Install custom kitchen cabinets in modern home. High-quality materials required.',
      address: '12 Victoria Island, Lagos State',
      minBudget: 200000,
      maxBudget: 300000,
      duration: '2-3 weeks',
      applied: true,
      thumbnailUrl: '',
      status: JobStatus.pending,
      projectStatus: AppliedProjectStatus.ongoing,
      agreement: Agreement(
        id: 1,
        deliveryDate: DateTime.parse('2024-02-15T10:00:00Z'),
        agreedPayment: 250000.0,
        comment: 'Cabinet installation agreement with premium materials',
        status: 'pending',
        amount: 250000,
        description: 'Cabinet installation agreement with premium materials',
        deadline: '2024-02-15T10:00:00Z',
      ),
    ),

    // Job with changeRequested status - should show "View Change Request" button
    const JobModel(
      id: 'app_2',
      title: 'Plumbing System Repair',
      category: 'Plumbing',
      description: 'Fix leaking pipes and upgrade bathroom fixtures.',
      address: '45 Lekki Phase 1, Lagos State',
      minBudget: 150000,
      maxBudget: 200000,
      duration: '1 week',
      applied: true,
      thumbnailUrl: '',
      status: JobStatus.changeRequested,
      projectStatus: AppliedProjectStatus.ongoing,
    ),

    // Job with accepted status - should show minimal buttons (just tap to view details)
    const JobModel(
      id: 'app_3',
      title: 'Electrical Wiring Installation',
      category: 'Electrical',
      description: 'Complete electrical wiring for new 3-bedroom apartment.',
      address: '78 Ajah, Lagos State',
      minBudget: 300000,
      maxBudget: 400000,
      duration: '2 weeks',
      applied: true,
      thumbnailUrl: '',
      status: JobStatus.accepted,
      projectStatus: AppliedProjectStatus.ongoing,
    ),

    // Job with inProgress status
    const JobModel(
      id: 'app_4',
      title: 'Furniture Assembly',
      category: 'Furniture',
      description: 'Assemble and install office furniture for startup company.',
      address: '22 Ikeja, Lagos State',
      minBudget: 100000,
      maxBudget: 150000,
      duration: '3 days',
      applied: true,
      thumbnailUrl: '',
      status: JobStatus.inProgress,
      projectStatus: AppliedProjectStatus.ongoing,
    ),

    // Completed job
    const JobModel(
      id: 'app_5',
      title: 'Tile Installation',
      category: 'Tiling',
      description: 'Install ceramic tiles in bathroom and kitchen areas.',
      address: '67 Surulere, Lagos State',
      minBudget: 180000,
      maxBudget: 250000,
      duration: '1 week',
      applied: true,
      thumbnailUrl: '',
      status: JobStatus.completed,
      projectStatus: AppliedProjectStatus.completed,
    ),
  ];

  @override
  Future<List<JobModel>> loadApplications(
      {int page = 1, int limit = 20}) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));

    // Return the sample applied jobs with different statuses
    final start = (page - 1) * limit;
    if (start >= _appliedJobs.length) return <JobModel>[];
    final end = (start + limit) > _appliedJobs.length
        ? _appliedJobs.length
        : (start + limit);
    return _appliedJobs.sublist(start, end);
  }

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
    final idx = _appliedJobs.indexWhere((j) => j.id == jobId);

    // For demo/test data, accept requests for unknown job IDs so the change request
    // flow can complete even when HomePage uses sample IDs not present in _jobs.
    if (idx == -1) {
      return true;
    }

    final model = _appliedJobs[idx];
    // Update status to changeRequested
    _appliedJobs[idx] = JobModel(
      id: model.id,
      title: model.title,
      category: model.category,
      description: model.description,
      address: model.address,
      minBudget: model.minBudget,
      maxBudget: model.maxBudget,
      duration: model.duration,
      applied: model.applied,
      thumbnailUrl: model.thumbnailUrl,
      status: JobStatus.changeRequested,
      projectStatus: model.projectStatus,
      agreement: model.agreement,
    );
    return true;
  }

  @override
  Future<bool> acceptAgreement(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _appliedJobs.indexWhere((j) => j.id == projectId);
    if (idx == -1) return true;

    final model = _appliedJobs[idx];
    _appliedJobs[idx] = JobModel(
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
      status: JobStatus.accepted,
      projectStatus: AppliedProjectStatus.ongoing,
      agreement: model.agreement,
    );
    return true;
  }
}
