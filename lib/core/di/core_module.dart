import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/core/storage/secure_storage.dart';
import 'package:artisans_circle/core/storage/secure_storage_fake.dart';
import 'package:artisans_circle/core/services/theme_service.dart';
import 'package:artisans_circle/core/analytics/firebase_analytics_service.dart';
import 'package:artisans_circle/core/services/subscription_service.dart';
import 'package:artisans_circle/core/utils/subscription_guard.dart';
import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/core/network/http_service.dart';
import 'package:artisans_circle/core/network/ssl_overrides_stub.dart'
    if (dart.library.io) 'package:artisans_circle/core/network/ssl_overrides_io.dart'
    as ssl;

/// Core infrastructure module
///
/// Registers essential services that are always needed at app startup:
/// - SharedPreferences
/// - SecureStorage
/// - Dio (HTTP client)
/// - HttpService
/// - ThemeService
/// - AnalyticsService
/// - SubscriptionService
class CoreModule {
  static bool _initialized = false;

  static const bool kAllowInsecure =
      bool.fromEnvironment('ALLOW_INSECURE', defaultValue: false);
  static const bool kLogHttp = bool.fromEnvironment('LOG_HTTP', defaultValue: false);

  /// Initialize core infrastructure dependencies
  ///
  /// This should be called during app startup before runApp()
  static Future<void> init(
    GetIt getIt, {
    String? baseUrl,
    bool useFake = false,
  }) async {
    if (_initialized) return;

    // External / 3rd party
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

    // Register secure storage for sensitive data
    if (useFake) {
      getIt.registerLazySingleton<SecureStorage>(() => SecureStorageFake());
    } else {
      getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
    }

    // Configure Dio HTTP client
    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // Attach Authorization header from SecureStorage for all requests
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

      // Optionally relax certificate checks for a specific host in dev
      if (kAllowInsecure) {
        try {
          final host = Uri.parse(baseUrl ?? ApiEndpoints.baseUrl).host;
          ssl.configureBadCertificate(dio, host: host);
        } catch (e) {
          // Ignore: any issues configuring insecure mode should not crash app
        }
      }

      return dio;
    });

    // Register optimized HTTP service
    getIt.registerLazySingleton<HttpService>(
      () => OptimizedHttpService(
        dio: getIt<Dio>(),
        cacheDuration: const Duration(minutes: 5),
        maxCacheSize: 100,
      ),
    );

    // Register Theme Service
    getIt.registerLazySingleton<ThemeService>(
      () => ThemeService(getIt<SharedPreferences>()),
    );

    // Register Analytics Service
    getIt.registerLazySingleton<AnalyticsService>(
      () => FirebaseAnalyticsService(),
    );

    // Subscription service
    getIt.registerLazySingleton<SubscriptionService>(
      () => SubscriptionService(getIt<Dio>()),
    );

    // Subscription guard
    getIt.registerLazySingleton<SubscriptionGuard>(
      () => SubscriptionGuard(getIt<SubscriptionService>(), getIt<Dio>()),
    );

    _initialized = true;
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _initialized = false;
  }
}
