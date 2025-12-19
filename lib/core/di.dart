import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:artisans_circle/core/storage/secure_storage.dart';
// ✅ Modular DI - Core infrastructure and feature modules
import 'package:artisans_circle/core/di/core_module.dart';
import 'package:artisans_circle/core/di/features/auth_module.dart';
import 'package:artisans_circle/core/di/features/jobs_module.dart';
import 'package:artisans_circle/core/di/features/account_module.dart';
import 'package:artisans_circle/core/di/features/catalog_module.dart';

import 'package:artisans_circle/core/location/location_remote_data_source.dart';
import 'package:artisans_circle/core/services/push_registration_service.dart';
// ✅ Jobs, Account, and Catalog features now handled by modules
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
// HttpService is now registered by CoreModule
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
  // ✅ Phase 1: Initialize core infrastructure using CoreModule
  // This replaces the inline registrations for Dio, SharedPreferences, SecureStorage,
  // HttpService, ThemeService, SubscriptionService, SubscriptionGuard, and Analytics
  await CoreModule.init(getIt, baseUrl: baseUrl, useFake: useFake);

  // Location (States/LGAs)
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(getIt<Dio>()),
  );

  // ✅ AnalyticsService is now registered by CoreModule
  // ✅ PerformanceMonitor setup is handled by CoreModule

  // ✅ Phase 2: Initialize auth feature using AuthModule
  await AuthModule.init(getIt, useFake: useFake);

  // ✅ Phase 3: Initialize jobs feature using JobsModule
  await JobsModule.init(getIt, useFake: useFake);

  // ✅ Phase 4: Initialize catalog feature using CatalogModule
  await CatalogModule.init(getIt, useFake: useFake);

  // ✅ Phase 5: Initialize account feature using AccountModule
  await AccountModule.init(getIt, useFake: useFake);

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
