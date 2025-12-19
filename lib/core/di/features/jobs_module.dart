import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:artisans_circle/features/jobs/data/datasources/job_remote_data_source.dart';
import 'package:artisans_circle/features/jobs/data/datasources/job_remote_data_source_fake.dart';
import 'package:artisans_circle/features/jobs/data/repositories/job_repository_impl.dart';
import 'package:artisans_circle/features/jobs/domain/repositories/job_repository.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_jobs.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_applications.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/apply_to_job.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/accept_agreement.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/request_change.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_job_invitations.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/respond_to_job_invitation.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_artisan_invitations.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/get_recent_artisan_invitations.dart';
import 'package:artisans_circle/features/jobs/domain/usecases/respond_to_artisan_invitation.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';

/// Jobs feature module
///
/// Registers jobs-related dependencies including data sources, repositories,
/// use cases, and the JobBloc.
class JobsModule {
  static bool _initialized = false;

  /// Initialize jobs dependencies
  static Future<void> init(GetIt getIt, {bool useFake = false}) async {
    if (_initialized) return;

    // Data sources
    if (useFake) {
      getIt.registerLazySingleton<JobRemoteDataSource>(
        () => JobRemoteDataSourceFake(),
      );
    } else {
      getIt.registerLazySingleton<JobRemoteDataSource>(
        () => JobRemoteDataSourceImpl(getIt<Dio>()),
      );
    }

    // Repositories
    getIt.registerLazySingleton<JobRepository>(
      () => JobRepositoryImpl(remoteDataSource: getIt<JobRemoteDataSource>()),
    );

    // Use cases
    getIt.registerLazySingleton<GetJobs>(
      () => GetJobs(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<GetApplications>(
      () => GetApplications(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<ApplyToJob>(
      () => ApplyToJob(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<AcceptAgreement>(
      () => AcceptAgreement(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<RequestChange>(
      () => RequestChange(getIt<JobRepository>()),
    );

    // Job invitations use cases (legacy)
    getIt.registerLazySingleton<GetJobInvitations>(
      () => GetJobInvitations(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<RespondToJobInvitation>(
      () => RespondToJobInvitation(getIt<JobRepository>()),
    );

    // Artisan invitations use cases (v1)
    getIt.registerLazySingleton<GetArtisanInvitations>(
      () => GetArtisanInvitations(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<GetRecentArtisanInvitations>(
      () => GetRecentArtisanInvitations(getIt<JobRepository>()),
    );

    getIt.registerLazySingleton<RespondToArtisanInvitation>(
      () => RespondToArtisanInvitation(getIt<JobRepository>()),
    );

    // BLoC - registered as factory (new instance each time)
    getIt.registerFactory<JobBloc>(
      () => JobBloc(
        getJobs: getIt<GetJobs>(),
        getApplications: getIt<GetApplications>(),
        applyToJob: getIt<ApplyToJob>(),
        acceptAgreement: getIt<AcceptAgreement>(),
        requestChange: getIt<RequestChange>(),
        getJobInvitations: getIt<GetJobInvitations>(),
        respondToJobInvitation: getIt<RespondToJobInvitation>(),
        getArtisanInvitations: getIt<GetArtisanInvitations>(),
        getRecentArtisanInvitations: getIt<GetRecentArtisanInvitations>(),
        respondToArtisanInvitation: getIt<RespondToArtisanInvitation>(),
      ),
    );

    _initialized = true;
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _initialized = false;
  }
}
