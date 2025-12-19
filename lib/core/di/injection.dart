import 'package:get_it/get_it.dart';
import 'package:artisans_circle/core/di/core_module.dart';
import 'package:artisans_circle/core/di/features/auth_module.dart';

/// Main dependency injection coordinator
///
/// This file orchestrates the initialization of all DI modules.
/// Core infrastructure is loaded immediately, while feature modules
/// can be loaded lazily for better performance.

final GetIt getIt = GetIt.instance;

/// Initialize all dependencies
///
/// Call this during app startup (before runApp) to register dependencies.
///
/// Set [useFake] to true to register in-memory fakes for development and widget tests.
/// Set [baseUrl] to override the default API base URL.
Future<void> setupDependencies({
  String? baseUrl,
  bool useFake = false,
}) async {
  // Phase 1: Initialize core infrastructure (always needed)
  await CoreModule.init(getIt, baseUrl: baseUrl, useFake: useFake);

  // Phase 2: Initialize auth module (needed early for navigation)
  await AuthModule.init(getIt, useFake: useFake);

  // Note: Other feature modules (Jobs, Account, Catalog, etc.) are still
  // registered inline in the old di.dart file. They should be migrated to
  // modular structure progressively.
  //
  // Future modules to create:
  // - JobsModule (for lazy loading when jobs feature is accessed)
  // - AccountModule (for lazy loading when account feature is accessed)
  // - CatalogModule (for lazy loading when catalog feature is accessed)
  // - InvoicesModule (for lazy loading when invoices feature is accessed)
  // - MessagesModule (for lazy loading when messages feature is accessed)
  // - CollaborationModule (for lazy loading when collaboration feature is accessed)
}

/// Reset all DI modules (for testing)
void resetDependencies() {
  getIt.reset();
  CoreModule.reset();
  AuthModule.reset();
}
