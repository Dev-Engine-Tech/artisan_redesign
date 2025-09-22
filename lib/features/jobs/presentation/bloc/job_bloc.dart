import 'package:bloc/bloc.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_jobs.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/apply_to_job.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/accept_agreement.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/request_change.dart';

export 'package:artisans_circle/features/jobs/presentation/bloc/job_event.dart';
export 'package:artisans_circle/features/jobs/presentation/bloc/job_state.dart';

import 'package:artisans_circle/features/jobs/presentation/bloc/job_event.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final GetJobs getJobs;
  final ApplyToJob applyToJob;
  final AcceptAgreement acceptAgreement;
  final RequestChange requestChange;

  JobBloc({
    required this.getJobs,
    required this.applyToJob,
    required this.acceptAgreement,
    required this.requestChange,
  }) : super(const JobStateInitial()) {
    on<LoadJobs>(_onLoadJobs);
    on<RefreshJobs>(_onRefreshJobs);
    on<ApplyToJobEvent>(_onApplyToJob);
    on<AcceptAgreementEvent>(_onAcceptAgreement);
    on<RequestChangeEvent>(_onRequestChange);
  }

  Future<void> _onLoadJobs(LoadJobs event, Emitter<JobState> emit) async {
    emit(const JobStateLoading());
    try {
      final list = await getJobs(page: event.page, limit: event.limit);
      emit(JobStateLoaded(jobs: list));
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onRefreshJobs(RefreshJobs event, Emitter<JobState> emit) async {
    try {
      final list = await getJobs(page: 1, limit: event.limit);
      emit(JobStateLoaded(jobs: list));
    } catch (e) {
      emit(JobStateError(message: e.toString()));
    }
  }

  Future<void> _onApplyToJob(
      ApplyToJobEvent event, Emitter<JobState> emit) async {
    emit(const JobStateApplying());
    try {
      final ok = await applyToJob(event.application);
      if (ok) {
        // after successful apply, refresh list (simple approach)
        final list = await getJobs();
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
    // Use repository.applyToJob as the underlying operation for accepting agreement
    // (the repository currently models server-side update via applyToJob).
    emit(const JobStateApplying());
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
    emit(const JobStateApplying());
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
}
