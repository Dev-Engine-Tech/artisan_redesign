import 'package:bloc/bloc.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_jobs.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_applications.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/apply_to_job.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/accept_agreement.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/request_change.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/core/bloc/cached_bloc_mixin.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart'
    show JobModel;

export 'package:artisans_circle/features/jobs/presentation/bloc/job_event.dart';
export 'package:artisans_circle/features/jobs/presentation/bloc/job_state.dart';

import 'package:artisans_circle/features/jobs/presentation/bloc/job_event.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_state.dart';
import 'dart:developer' as dev;

// ✅ WEEK 4: Added CachedBlocMixin for automatic caching
class JobBloc extends Bloc<JobEvent, JobState> with CachedBlocMixin {
  final GetJobs getJobs;
  final GetApplications getApplications;
  final ApplyToJob applyToJob;
  final AcceptAgreement acceptAgreement;
  final RequestChange requestChange;

  JobBloc({
    required this.getJobs,
    required this.getApplications,
    required this.applyToJob,
    required this.acceptAgreement,
    required this.requestChange,
  }) : super(const JobStateInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<RefreshJobs>(_onRefreshJobs);
    on<LoadApplications>(_onLoadApplications);
    on<LoadOngoingJobs>(_onLoadOngoingJobs);
    on<LoadCompletedJobs>(_onLoadCompletedJobs);
    on<ApplyToJobEvent>(_onApplyToJob);
    on<AcceptAgreementEvent>(_onAcceptAgreement);
    on<RequestChangeEvent>(_onRequestChange);
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(const JobStateLoading());
    try {
      // ✅ WEEK 4: Added caching with 5 minute TTL
      final cacheKey = _jobsCacheKey(
        page: event.page,
        limit: event.limit,
        search: event.search,
        saved: event.saved ?? false,
        match: event.match ?? false,
        category: event.category,
        state: event.state,
      );

      final list = await executeWithCache(
        cacheKey: cacheKey,
        fetch: () => getJobs(
          page: event.page,
          limit: event.limit,
          search: event.search,
          saved: event.saved,
          match: event.match,
          postedDate: event.postedDate,
          workMode: event.workMode,
          budgetType: event.budgetType,
          duration: event.duration,
          category: event.category,
          state: event.state,
          lgas: event.lgas,
        ),
        // Cache as JSON list and restore back to domain entities
        fromJson: (json) => (json as List)
            .map((e) => JobModel.fromJson(e as Map<String, dynamic>).toEntity())
            .toList(),
        toJson: (jobs) => jobs
            .map((job) => {
                  'id': (job).id,
                  'title': job.title,
                  'category': job.category,
                  'description': job.description,
                  // Prefer job_address key which our model also understands
                  'job_address': job.address,
                  'min_budget': job.minBudget,
                  'max_budget': job.maxBudget,
                  'duration': job.duration,
                  'applied': job.applied,
                  'saved': job.saved,
                  'thumbnail_url': job.thumbnailUrl,
                  'proposal': job.proposal,
                  'payment_type': job.paymentType,
                  'desired_pay': job.desiredPay,
                  'date_created': job.dateCreated?.toIso8601String(),
                  'status': job.status.name,
                  'project_status': job.projectStatus.name,
                  // Keep materials empty in cache JSON to avoid type casting issues
                  'materials': const <Map<String, dynamic>>[],
                })
            .toList(),
        ttl: const Duration(minutes: 5),
      );
      emit(JobStateLoaded(jobs: list));
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  // ✅ WEEK 4: Cache key generation
  String _jobsCacheKey({
    int page = 1,
    int limit = 20,
    String? search,
    bool saved = false,
    bool match = false,
    String? category,
    String? state,
  }) {
    return 'jobs_p${page}_l${limit}_s${search ?? ''}_sv${saved}_m${match}_c${category ?? ''}_st${state ?? ''}';
  }

  Future<void> _onRefreshJobs(RefreshJobs event, Emitter<JobState> emit) async {
    try {
      final list = await getJobs(page: 1, limit: event.limit);
      emit(JobStateLoaded(jobs: list));
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onLoadApplications(
      LoadApplications event, Emitter<JobState> emit) async {
    dev.log('Loading applications page=${event.page} limit=${event.limit}',
        name: 'JobBloc');
    emit(const JobStateLoading());
    try {
      final list = await getApplications(page: event.page, limit: event.limit);
      dev.log('Received ${list.length} applications', name: 'JobBloc');
      emit(JobStateAppliedSuccess(jobs: list, jobId: ''));
      dev.log('Emitted JobStateAppliedSuccess with ${list.length} jobs',
          name: 'JobBloc');
    } catch (e) {
      dev.log('Error loading applications: $e', name: 'JobBloc', error: e);
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onApplyToJob(
      ApplyToJobEvent event, Emitter<JobState> emit) async {
    emit(const JobStateApplying());
    try {
      final ok = await applyToJob(event.application);
      if (ok) {
        // After successful apply, refresh applied jobs list
        final list = await getApplications();
        emit(JobStateAppliedSuccess(
            jobs: list, jobId: event.application.job.toString()));
      } else {
        emit(const JobStateError(message: 'Failed to apply to job'));
      }
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onAcceptAgreement(
      AcceptAgreementEvent event, Emitter<JobState> emit) async {
    emit(JobStateAcceptingAgreement(jobId: event.jobId));
    try {
      final ok = await acceptAgreement(event.jobId);
      if (ok) {
        final list = await getJobs();
        emit(JobStateAgreementAccepted(jobs: list, jobId: event.jobId));
      } else {
        emit(const JobStateError(message: 'Failed to accept agreement'));
      }
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onRequestChange(
      RequestChangeEvent event, Emitter<JobState> emit) async {
    emit(JobStateRequestingChange(jobId: event.jobId));
    try {
      final ok = await requestChange(jobId: event.jobId, reason: event.reason);
      if (ok) {
        final list = await getJobs();
        emit(JobStateChangeRequested(jobs: list, jobId: event.jobId));
      } else {
        emit(const JobStateError(message: 'Failed to request change'));
      }
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onLoadOngoingJobs(
      LoadOngoingJobs event, Emitter<JobState> emit) async {
    emit(const JobStateLoading());
    try {
      // Use existing getJobs endpoint and filter client-side for ongoing jobs
      final allJobs = await getJobs(page: event.page, limit: event.limit);
      final ongoingJobs = allJobs
          .where((job) =>
              job.status == JobStatus.inProgress ||
              job.status == JobStatus.accepted ||
              job.projectStatus == AppliedProjectStatus.ongoing)
          .toList();
      emit(JobStateOngoingLoaded(ongoingJobs: ongoingJobs));
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onLoadCompletedJobs(
      LoadCompletedJobs event, Emitter<JobState> emit) async {
    emit(const JobStateLoading());
    try {
      // Use existing getJobs endpoint and filter client-side for completed jobs
      final allJobs = await getJobs(page: event.page, limit: event.limit);
      final completedJobs = allJobs
          .where((job) =>
              job.status == JobStatus.completed ||
              job.projectStatus == AppliedProjectStatus.completed)
          .toList();
      emit(JobStateCompletedLoaded(completedJobs: completedJobs));
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }
}
