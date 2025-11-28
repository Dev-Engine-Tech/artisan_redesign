import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_event.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';
import 'package:artisans_circle/core/utils/api_request_manager.dart';

/// Centralized data loading for homepage with performance optimizations
/// Features:
/// - Staggered loading to prevent overwhelming the server
/// - Priority-based loading (critical data first)
/// - Error handling and recovery
/// - Request cancellation support
class HomeDataLoader {
  final ApiRequestManager _requestManager = ApiRequestManager();
  bool _isDisposed = false;

  /// Load all homepage data with staggered timing
  Future<void> loadAllData(BuildContext context) async {
    if (!context.mounted) return;

    try {
      // Priority 1: Critical data (visible immediately) - Account balance
      await _loadAccountData(context);

      // Small delay before loading secondary data
      await Future.delayed(const Duration(milliseconds: 150));
      if (_isDisposed || !context.mounted) return;

      // Priority 2: Applications (commonly accessed)
      await _loadApplicationsData(context);

      // Small delay before loading tertiary data
      await Future.delayed(const Duration(milliseconds: 150));
      if (_isDisposed || !context.mounted) return;

      // Priority 3: Orders
      await _loadOrdersData(context);

      debugPrint('✅ Homepage data loading complete');
    } catch (e) {
      debugPrint('⚠️ Homepage data loading error: $e');
      // Errors are handled individually in each method
    }
  }

  /// Load account data (balance and recent transactions)
  Future<void> _loadAccountData(BuildContext context) async {
    if (_isDisposed || !context.mounted) return;

    try {
      final accountBloc = context.read<AccountBloc>();

      // Load earnings (balance) - most critical
      await _requestManager.execute(
        requestId: 'account_earnings',
        request: () async {
          accountBloc.add(AccountLoadEarnings());
          // Wait a bit for the bloc to process
          await Future.delayed(const Duration(milliseconds: 100));
        },
      );

      // Load profile for greeting/name usage
      if (_isDisposed || !context.mounted) return;
      await _requestManager.execute(
        requestId: 'account_profile',
        request: () async {
          accountBloc.add(AccountLoadProfile());
          await Future.delayed(const Duration(milliseconds: 100));
        },
      );

      // Load recent transactions - less critical
      if (_isDisposed || !context.mounted) return;
      await _requestManager.execute(
        requestId: 'account_transactions',
        request: () async {
          accountBloc.add(const AccountLoadTransactions(page: 1, limit: 10));
          await Future.delayed(const Duration(milliseconds: 100));
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to load account data: $e');
      // Continue with other data loads even if this fails
    }
  }

  /// Load applications data
  Future<void> _loadApplicationsData(BuildContext context) async {
    if (_isDisposed || !context.mounted) return;

    try {
      final jobBloc = context.read<JobBloc>();

      await _requestManager.execute(
        requestId: 'job_applications',
        request: () async {
          jobBloc.add(LoadApplications(page: 1, limit: 10));
          await Future.delayed(const Duration(milliseconds: 100));
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to load applications: $e');
    }
  }

  /// Load orders/catalog requests data
  Future<void> _loadOrdersData(BuildContext context) async {
    if (_isDisposed || !context.mounted) return;

    try {
      final ordersBloc = context.read<CatalogRequestsBloc>();

      await _requestManager.execute(
        requestId: 'catalog_requests',
        request: () async {
          ordersBloc.add(LoadCatalogRequests());
          await Future.delayed(const Duration(milliseconds: 100));
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to load orders: $e');
    }
  }

  /// Load jobs data (lazy loaded when user navigates to Jobs tab)
  Future<void> loadJobsData(BuildContext context) async {
    if (_isDisposed || !context.mounted) return;

    try {
      final jobBloc = context.read<JobBloc>();
      final state = jobBloc.state;

      // Only load if not already loaded
      if (state is! JobStateLoaded) {
        await _requestManager.execute(
          requestId: 'jobs_list',
          request: () async {
            jobBloc.add(LoadJobs(page: 1, limit: 10));
            await Future.delayed(const Duration(milliseconds: 100));
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to load jobs: $e');
    }
  }

  /// Refresh specific data section
  Future<void> refreshSection(
    BuildContext context,
    HomeDataSection section,
  ) async {
    if (_isDisposed || !context.mounted) return;

    switch (section) {
      case HomeDataSection.account:
        await _loadAccountData(context);
        break;
      case HomeDataSection.applications:
        await _loadApplicationsData(context);
        break;
      case HomeDataSection.orders:
        await _loadOrdersData(context);
        break;
      case HomeDataSection.jobs:
        await loadJobsData(context);
        break;
    }
  }

  /// Cancel all pending requests (call in dispose)
  void dispose() {
    _isDisposed = true;
    _requestManager.cancelAll();
    debugPrint('🧹 HomeDataLoader disposed');
  }

  /// Get loading statistics for monitoring
  Map<String, dynamic> getStats() {
    return _requestManager.getStats();
  }
}

/// Enum for different data sections
enum HomeDataSection {
  account,
  applications,
  orders,
  jobs,
}
