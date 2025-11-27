import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/di.dart';
import '../../../../core/services/subscription_service.dart';
import 'subscription_bank_transfer_page.dart';

class SubscriptionModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SubscriptionPage(),
    );
  }
}

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isYearly = true; // Default to yearly subscription
  SubscriptionPlan _currentPlan = SubscriptionPlan.unknown;

  @override
  void initState() {
    super.initState();
    // Initialize PageController immediately to prevent LateInitializationError
    _pageController = PageController(initialPage: 0);
    _loadCurrentPlan();
  }

  Future<void> _loadCurrentPlan() async {
    try {
      final subscriptionService = getIt<SubscriptionService>();
      final plan = await subscriptionService.getCurrentPlan();

      // Set initial page based on current plan
      int initialPage = 0; // Default to Bronze
      switch (plan) {
        case SubscriptionPlan.free:
          initialPage = 0; // Show Bronze
          break;
        case SubscriptionPlan.bronze:
          initialPage = 1; // Show Silver
          break;
        case SubscriptionPlan.silver:
          initialPage = 2; // Show Gold
          break;
        case SubscriptionPlan.gold:
          initialPage = 2; // Already on Gold, show Gold
          break;
        default:
          initialPage = 0;
      }

      debugPrint('💳 Current plan: $plan, Initial page: $initialPage');

      // Update page controller to show correct plan
      if (mounted &&
          _pageController.hasClients &&
          initialPage != _currentPage) {
        _pageController.jumpToPage(initialPage);
      }

      setState(() {
        _currentPlan = plan;
        _currentPage = initialPage;
      });
    } catch (e) {
      debugPrint('❌ Error loading current plan: $e');
      // Keep default page (already initialized)
    }
  }

  Future<void> _initiateUpgrade(String planName) async {
    try {
      debugPrint('💳 Initiating upgrade to $planName plan...');

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
      );

      final dio = getIt<Dio>();
      debugPrint('💳 Calling API: ${ApiEndpoints.subscriptionPurchase}');
      debugPrint(
          '💳 Data: plan=$planName, billing_cycle=${_isYearly ? 'yearly' : 'monthly'}');

      // Attempt 1: Try wallet-first payment (no payment_provider specified)
      final response = await dio.post(
        ApiEndpoints.subscriptionPurchase,
        data: {
          'plan': planName.toLowerCase(),
          'billing_cycle': _isYearly ? 'yearly' : 'monthly',
        },
      );

      debugPrint('💳 API Response: ${response.data}');

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Extract payment link from response
      String? paymentLink;
      if (response.data is Map) {
        paymentLink = response.data['link'] ??
            response.data['payment_link'] ??
            response.data['authorization_url'] ??
            (response.data['data'] is Map
                ? (response.data['data']['link'] ??
                    response.data['data']['payment_link'] ??
                    response.data['data']['authorization_url'])
                : null);
      }

      debugPrint('💳 Payment link: $paymentLink');

      if (paymentLink != null && paymentLink.isNotEmpty) {
        // Open payment link in webview
        debugPrint('💳 Opening payment webview...');
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _PaymentWebView(url: paymentLink!),
          ),
        );

        // After WebView closes, show success message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Payment completed. Please check your subscription status.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Wallet payment successful (no payment link needed)
        debugPrint('✅ Wallet payment successful (no payment link)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription upgraded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Error initiating payment: $e');
      debugPrint('❌ Response status: ${e.response?.statusCode}');
      debugPrint('❌ Response data: ${e.response?.data}');

      if (!mounted) return;

      // Try to close loading dialog
      try {
        Navigator.pop(context);
      } catch (_) {}

      // Check for 402 Payment Required (insufficient wallet balance)
      if (e.response?.statusCode == 402) {
        debugPrint(
            '💳 Insufficient wallet balance - showing provider selection');

        final responseData = e.response?.data;
        double? shortfall;
        double? requiredAmount;

        if (responseData is Map) {
          // Handle both string and number types from backend
          final shortfallValue = responseData['shortfall'];
          final requiredValue = responseData['required_amount'];

          shortfall = shortfallValue is num
              ? shortfallValue.toDouble()
              : (shortfallValue is String
                  ? double.tryParse(shortfallValue)
                  : null);

          requiredAmount = requiredValue is num
              ? requiredValue.toDouble()
              : (requiredValue is String
                  ? double.tryParse(requiredValue)
                  : null);
        }

        // Show payment provider selection dialog
        final selectedProvider = await _showPaymentProviderSelection(
          shortfall: shortfall,
          requiredAmount: requiredAmount,
        );

        if (selectedProvider != null) {
          // Retry with selected payment provider, passing the full response data
          await _retryPaymentWithProvider(
              planName, selectedProvider, responseData);
        }
      } else {
        // Other errors (5xx/4xx): show detail + request id if present and allow retry
        String message = 'Failed to initiate payment.';
        String? requestId;
        final data = e.response?.data;
        if (data is Map) {
          if (data['detail'] != null) message = data['detail'].toString();
          requestId = (data['request_id'] ?? data['requestId'])?.toString();
        } else if (e.message != null) {
          message = e.message!;
        }

        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Payment Error'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (requestId != null) ...[
                  const SizedBox(height: 8),
                  Text('Error ID: $requestId',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _initiateUpgrade(planName);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (!mounted) return;

      // Try to close loading dialog
      try {
        Navigator.pop(context);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initiate payment: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<String?> _showPaymentProviderSelection({
    double? shortfall,
    double? requiredAmount,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Choose Payment Method',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.brownHeader,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shortfall != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.orange, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Insufficient wallet balance',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownHeader,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Amount needed: ₦${requiredAmount?.toStringAsFixed(0) ?? 'N/A'}',
                          style: TextStyle(
                            color: AppColors.brownHeader.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Shortfall: ₦${shortfall.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Text(
                'Select a payment method to continue:',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.brownHeader,
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentProviderOption(
                context: context,
                provider: 'paystack',
                icon: Icons.credit_card,
                title: 'Paystack',
                description: 'Pay with card, bank transfer, or USSD',
              ),
              const SizedBox(height: 12),
              _buildPaymentProviderOption(
                context: context,
                provider: 'moniepoint',
                icon: Icons.account_balance,
                title: 'Moniepoint',
                description: 'Pay with Moniepoint/Monnify',
              ),
              const SizedBox(height: 12),
              _buildPaymentProviderOption(
                context: context,
                provider: 'bank_transfer',
                icon: Icons.account_balance_wallet,
                title: 'Bank Transfer',
                description: 'Manual bank transfer',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentProviderOption({
    required BuildContext context,
    required String provider,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(provider),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownHeader,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.brownHeader.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _retryPaymentWithProvider(
    String planName,
    String provider,
    Map<String, dynamic>? paymentData,
  ) async {
    try {
      debugPrint('💳 Processing payment with provider: $provider');

      // Extract payment options and reference from the 402 response
      final paymentOptions = paymentData?['payment_options'];
      final paymentReference = paymentData?['payment_reference'];

      debugPrint('💳 Payment reference: $paymentReference');
      debugPrint('💳 Payment options: $paymentOptions');

      if (paymentOptions is! Map) {
        throw Exception('Payment options not available in response');
      }

      // Get the provider-specific data
      final providerData = paymentOptions[provider];

      if (providerData == null) {
        // Provider not available
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${provider.toUpperCase()} is currently not available.\nPlease try another payment method.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Handle bank transfer (navigate to bank transfer page)
      if (provider == 'bank_transfer') {
        final bankTransferData = providerData as Map;
        final reference = bankTransferData['reference'] ?? paymentReference;
        final uploadUrl = bankTransferData['upload_url']?.toString() ??
            '/client/api/bank/transfer/';
        final requiredAmount = paymentData?['required_amount'];

        double amount = 0;
        if (requiredAmount is num) {
          amount = requiredAmount.toDouble();
        } else if (requiredAmount is String) {
          amount = double.tryParse(requiredAmount) ?? 0;
        }

        if (!mounted) return;

        // Navigate to bank transfer page
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SubscriptionBankTransferPage(
              planName: planName,
              amount: amount,
              paymentReference: reference,
              uploadUrl: uploadUrl,
            ),
          ),
        );
        return;
      }

      // For Paystack/Moniepoint, extract payment link directly from payment_options
      String? paymentLink;
      if (providerData is Map) {
        paymentLink = providerData['authorization_url']?.toString() ??
            providerData['payment_link']?.toString() ??
            providerData['link']?.toString();
      }

      debugPrint('💳 Payment link from options: $paymentLink');

      if (paymentLink == null || paymentLink.isEmpty) {
        throw Exception('Payment link not available for $provider');
      }

      // Open payment link in webview (paymentLink is guaranteed non-null here)
      debugPrint('💳 Opening payment webview for $provider...');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => _PaymentWebView(url: paymentLink!),
        ),
      );

      // After WebView closes, show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Payment completed. Please check your subscription status.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error with payment provider: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppColors.lightPeach,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: context.responsivePadding,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Pricing Plans',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brownHeader,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  3,
                  (index) => Container(
                        margin: AppSpacing.horizontalXS,
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.orange
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      )),
            ),
            AppSpacing.spaceSM,
            // Swipe indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                  color: _currentPage > 0 ? AppColors.orange : Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Text(
                  'Swipe to explore plans',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.brownHeader.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _currentPage < 2 ? AppColors.orange : Colors.grey[400],
                ),
              ],
            ),
            AppSpacing.spaceLG,
            // Monthly/Yearly toggle
            Container(
              margin: AppSpacing.horizontalLG,
              padding: AppSpacing.paddingXS,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: AppRadius.radiusMD,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isYearly = false),
                      child: Container(
                        padding: AppSpacing.verticalSM,
                        decoration: BoxDecoration(
                          color: !_isYearly ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: !_isYearly
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          'Monthly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !_isYearly
                                ? AppColors.brownHeader
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isYearly = true),
                      child: Container(
                        padding: AppSpacing.verticalSM,
                        decoration: BoxDecoration(
                          color: _isYearly ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _isYearly
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          'Yearly',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: _isYearly
                                ? AppColors.brownHeader
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.spaceLG,
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildPricingCard(
                    title: 'Bronze Plan',
                    description:
                        'Perfect for individuals starting their artisan journey',
                    price: _isYearly ? '₦50,000' : '₦5,000',
                    period: _isYearly ? '/ year' : '/ month',
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.orange.withValues(alpha: 0.8),
                        AppColors.brownHeader.withValues(alpha: 0.9),
                      ],
                    ),
                    buttonText: 'Upgrade',
                    planName: 'bronze',
                    features: [
                      'All Free features + Priority support, Profile badge, Extended profile visibility',
                      'Smart limits: 10 applications/week; 20 invoices/month; 10 catalog products; up to 2 collaborators/job',
                      'Visibility: Elevated vs Free',
                      'Invoices: "Classic", "Modern", "Minimal" styles',
                      'Best for: Getting noticed more and moving faster with priority support',
                    ],
                  ),
                  _buildPricingCard(
                    title: 'Silver Plan',
                    description:
                        'Best for established artisans looking to grow their business',
                    price: _isYearly ? '₦100,000' : '₦10,000',
                    period: _isYearly ? '/ year' : '/ month',
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.softPink,
                        AppColors.orange.withValues(alpha: 0.7),
                      ],
                    ),
                    buttonText: 'Upgrade',
                    planName: 'silver',
                    savePercent: _isYearly ? '17%' : null,
                    isHierarchical: true,
                    previousPlan: 'Bronze',
                    features: [
                      'All Bronze features + Job matching (smart recommendations to fit your skills), Advanced analytics, Featured profile listing, Priority job applications',
                      'Smart limits: 20 applications/week; 50 invoices/month; 50 catalog products; up to 5 collaborators/job',
                      'Visibility: Featured listing placement',
                      'Invoices: All styles unlocked',
                      'Best for: Consistent lead flow with smarter matches and stronger visibility',
                    ],
                  ),
                  _buildPricingCard(
                    title: 'Gold Plan',
                    description:
                        'Comprehensive solution for large artisan businesses',
                    price: _isYearly ? '₦150,000' : '₦15,000',
                    period: _isYearly ? '/ year' : '/ month',
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.darkBlue.withValues(alpha: 0.8),
                        AppColors.brownHeader,
                      ],
                    ),
                    buttonText: 'Upgrade',
                    planName: 'gold',
                    savePercent: _isYearly ? '17%' : null,
                    isHierarchical: true,
                    previousPlan: 'Silver',
                    features: [
                      'All Silver features + AI-powered job recommendations, Personalized career insights, Unlimited job applications, Premium profile badge, Dedicated account manager',
                      'Limits: Unlimited applications; Unlimited invoices; Unlimited catalog products; Unlimited collaborators/job',
                      'Visibility: Top-tier presence and branding',
                      'Invoices: All styles unlocked',
                      'Best for: Serious growth—maximum visibility, no ceilings, and personal support',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String description,
    required String price,
    required String period,
    required LinearGradient gradient,
    required String buttonText,
    required List<String> features,
    String? savePercent,
    bool isHierarchical = false,
    String? previousPlan,
    required String planName, // bronze, silver, gold
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppRadius.radiusXXL,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.paddingXXL,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (savePercent != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: AppRadius.radiusLG,
                  ),
                  child: Text(
                    'Save $savePercent',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (savePercent != null) AppSpacing.spaceLG,
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.spaceSM,
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              AppSpacing.spaceXXL,
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppSpacing.spaceXS,
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      period,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.spaceXXL,
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _initiateUpgrade(planName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.brownHeader,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: AppColors.brownHeader,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              AppSpacing.spaceXXL,
              const Text(
                'Features Included',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.spaceLG,
              if (isHierarchical && previousPlan != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusMD,
                    ),
                    child: Text(
                      'Everything in $previousPlan Plan +',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ...features.map((feature) => _buildFeatureItem(feature)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Payment WebView widget
class _PaymentWebView extends StatefulWidget {
  final String url;

  const _PaymentWebView({required this.url});

  @override
  State<_PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<_PaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.brownHeader,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
                backgroundColor: AppColors.orange.withValues(alpha: 0.3),
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
