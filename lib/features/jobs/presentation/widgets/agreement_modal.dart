import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/core/utils/currency.dart';
import '../../domain/entities/agreement.dart';
import '../../domain/entities/job.dart';
import '../bloc/job_bloc.dart';
import 'change_request_modal.dart';

/// Modal for displaying and interacting with job agreements
/// Matches the artisan_app design patterns for agreement flows
class AgreementModal extends StatelessWidget {
  final Job job;
  final Agreement agreement;
  final VoidCallback? onClose;

  const AgreementModal({
    required this.job,
    required this.agreement,
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: AppSpacing.verticalMD,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: AppSpacing.horizontalXL,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Project Agreement',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingXL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job title section
                  _buildJobHeader(context),
                  AppSpacing.spaceXL,

                  // Agreement details
                  _buildAgreementDetails(context),
                  AppSpacing.spaceXL,

                  // Payment breakdown
                  _buildPaymentBreakdown(context),
                  AppSpacing.spaceXL,

                  // Timeline section
                  _buildTimeline(context),
                  AppSpacing.spaceXL,

                  // Terms section
                  _buildTermsSection(context),
                  AppSpacing.spaceXXXL,
                ],
              ),
            ),
          ),

          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildJobHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceXS,
          Text(
            job.category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementDetails(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agreement Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceMD,
          _buildDetailRow('Agreement ID', '#${agreement.id}'),
          AppSpacing.spaceSM,
          _buildDetailRow('Status', agreement.status),
          AppSpacing.spaceSM,
          _buildDetailRow(
              'Total Amount', Currency.formatNgn(agreement.agreedPayment)),
          if (agreement.comment.isNotEmpty) ...[
            AppSpacing.spaceMD,
            Text(
              'Client Comments:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            AppSpacing.spaceXS,
            Text(
              agreement.comment,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceMD,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Project Amount',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                Currency.formatNgn(agreement.agreedPayment),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          AppSpacing.spaceSM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platform Fee (5%)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              Text(
                Currency.formatNgn(agreement.agreedPayment * 0.05),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You\'ll Receive',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                Currency.formatNgn(agreement.agreedPayment * 0.95),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Project Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceMD,
          if (agreement.startDate != null)
            _buildDetailRow('Start Date', _formatDate(agreement.startDate!)),
          AppSpacing.spaceSM,
          _buildDetailRow('Delivery Date', _formatDate(agreement.deliveryDate)),
          AppSpacing.spaceSM,
          _buildDetailRow('Duration', job.duration),
        ],
      ),
    );
  }

  Widget _buildTermsSection(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              AppSpacing.spaceSM,
              Text(
                'Important Terms',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade700,
                    ),
              ),
            ],
          ),
          AppSpacing.spaceSM,
          Text(
            '• Payment will be released upon successful project completion\n'
            '• Changes to scope may affect timeline and pricing\n'
            '• Quality standards must be maintained throughout\n'
            '• Communication should remain professional at all times',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange.shade700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Accept button
          PrimaryButton(
            text: 'Accept Agreement',
            onPressed: () => _showAcceptConfirmation(context),
          ),
          AppSpacing.spaceMD,
          // Request changes button
          OutlinedAppButton(
            text: 'Request Changes',
            onPressed: () => _showChangeRequestModal(context),
          ),
        ],
      ),
    );
  }

  void _showAcceptConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Agreement'),
        content: const Text(
          'Are you sure you want to accept this agreement? This action cannot be undone.',
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          PrimaryButton(
            text: 'Accept',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<JobBloc>().add(AcceptAgreementEvent(jobId: job.id));
              Navigator.of(context).pop(); // Close the agreement modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Agreement accepted successfully!')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChangeRequestModal(BuildContext context) {
    Navigator.of(context).pop(); // Close agreement modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChangeRequestModal(job: job),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
