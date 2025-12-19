import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Subscription pricing card widget
///
/// Displays:
/// - Plan title and description
/// - Pricing information (monthly/yearly)
/// - Upgrade button
/// - Feature list with checkmarks
/// - Optional save badge for yearly plans
/// - Hierarchical plan indicator (e.g., "Everything in Bronze Plan +")
class SubscriptionPricingCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String period;
  final LinearGradient gradient;
  final String buttonText;
  final List<String> features;
  final String planName; // bronze, silver, gold
  final String? savePercent;
  final bool isHierarchical;
  final String? previousPlan;
  final VoidCallback onUpgradePressed;

  const SubscriptionPricingCard({
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    required this.gradient,
    required this.buttonText,
    required this.features,
    required this.planName,
    required this.onUpgradePressed,
    this.savePercent,
    this.isHierarchical = false,
    this.previousPlan,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: onUpgradePressed,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
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
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
