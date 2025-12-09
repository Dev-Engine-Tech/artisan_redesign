import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/core/storage/secure_storage.dart';
import 'package:artisans_circle/core/storage/secure_storage_fake.dart'
    show SecureStorageFake;

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

import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source_fake.dart';
import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:artisans_circle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:artisans_circle/features/auth/domain/repositories/auth_repository.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_in.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_up.dart';
import 'package:artisans_circle/features/auth/domain/usecases/is_signed_in.dart';
import 'package:artisans_circle/features/auth/domain/usecases/get_current_user.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_out.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'api/endpoints.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/signup_cubit.dart';
import 'package:artisans_circle/core/network/ssl_overrides_stub.dart'
    if (dart.library.io) 'package:artisans_circle/core/network/ssl_overrides_io.dart'
    as ssl;
import 'package:artisans_circle/core/services/banner_service.dart';
import 'package:artisans_circle/core/services/login_state_service.dart';
import 'package:artisans_circle/core/services/theme_service.dart';
import 'package:artisans_circle/core/location/location_remote_data_source.dart';
import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';
import 'package:artisans_circle/core/services/push_registration_service.dart';
import 'package:artisans_circle/core/services/subscription_service.dart';
import 'package:artisans_circle/core/utils/subscription_guard.dart';
// Catalog feature
import 'package:artisans_circle/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_remote_data_source_fake.dart';
import 'package:artisans_circle/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:artisans_circle/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_by_user.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_details.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/create_catalog.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/update_catalog.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/delete_catalog.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_requests_remote_data_source.dart';
import 'package:artisans_circle/features/catalog/data/repositories/catalog_requests_repository_impl.dart';
import 'package:artisans_circle/features/catalog/domain/repositories/catalog_requests_repository.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_requests.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_request_details.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/approve_catalog_request.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/decline_catalog_request.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_categories_remote_data_source.dart';
// Avoid importing Flutter widget types in core DI; pages import DI instead when needed.
// Account feature
import 'package:artisans_circle/features/account/data/datasources/account_remote_data_source.dart';
import 'package:artisans_circle/features/account/data/datasources/business_settings_remote_data_source.dart';
import 'package:artisans_circle/features/account/data/repositories/account_repository_impl.dart';
import 'package:artisans_circle/features/account/data/repositories/business_settings_repository_impl.dart';
import 'package:artisans_circle/features/account/domain/repositories/account_repository.dart';
import 'package:artisans_circle/features/account/domain/repositories/business_settings_repository.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_user_profile.dart';
import 'package:artisans_circle/features/account/domain/usecases/update_user_profile.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_earnings.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_transactions.dart';
import 'package:artisans_circle/features/account/domain/usecases/request_withdrawal.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_bank_accounts.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_bank_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_bank_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/change_password.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/upload_profile_image.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_skill.dart';
import 'package:artisans_circle/features/account/domain/usecases/remove_skill.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_work_experience.dart';
import 'package:artisans_circle/features/account/domain/usecases/update_work_experience.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_work_experience.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_education.dart';
import 'package:artisans_circle/features/account/domain/usecases/update_education.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_education.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_bank_list.dart';
import 'package:artisans_circle/features/account/domain/usecases/verify_bank_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/set_withdrawal_pin.dart';
import 'package:artisans_circle/features/account/domain/usecases/verify_withdrawal_pin.dart';
// Messages feature
import 'package:artisans_circle/features/messages/data/datasources/messages_in_memory_data_source.dart';
import 'package:artisans_circle/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:artisans_circle/features/messages/data/repositories/messages_repository_firebase.dart';
import 'package:artisans_circle/features/messages/domain/repositories/messages_repository.dart';
import 'package:artisans_circle/features/messages/domain/usecases/send_text_message.dart';
import 'package:artisans_circle/features/messages/domain/usecases/send_image_message.dart';
import 'package:artisans_circle/features/messages/domain/usecases/send_audio_message.dart';
import 'package:artisans_circle/features/messages/domain/usecases/delete_message.dart';
import 'package:artisans_circle/features/messages/domain/usecases/watch_messages.dart';
import 'package:artisans_circle/features/messages/domain/usecases/watch_conversations.dart';
import 'package:artisans_circle/features/messages/domain/usecases/mark_messages_seen.dart';
import 'package:artisans_circle/features/messages/domain/usecases/set_typing_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart' as fba;
// Notifications feature
import 'package:artisans_circle/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:artisans_circle/features/notifications/data/datasources/notification_remote_data_source_impl.dart';
import 'package:artisans_circle/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:artisans_circle/features/notifications/domain/repositories/notification_repository.dart';
// Invoice feature
import 'package:artisans_circle/features/invoices/data/datasources/invoice_remote_data_source.dart';
import 'package:artisans_circle/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:artisans_circle/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:artisans_circle/features/invoices/domain/usecases/get_invoices.dart'
    as invoice_usecases;
import 'package:artisans_circle/features/invoices/domain/usecases/create_invoice.dart'
    as invoice_usecases;
import 'package:artisans_circle/features/invoices/domain/usecases/send_invoice.dart'
    as invoice_usecases;
import 'package:artisans_circle/features/invoices/presentation/bloc/invoice_bloc.dart';
import 'package:artisans_circle/core/network/http_service.dart';
// import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';
// import 'package:artisans_circle/core/performance/performance_monitor.dart';
// Customers
import 'package:artisans_circle/features/customers/data/datasources/customer_remote_data_source.dart';
import 'package:artisans_circle/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:artisans_circle/features/customers/domain/repositories/customer_repository.dart';
import 'package:artisans_circle/features/customers/domain/usecases/get_customers.dart';
// Collaboration feature
import 'package:artisans_circle/features/collaboration/data/datasources/collaboration_remote_data_source.dart';
import 'package:artisans_circle/features/collaboration/data/repositories/collaboration_repository_impl.dart';
import 'package:artisans_circle/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:artisans_circle/features/collaboration/domain/usecases/invite_collaborator.dart';
import 'package:artisans_circle/features/collaboration/domain/usecases/invite_external_collaborator.dart';
import 'package:artisans_circle/features/collaboration/domain/usecases/get_my_collaborations.dart';
import 'package:artisans_circle/features/collaboration/domain/usecases/respond_to_collaboration.dart';
import 'package:artisans_circle/features/collaboration/domain/usecases/get_job_collaborators.dart';
import 'package:artisans_circle/features/collaboration/domain/usecases/search_artisans.dart';
import 'package:artisans_circle/features/collaboration/presentation/bloc/collaboration_bloc.dart';

final GetIt getIt = GetIt.instance;

// Allow opting into insecure TLS (e.g., self-signed, wrong host) for dev only.
// Never enable this in production.
const bool kAllowInsecure =
    bool.fromEnvironment('ALLOW_INSECURE', defaultValue: false);
const bool kLogHttp = bool.fromEnvironment('LOG_HTTP', defaultValue: false);
const bool kUseFirebaseMessages =
    bool.fromEnvironment('USE_FIREBASE_MESSAGES', defaultValue: true);

/// Call this during app startup (before runApp) to register dependencies.
///
/// Set [useFake] to true to register in-memory fakes for development and widget tests.
Future<void> setupDependencies({String? baseUrl, bool useFake = false}) async {
  // External / 3rd party
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Register secure storage for sensitive data
  if (useFake) {
    getIt.registerLazySingleton<SecureStorage>(() => SecureStorageFake());
  } else {
    getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
  }

  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    // Attach Authorization header from SecureStorage for all requests.
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final secureStorage = getIt<SecureStorage>();
          final token = await secureStorage.getAccessToken();
          options.headers.addAll({
            'Accept': 'application/json',
            'Content-Type':
                options.headers['Content-Type'] ?? 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          });
        } catch (_) {}
        handler.next(options);
      },
    ));
    if (kLogHttp) {
      dio.interceptors.add(PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: false,
        compact: true,
      ));
    }
    // Optionally add a logging interceptor here for debugging
    // Optionally relax certificate checks for a specific host in dev.
    if (kAllowInsecure) {
      try {
        final host = Uri.parse(baseUrl ?? ApiEndpoints.baseUrl).host;
        ssl.configureBadCertificate(dio, host: host);
      } catch (e) {
        // ignore: any issues configuring insecure mode should not crash app
      }
    } else {
      // certificate bypass disabled
    }
    return dio;
  });

  // Register optimized HTTP service using the same configured Dio instance
  // so it inherits auth headers, logging and SSL settings.
  getIt.registerLazySingleton<HttpService>(
    () => OptimizedHttpService(
      dio: getIt<Dio>(),
      cacheDuration: const Duration(minutes: 5),
      maxCacheSize: 100,
    ),
  );

  // Register Banner Service
  getIt.registerLazySingleton<BannerService>(
    () => BannerService(),
  );

  // Register Theme Service
  getIt.registerLazySingleton<ThemeService>(
    () => ThemeService(getIt<SharedPreferences>()),
  );

  // Subscription service
  getIt.registerLazySingleton<SubscriptionService>(
    () => SubscriptionService(getIt<Dio>()),
  );

  // Subscription guard for enforcing plan limits
  getIt.registerLazySingleton<SubscriptionGuard>(
    () => SubscriptionGuard(getIt<SubscriptionService>(), getIt<Dio>()),
  );

  // Register Login State Service for tracking fresh logins
  getIt.registerLazySingleton<LoginStateService>(
    () => LoginStateService.instance,
  );

  // Location (States/LGAs)
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(getIt<Dio>()),
  );

  // Register Firebase Analytics service
  getIt.registerLazySingleton<AnalyticsService>(
    () => FirebaseAnalyticsService(),
  );

  // Register Performance Monitor with Analytics integration
  // getIt.registerLazySingleton<PerformanceMonitor>(() {
  //   final monitor = DefaultPerformanceMonitor();
  //   monitor.setAnalyticsService(getIt<AnalyticsService>());
  //   return monitor;
  // });

  // Core / infrastructure - feature registrations
  // Jobs feature
  if (useFake) {
    getIt.registerLazySingleton<JobRemoteDataSource>(
      () => JobRemoteDataSourceFake(),
    );
  } else {
    getIt.registerLazySingleton<JobRemoteDataSource>(
      () => JobRemoteDataSourceImpl(getIt<Dio>()),
    );
  }

  getIt.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(remoteDataSource: getIt<JobRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetJobs>(
    () => GetJobs(getIt<JobRepository>()),
  );

  getIt.registerLazySingleton<GetApplications>(
    () => GetApplications(getIt<JobRepository>()),
  );

  // Register additional usecases
  getIt.registerLazySingleton<ApplyToJob>(
    () => ApplyToJob(getIt<JobRepository>()),
  );

  getIt.registerLazySingleton<AcceptAgreement>(
    () => AcceptAgreement(getIt<JobRepository>()),
  );

  // Request change usecase
  getIt.registerLazySingleton<RequestChange>(
    () => RequestChange(getIt<JobRepository>()),
  );

  // Job invitations usecases (legacy)
  getIt.registerLazySingleton<GetJobInvitations>(
    () => GetJobInvitations(getIt<JobRepository>()),
  );

  getIt.registerLazySingleton<RespondToJobInvitation>(
    () => RespondToJobInvitation(getIt<JobRepository>()),
  );

  // Artisan invitations usecases (v1)
  getIt.registerLazySingleton<GetArtisanInvitations>(
    () => GetArtisanInvitations(getIt<JobRepository>()),
  );

  getIt.registerLazySingleton<GetRecentArtisanInvitations>(
    () => GetRecentArtisanInvitations(getIt<JobRepository>()),
  );

  getIt.registerLazySingleton<RespondToArtisanInvitation>(
    () => RespondToArtisanInvitation(getIt<JobRepository>()),
  );

  // Auth feature (fake by default for development & tests)
  if (useFake) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceFake(),
    );
  } else {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
          getIt<Dio>(), getIt<SharedPreferences>(), getIt<SecureStorage>()),
    );
  }

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<SignIn>(() => SignIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignUp>(() => SignUp(getIt<AuthRepository>()));
  getIt.registerLazySingleton<IsSignedIn>(
      () => IsSignedIn(getIt<AuthRepository>()));
  getIt.registerLazySingleton<GetCurrentUser>(
      () => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignOut>(() => SignOut(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignInWithGoogle>(
      () => SignInWithGoogle(getIt<AuthRepository>()));
  getIt.registerLazySingleton<SignInWithApple>(
      () => SignInWithApple(getIt<AuthRepository>()));

  // Blocs / Cubits are registered as factories so they can be created with fresh state.
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      signIn: getIt<SignIn>(),
      signUp: getIt<SignUp>(),
      isSignedIn: getIt<IsSignedIn>(),
      getCurrentUser: getIt<GetCurrentUser>(),
      signOut: getIt<SignOut>(),
      signInWithGoogle: getIt<SignInWithGoogle>(),
      signInWithApple: getIt<SignInWithApple>(),
    ),
  );

  // SignUp Cubit (stepper wizard)
  if (useFake) {
    // For widget tests and development we register the cubit as a singleton so tests
    // that call `getIt<SignUpCubit>()` get the same instance used by the widget.
    getIt.registerLazySingleton<SignUpCubit>(
      () => SignUpCubit(signUpUsecase: getIt<SignUp>()),
    );
  } else {
    getIt.registerFactory<SignUpCubit>(
      () => SignUpCubit(signUpUsecase: getIt<SignUp>()),
    );
  }

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

  // Catalog feature
  if (useFake) {
    getIt.registerLazySingleton<CatalogRemoteDataSource>(
        () => CatalogRemoteDataSourceFake());
  } else {
    getIt.registerLazySingleton<CatalogRemoteDataSource>(
        () => CatalogRemoteDataSourceImpl(getIt<Dio>()));
  }
  getIt.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(getIt<CatalogRemoteDataSource>()));
  getIt.registerLazySingleton<GetMyCatalogItems>(
      () => GetMyCatalogItems(getIt<CatalogRepository>()));
  getIt.registerLazySingleton<GetCatalogByUser>(
      () => GetCatalogByUser(getIt<CatalogRepository>()));
  getIt.registerLazySingleton<GetCatalogDetails>(
      () => GetCatalogDetails(getIt<CatalogRepository>()));
  getIt.registerLazySingleton<CreateCatalog>(
      () => CreateCatalog(getIt<CatalogRepository>()));
  getIt.registerLazySingleton<UpdateCatalog>(
      () => UpdateCatalog(getIt<CatalogRepository>()));
  getIt.registerLazySingleton<DeleteCatalog>(
      () => DeleteCatalog(getIt<CatalogRepository>()));
  getIt.registerFactory<CatalogBloc>(() => CatalogBloc(
        getMyCatalogItems: getIt<GetMyCatalogItems>(),
        getCatalogByUser: getIt<GetCatalogByUser>(),
        getCatalogDetails: getIt<GetCatalogDetails>(),
      ));
  getIt.registerLazySingleton<CatalogCategoriesRemoteDataSource>(
      () => CatalogCategoriesRemoteDataSourceImpl(getIt<Dio>()));

  // Catalog Requests
  getIt.registerLazySingleton<CatalogRequestsRemoteDataSource>(
      () => CatalogRequestsRemoteDataSourceImpl(getIt<Dio>()));
  getIt.registerLazySingleton<CatalogRequestsRepository>(() =>
      CatalogRequestsRepositoryImpl(getIt<CatalogRequestsRemoteDataSource>()));
  getIt.registerLazySingleton<GetCatalogRequests>(
      () => GetCatalogRequests(getIt<CatalogRequestsRepository>()));
  getIt.registerLazySingleton<GetCatalogRequestDetails>(
      () => GetCatalogRequestDetails(getIt<CatalogRequestsRepository>()));
  getIt.registerLazySingleton<ApproveCatalogRequest>(
      () => ApproveCatalogRequest(getIt<CatalogRequestsRepository>()));
  getIt.registerLazySingleton<DeclineCatalogRequest>(
      () => DeclineCatalogRequest(getIt<CatalogRequestsRepository>()));
  getIt.registerFactory<CatalogRequestsBloc>(() => CatalogRequestsBloc(
        getRequests: getIt<GetCatalogRequests>(),
        getDetails: getIt<GetCatalogRequestDetails>(),
        approve: getIt<ApproveCatalogRequest>(),
        decline: getIt<DeclineCatalogRequest>(),
      ));

  // No page factory registered to keep DI free of Flutter widget types.

  // Account feature
  getIt.registerLazySingleton<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(getIt<Dio>()));
  getIt.registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(getIt<AccountRemoteDataSource>()));
  getIt.registerLazySingleton<GetUserProfile>(
      () => GetUserProfile(getIt<AccountRepository>()));
  getIt.registerLazySingleton<UpdateUserProfile>(
      () => UpdateUserProfile(getIt<AccountRepository>()));
  getIt.registerLazySingleton<GetEarnings>(
      () => GetEarnings(getIt<AccountRepository>()));
  getIt.registerLazySingleton<GetTransactions>(
      () => GetTransactions(getIt<AccountRepository>()));
  getIt.registerLazySingleton<RequestWithdrawal>(
      () => RequestWithdrawal(getIt<AccountRepository>()));
  getIt.registerLazySingleton<GetBankAccounts>(
      () => GetBankAccounts(getIt<AccountRepository>()));
  getIt.registerLazySingleton<AddBankAccount>(
      () => AddBankAccount(getIt<AccountRepository>()));
  getIt.registerLazySingleton<DeleteBankAccount>(
      () => DeleteBankAccount(getIt<AccountRepository>()));
  getIt.registerLazySingleton<GetBankList>(
      () => GetBankList(getIt<AccountRepository>()));
  getIt.registerLazySingleton<VerifyBankAccount>(
      () => VerifyBankAccount(getIt<AccountRepository>()));
  getIt.registerLazySingleton<SetWithdrawalPin>(
      () => SetWithdrawalPin(getIt<AccountRepository>()));
  getIt.registerLazySingleton<VerifyWithdrawalPin>(
      () => VerifyWithdrawalPin(getIt<AccountRepository>()));
  getIt.registerLazySingleton<ChangePassword>(
      () => ChangePassword(getIt<AccountRepository>()));
  getIt.registerLazySingleton<DeleteAccount>(
      () => DeleteAccount(getIt<AccountRepository>()));
  getIt.registerLazySingleton<AddSkill>(
      () => AddSkill(getIt<AccountRepository>()));
  getIt.registerLazySingleton<RemoveSkill>(
      () => RemoveSkill(getIt<AccountRepository>()));
  getIt.registerLazySingleton<AddWorkExperience>(
      () => AddWorkExperience(getIt<AccountRepository>()));
  getIt.registerLazySingleton<UpdateWorkExperience>(
      () => UpdateWorkExperience(getIt<AccountRepository>()));
  getIt.registerLazySingleton<DeleteWorkExperience>(
      () => DeleteWorkExperience(getIt<AccountRepository>()));
  getIt.registerLazySingleton<AddEducation>(
      () => AddEducation(getIt<AccountRepository>()));
  getIt.registerLazySingleton<UpdateEducation>(
      () => UpdateEducation(getIt<AccountRepository>()));
  getIt.registerLazySingleton<DeleteEducation>(
      () => DeleteEducation(getIt<AccountRepository>()));
  getIt.registerLazySingleton<UploadProfileImage>(
      () => UploadProfileImage(getIt<AccountRepository>()));
  getIt.registerFactory<AccountBloc>(() => AccountBloc(
        getUserProfile: getIt<GetUserProfile>(),
        updateUserProfile: getIt<UpdateUserProfile>(),
        getEarnings: getIt<GetEarnings>(),
        getTransactions: getIt<GetTransactions>(),
        requestWithdrawal: getIt<RequestWithdrawal>(),
        getBankAccounts: getIt<GetBankAccounts>(),
        addBankAccount: getIt<AddBankAccount>(),
        deleteBankAccount: getIt<DeleteBankAccount>(),
        getBankList: getIt<GetBankList>(),
        verifyBankAccount: getIt<VerifyBankAccount>(),
        setWithdrawalPin: getIt<SetWithdrawalPin>(),
        verifyWithdrawalPin: getIt<VerifyWithdrawalPin>(),
        changePassword: getIt<ChangePassword>(),
        deleteAccount: getIt<DeleteAccount>(),
        addSkill: getIt<AddSkill>(),
        removeSkill: getIt<RemoveSkill>(),
        addWork: getIt<AddWorkExperience>(),
        updateWork: getIt<UpdateWorkExperience>(),
        deleteWork: getIt<DeleteWorkExperience>(),
        addEducation: getIt<AddEducation>(),
        updateEducation: getIt<UpdateEducation>(),
        deleteEducation: getIt<DeleteEducation>(),
        uploadProfileImage: getIt<UploadProfileImage>(),
      ));

  // Business Settings feature
  getIt.registerLazySingleton<BusinessSettingsRemoteDataSource>(
      () => BusinessSettingsRemoteDataSourceImpl(getIt<Dio>()));
  getIt.registerLazySingleton<BusinessSettingsRepository>(() =>
      BusinessSettingsRepositoryImpl(
          getIt<BusinessSettingsRemoteDataSource>()));

  // Messages feature: prefer Firebase if available and permitted
  final bool hasFirebase = fb.Firebase.apps.isNotEmpty;
  final bool hasFirebaseAuthUser =
      hasFirebase && (fba.FirebaseAuth.instance.currentUser != null);
  final String? customToken = await getIt<SecureStorage>().getFirebaseToken();
  final bool hasCustomToken = customToken != null;
  if (kUseFirebaseMessages &&
      hasFirebase &&
      (hasFirebaseAuthUser || hasCustomToken)) {
    getIt.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance);
    getIt.registerLazySingleton<MessagesRepository>(
        () => MessagesRepositoryFirebase(getIt<FirebaseFirestore>()));
  } else {
    // In-memory fallback
    getIt.registerLazySingleton<InMemoryMessagesStore>(
        () => InMemoryMessagesStore());
    getIt.registerLazySingleton<MessagesRepository>(
        () => MessagesRepositoryImpl(getIt<InMemoryMessagesStore>()));
  }

  // Messages use cases
  getIt.registerLazySingleton<SendTextMessage>(
    () => SendTextMessage(getIt<MessagesRepository>()),
  );
  getIt.registerLazySingleton<SendImageMessage>(
    () => SendImageMessage(getIt<MessagesRepository>()),
  );
  getIt.registerLazySingleton<SendAudioMessage>(
    () => SendAudioMessage(getIt<MessagesRepository>()),
  );
  getIt.registerLazySingleton<DeleteMessage>(
    () => DeleteMessage(getIt<MessagesRepository>()),
  );
  getIt.registerLazySingleton<WatchMessages>(
    () => WatchMessages(getIt<MessagesRepository>()),
  );
  getIt.registerLazySingleton<WatchConversations>(
    () => WatchConversations(getIt<MessagesRepository>()),
  );
  getIt.registerLazySingleton<MarkMessagesSeen>(
    () => MarkMessagesSeen(getIt<MessagesRepository>()),
  );
  getIt.registerLazySingleton<SetTypingStatus>(
    () => SetTypingStatus(getIt<MessagesRepository>()),
  );

  // Notifications feature
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
        remoteDataSource: getIt<NotificationRemoteDataSource>()),
  );

  // Push registration service (FCM token → backend)
  getIt.registerLazySingleton<PushRegistrationService>(
      () => PushRegistrationService(
            remote: getIt<NotificationRemoteDataSource>(),
            secureStorage: getIt<SecureStorage>(),
          ));

  // Invoice feature - Real API implementation
  getIt.registerLazySingleton<InvoiceRemoteDataSource>(
    () => InvoiceRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(getIt<InvoiceRemoteDataSource>()),
  );
  getIt.registerLazySingleton<invoice_usecases.GetInvoices>(
    () => invoice_usecases.GetInvoices(getIt<InvoiceRepository>()),
  );
  getIt.registerLazySingleton<invoice_usecases.CreateInvoice>(
    () => invoice_usecases.CreateInvoice(getIt<InvoiceRepository>()),
  );
  getIt.registerLazySingleton<invoice_usecases.SendInvoice>(
    () => invoice_usecases.SendInvoice(getIt<InvoiceRepository>()),
  );
  getIt.registerFactory<InvoiceBloc>(
    () => InvoiceBloc(
      getInvoices: getIt<invoice_usecases.GetInvoices>(),
      createInvoice: getIt<invoice_usecases.CreateInvoice>(),
      sendInvoice: getIt<invoice_usecases.SendInvoice>(),
      repository: getIt<InvoiceRepository>(),
    ),
  );

  // Customers feature - Real API implementation
  getIt.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<CustomerRemoteDataSource>()),
  );
  getIt.registerLazySingleton<GetCustomers>(
    () => GetCustomers(getIt<CustomerRepository>()),
  );

  // Collaboration feature - Real API implementation
  getIt.registerLazySingleton<CollaborationRemoteDataSource>(
    () => CollaborationRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CollaborationRepository>(
    () => CollaborationRepositoryImpl(
      remoteDataSource: getIt<CollaborationRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<InviteCollaborator>(
    () => InviteCollaborator(getIt<CollaborationRepository>()),
  );
  getIt.registerLazySingleton<InviteExternalCollaborator>(
    () => InviteExternalCollaborator(getIt<CollaborationRepository>()),
  );
  getIt.registerLazySingleton<GetMyCollaborations>(
    () => GetMyCollaborations(getIt<CollaborationRepository>()),
  );
  getIt.registerLazySingleton<RespondToCollaboration>(
    () => RespondToCollaboration(getIt<CollaborationRepository>()),
  );
  getIt.registerLazySingleton<GetJobCollaborators>(
    () => GetJobCollaborators(getIt<CollaborationRepository>()),
  );
  getIt.registerLazySingleton<SearchArtisans>(
    () => SearchArtisans(getIt<CollaborationRepository>()),
  );
  getIt.registerFactory<CollaborationBloc>(
    () => CollaborationBloc(
      getMyCollaborations: getIt<GetMyCollaborations>(),
      inviteCollaborator: getIt<InviteCollaborator>(),
      inviteExternalCollaborator: getIt<InviteExternalCollaborator>(),
      respondToCollaboration: getIt<RespondToCollaboration>(),
      getJobCollaborators: getIt<GetJobCollaborators>(),
    ),
  );
}
