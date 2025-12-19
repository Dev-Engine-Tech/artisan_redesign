import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Billing cycle toggle widget (Monthly/Yearly)
///
/// Displays:
/// - Toggle between Monthly and Yearly billing
/// - Visual feedback for selected option
/// - Clean, modern design with shadows
class BillingCycleToggle extends StatelessWidget {
  final bool isYearly;
  final ValueChanged<bool> onChanged;

  const BillingCycleToggle({
    required this.isYearly,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onTap: () => onChanged(false),
              child: Container(
                padding: AppSpacing.verticalSM,
                decoration: BoxDecoration(
                  color: !isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: !isYearly
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
                    color: !isYearly ? AppColors.brownHeader : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: AppSpacing.verticalSM,
                decoration: BoxDecoration(
                  color: isYearly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isYearly
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
                    color: isYearly ? AppColors.brownHeader : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
