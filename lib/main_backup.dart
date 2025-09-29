import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme.dart';
import 'core/api/endpoints.dart';
import 'core/di.dart';
import 'core/storage/secure_storage.dart';
// import 'core/analytics/firebase_analytics_service.dart';
// import 'core/performance/performance_monitor.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
// import 'firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart' as fba;

// Use real backend data to test API integration
const bool kUseFake = bool.fromEnvironment('USE_FAKE', defaultValue: false);
const String kBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: ApiEndpoints.baseUrl);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase so chat can use Firestore when enabled.
  // try {
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // } catch (_) {
  //   // If initialization fails (e.g., web/macos not configured), continue for in-memory fallback
  // }
  await setupDependencies(useFake: kUseFake, baseUrl: kBaseUrl);

  // Initialize Firebase Analytics
  // try {
  //   final analyticsService = getIt<AnalyticsService>();
  //   await (analyticsService as FirebaseAnalyticsService).initialize();
  //
  //   // Initialize Performance Monitor
  //   final performanceMonitor = getIt<PerformanceMonitor>();
  //   (performanceMonitor as DefaultPerformanceMonitor).enable();
  // } catch (e) {
  //   if (kDebugMode) {
  //     print('Analytics initialization error: $e');
  //   }
  // }

  // Attempt Firebase Auth sign-in using saved custom token from backend (if any)
  // try {
  //   final secureStorage = getIt<SecureStorage>();
  //   final token = await secureStorage.getFirebaseToken();
  //   if (token != null && (fba.FirebaseAuth.instance.currentUser == null)) {
  //     await fba.FirebaseAuth.instance.signInWithCustomToken(token);
  //   }
  // } catch (_) {}

  // Provide AuthBloc at the top level so SplashPage (and subsequent pages)
  // can access authentication state. We create the bloc instance via getIt.
  final authBloc = getIt<AuthBloc>();
  runApp(BlocProvider.value(
    value: authBloc,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artisans Circle',
      theme: AppThemes.lightTheme(),
      darkTheme: AppThemes.darkTheme(),
      themeMode: ThemeMode.system,
      // navigatorObservers: [
      //   FirebaseAnalyticsRouteObserver(getIt<AnalyticsService>()),
      // ],
      home: const SplashPage(),
    );
  }
}
