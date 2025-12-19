import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Payment provider selection dialog
///
/// Shows:
/// - Insufficient wallet balance warning (if applicable)
/// - Payment provider options (Paystack, Moniepoint, Bank Transfer)
/// - Cancel button
///
/// Returns the selected provider string or null if cancelled
class PaymentProviderDialog extends StatelessWidget {
  final double? shortfall;
  final double? requiredAmount;

  const PaymentProviderDialog({
    this.shortfall,
    this.requiredAmount,
    super.key,
  });

  /// Show the payment provider selection dialog
  static Future<String?> show(
    BuildContext context, {
    double? shortfall,
    double? requiredAmount,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => PaymentProviderDialog(
        shortfall: shortfall,
        requiredAmount: requiredAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Shortfall: ₦${shortfall?.toStringAsFixed(0) ?? 'N/A'}',
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
}
