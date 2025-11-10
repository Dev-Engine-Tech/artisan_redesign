import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

class PaymentSummaryWidget extends StatelessWidget {
  final Job job;

  const PaymentSummaryWidget({
    required this.job,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXL,
      ),
      child: Container(
        padding: AppSpacing.paddingXXL,
        decoration: BoxDecoration(
          borderRadius: AppRadius.radiusXL,
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: AppColors.orange,
                  size: 24,
                ),
                AppSpacing.spaceSM,
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownHeader,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.cardBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMD,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.spaceXL,
            _buildPaymentItem('Project', job.title),
            _buildPaymentItem('Category', job.category),
            const Divider(height: 32),
            _buildPaymentItem(
              'Total Amount',
              'NGN ${_formatAmount(job.agreement?.amount ?? job.minBudget.toDouble())}',
              isHighlighted: true,
            ),
            _buildPaymentItem(
              'Payment Status',
              _getPaymentStatusText(job.paymentStatus ?? 'completed'),
              statusColor:
                  _getPaymentStatusColor(job.paymentStatus ?? 'completed'),
            ),
            if (job.completedDate != null) ...[
              _buildPaymentItem(
                'Completed Date',
                _formatDate(job.completedDate!),
              ),
            ],
            AppSpacing.spaceXXL,
            Row(
              children: [
                Expanded(
                  child: OutlinedAppButton(
                    text: 'Download Invoice',
                    onPressed: () => _downloadInvoice(context),
                  ),
                ),
                AppSpacing.spaceMD,
                Expanded(
                  child: PrimaryButton(
                    text: 'Share Details',
                    onPressed: () => _sharePaymentDetails(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(
    String label,
    String value, {
    bool isHighlighted = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          AppSpacing.spaceSM,
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                fontSize: isHighlighted ? 16 : 14,
                color: statusColor ??
                    (isHighlighted ? AppColors.orange : AppColors.brownHeader),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Payment Completed';
      case 'pending':
        return 'Payment Pending';
      case 'processing':
        return 'Processing Payment';
      default:
        return 'Payment Completed';
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _downloadInvoice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invoice download started'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  void _sharePaymentDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment details shared'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.of(context).pop();
  }
}
