import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/subscription_service.dart';
import '../api/endpoints.dart';
import '../../features/account/presentation/pages/subscription_page.dart';

/// Utility class for enforcing subscription plan limits across the app
class SubscriptionGuard {
  final SubscriptionService _subscriptionService;
  final Dio _dio;

  SubscriptionGuard(this._subscriptionService, this._dio);

  /// Shows the subscription upgrade modal
  static void showUpgradeModal(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Required'),
        content: Text(message ??
            'This feature is not available on your current plan. Please upgrade to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              SubscriptionModal.show(context);
            },
            child: const Text('Upgrade Plan'),
          ),
        ],
      ),
    );
  }

  /// Checks if the user can create a catalog item based on their plan limit
  /// Returns true if allowed, false otherwise (and shows upgrade modal)
  Future<bool> checkCatalogLimit(
    BuildContext context, {
    required int currentCount,
  }) async {
    final plan = await _subscriptionService.getCurrentPlan();

    int maxCatalogItems;
    switch (plan) {
      case SubscriptionPlan.free:
        maxCatalogItems = 0; // Free plan cannot create catalog items
        break;
      case SubscriptionPlan.bronze:
        maxCatalogItems = 10;
        break;
      case SubscriptionPlan.silver:
        maxCatalogItems = 25;
        break;
      case SubscriptionPlan.gold:
        maxCatalogItems = 50;
        break;
      default:
        maxCatalogItems = 0;
    }

    if (currentCount >= maxCatalogItems) {
      if (!context.mounted) return false;

      final planName = plan.toString().split('.').last.toUpperCase();
      showUpgradeModal(
        context,
        message: plan == SubscriptionPlan.free
            ? 'You need a paid subscription to create catalog items. Please upgrade to Bronze, Silver, or Gold plan.'
            : 'You have reached the catalog item limit for your $planName plan ($maxCatalogItems items). Upgrade to a higher plan to add more items.',
      );
      return false;
    }

    return true;
  }

  /// Checks if the user can access a specific invoice style based on their plan
  /// Returns true if allowed, false otherwise (and shows upgrade modal)
  Future<bool> checkInvoiceStyleAccess(
    BuildContext context, {
    required String requestedStyle,
  }) async {
    final plan = await _subscriptionService.getCurrentPlan();

    // Define allowed styles per plan
    final List<String> allowedStyles;
    switch (plan) {
      case SubscriptionPlan.free:
        allowedStyles = ['modern'];
        break;
      case SubscriptionPlan.bronze:
        allowedStyles = ['classic', 'modern', 'minimal'];
        break;
      case SubscriptionPlan.silver:
      case SubscriptionPlan.gold:
        // All styles available
        return true;
      default:
        allowedStyles = ['modern'];
    }

    if (!allowedStyles.contains(requestedStyle.toLowerCase())) {
      if (!context.mounted) return false;

      final planName = plan.toString().split('.').last.toUpperCase();
      showUpgradeModal(
        context,
        message:
            'The "$requestedStyle" invoice style is not available on your $planName plan. Upgrade to Silver or Gold plan to access all invoice styles.',
      );
      return false;
    }

    return true;
  }

  /// Checks if the user can create an invoice based on their plan
  /// This checks backend limits, returns true if allowed
  Future<bool> checkInvoiceCreationLimit(
    BuildContext context, {
    String? errorDetail,
  }) async {
    // For invoice limits, the backend will handle the check
    // This method is called when a 403 error occurs during invoice creation
    if (!context.mounted) return false;

    showUpgradeModal(
      context,
      message: errorDetail ??
          'You have reached the invoice limit for your current plan. Upgrade to create more invoices.',
    );
    return false;
  }

  /// Checks if the user can apply for a job based on their plan limit
  /// Returns true if allowed, false otherwise (and shows upgrade modal)
  Future<bool> checkJobApplicationLimit(BuildContext context) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.subscriptionApplicationLimit);
      final data = response.data;

      // Parse the response to check if application is allowed
      bool canApply = true;
      String? message;

      if (data is Map) {
        // Check if limit reached
        final limitReached = data['limit_reached'] == true ||
            data['can_apply'] == false ||
            (data['data'] is Map && data['data']['limit_reached'] == true) ||
            (data['data'] is Map && data['data']['can_apply'] == false);

        if (limitReached) {
          canApply = false;
          // Extract message from response
          message = data['message']?.toString() ??
              data['detail']?.toString() ??
              (data['data'] is Map
                  ? (data['data']['message']?.toString() ??
                      data['data']['detail']?.toString())
                  : null) ??
              'You have reached the job application limit for your current plan. Upgrade to apply for more jobs.';
        }
      }

      if (!canApply) {
        if (!context.mounted) return false;
        showUpgradeModal(context, message: message);
        return false;
      }

      return true;
    } catch (e) {
      // If API call fails, allow the application (backend will handle the actual limit)
      // This is a UX enhancement, not the primary enforcement
      return true;
    }
  }

  /// Generic check for any premium feature
  Future<bool> checkPremiumFeature(
    BuildContext context, {
    required List<SubscriptionPlan> requiredPlans,
    String? featureName,
  }) async {
    final plan = await _subscriptionService.getCurrentPlan();

    if (!requiredPlans.contains(plan)) {
      if (!context.mounted) return false;

      final planNames = requiredPlans
          .map((p) => p.toString().split('.').last.toUpperCase())
          .join(', ');

      showUpgradeModal(
        context,
        message: featureName != null
            ? '$featureName is only available on $planNames plans. Please upgrade to access this feature.'
            : 'This feature requires a $planNames plan. Please upgrade to continue.',
      );
      return false;
    }

    return true;
  }
}
