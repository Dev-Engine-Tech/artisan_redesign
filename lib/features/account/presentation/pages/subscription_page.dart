import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/utils/responsive.dart';

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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  buttonText: 'Get Started',
                  features: [
                    'Profile creation and management',
                    'Basic job search and application',
                    'Access to public job listings',
                    'Standard customer support',
                    'Basic messaging with clients',
                    'Upload up to 10 catalogue items',
                    '15% commission per completed job',
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
                  buttonText: 'Upgrade Now',
                  savePercent: _isYearly ? '17%' : null,
                  isHierarchical: true,
                  previousPlan: 'Bronze',
                  features: [
                    'Priority job notifications',
                    'Advanced search filters',
                    'Portfolio showcase',
                    'Professional badge',
                    'Enhanced messaging features',
                    'Basic analytics dashboard',
                    'Upload up to 25 catalogue items',
                    '10% commission per completed job',
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
                  buttonText: 'Contact Sales',
                  savePercent: _isYearly ? '17%' : null,
                  isHierarchical: true,
                  previousPlan: 'Silver',
                  features: [
                    'Premium job visibility',
                    'Advanced portfolio tools',
                    'Verified professional status',
                    'Priority customer support',
                    'Marketing tools and promotion',
                    'Custom branding options',
                    'Upload up to 50 catalogue items',
                    '5% commission per completed job',
                  ],
                ),
              ],
            ),
          ),
        ],
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
              OutlinedAppButton(
                text: buttonText,
                onPressed: () {},
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
