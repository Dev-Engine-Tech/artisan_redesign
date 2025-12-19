import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_remote_data_source_fake.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_categories_remote_data_source.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_requests_remote_data_source.dart';
import 'package:artisans_circle/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:artisans_circle/features/catalog/data/repositories/catalog_requests_repository_impl.dart';
import 'package:artisans_circle/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:artisans_circle/features/catalog/domain/repositories/catalog_requests_repository.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_my_catalog_items.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_by_user.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_details.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/create_catalog.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/update_catalog.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/delete_catalog.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_requests.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/get_catalog_request_details.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/approve_catalog_request.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/decline_catalog_request.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';

/// Catalog feature module
///
/// Registers catalog-related dependencies including catalog items management
/// and catalog requests (orders) handling.
class CatalogModule {
  static bool _initialized = false;

  /// Initialize catalog dependencies
  static Future<void> init(GetIt getIt, {bool useFake = false}) async {
    if (_initialized) return;

    // Data sources - Catalog Items
    if (useFake) {
      getIt.registerLazySingleton<CatalogRemoteDataSource>(
        () => CatalogRemoteDataSourceFake(),
      );
    } else {
      getIt.registerLazySingleton<CatalogRemoteDataSource>(
        () => CatalogRemoteDataSourceImpl(getIt<Dio>()),
      );
    }

    // Data sources - Catalog Categories
    getIt.registerLazySingleton<CatalogCategoriesRemoteDataSource>(
      () => CatalogCategoriesRemoteDataSourceImpl(getIt<Dio>()),
    );

    // Data sources - Catalog Requests (Orders)
    getIt.registerLazySingleton<CatalogRequestsRemoteDataSource>(
      () => CatalogRequestsRemoteDataSourceImpl(getIt<Dio>()),
    );

    // Repositories
    getIt.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(getIt<CatalogRemoteDataSource>()),
    );

    getIt.registerLazySingleton<CatalogRequestsRepository>(
      () => CatalogRequestsRepositoryImpl(
          getIt<CatalogRequestsRemoteDataSource>()),
    );

    // Use cases - Catalog Items
    getIt.registerLazySingleton<GetMyCatalogItems>(
      () => GetMyCatalogItems(getIt<CatalogRepository>()),
    );

    getIt.registerLazySingleton<GetCatalogByUser>(
      () => GetCatalogByUser(getIt<CatalogRepository>()),
    );

    getIt.registerLazySingleton<GetCatalogDetails>(
      () => GetCatalogDetails(getIt<CatalogRepository>()),
    );

    getIt.registerLazySingleton<CreateCatalog>(
      () => CreateCatalog(getIt<CatalogRepository>()),
    );

    getIt.registerLazySingleton<UpdateCatalog>(
      () => UpdateCatalog(getIt<CatalogRepository>()),
    );

    getIt.registerLazySingleton<DeleteCatalog>(
      () => DeleteCatalog(getIt<CatalogRepository>()),
    );

    // Use cases - Catalog Requests (Orders)
    getIt.registerLazySingleton<GetCatalogRequests>(
      () => GetCatalogRequests(getIt<CatalogRequestsRepository>()),
    );

    getIt.registerLazySingleton<GetCatalogRequestDetails>(
      () => GetCatalogRequestDetails(getIt<CatalogRequestsRepository>()),
    );

    getIt.registerLazySingleton<ApproveCatalogRequest>(
      () => ApproveCatalogRequest(getIt<CatalogRequestsRepository>()),
    );

    getIt.registerLazySingleton<DeclineCatalogRequest>(
      () => DeclineCatalogRequest(getIt<CatalogRequestsRepository>()),
    );

    // BLoCs - registered as factories (new instance each time)
    getIt.registerFactory<CatalogBloc>(
      () => CatalogBloc(
        getMyCatalogItems: getIt<GetMyCatalogItems>(),
        getCatalogByUser: getIt<GetCatalogByUser>(),
        getCatalogDetails: getIt<GetCatalogDetails>(),
      ),
    );

    getIt.registerFactory<CatalogRequestsBloc>(
      () => CatalogRequestsBloc(
        getRequests: getIt<GetCatalogRequests>(),
        getDetails: getIt<GetCatalogRequestDetails>(),
        approve: getIt<ApproveCatalogRequest>(),
        decline: getIt<DeclineCatalogRequest>(),
      ),
    );

    _initialized = true;
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _initialized = false;
  }
}
