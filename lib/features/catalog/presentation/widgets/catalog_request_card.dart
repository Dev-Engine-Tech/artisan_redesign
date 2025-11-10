import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/entities/catalog_request.dart';
import '../pages/catalog_request_view_page.dart';

/// Enhanced catalog request card with status indicators and client information
/// matching the artisan_app design patterns
class CatalogRequestCard extends StatelessWidget {
  final CatalogRequest request;
  final VoidCallback? onTap;

  const CatalogRequestCard({
    required this.request,
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CatalogRequestViewPage(requestId: request.id),
                  ),
                );
              },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.subtleBorder),
            ),
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title and status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppSpacing.spaceMD,
                    _buildStatusBadge(),
                  ],
                ),

                AppSpacing.spaceMD,

                // Client information
                if (request.client != null) ...[
                  _buildClientInfo(),
                  AppSpacing.spaceMD,
                ],

                // Request details
                _buildRequestDetails(),

                AppSpacing.spaceMD,

                // Approval status
                _buildApprovalStatus(),

                AppSpacing.spaceLG,

                // Action buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the status badge
  Widget _buildStatusBadge() {
    final statusInfo = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: statusInfo.color.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusInfo.text,
        style: TextStyle(
          color: statusInfo.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds client information section
  Widget _buildClientInfo() {
    final client = request.client!;
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: AppRadius.radiusMD,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.orange.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (client.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    client.email!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                if (client.phone?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    client.phone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds request details section
  Widget _buildRequestDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (request.description.isNotEmpty) ...[
          const Text(
            'Description:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.brownHeader,
            ),
          ),
          AppSpacing.spaceXS,
          Text(
            request.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.spaceSM,
        ],
        Row(
          children: [
            if (request.deliveryDateTime != null) ...[
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey.shade600,
              ),
              AppSpacing.spaceXS,
              Text(
                'Delivery: ${_formatDate(request.deliveryDateTime!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Builds approval status section
  Widget _buildApprovalStatus() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildApprovalIndicator('Artisan', request.isArtisanApproved),
          AppSpacing.spaceLG,
          _buildApprovalIndicator('Client', request.isClientApproved),
          const Spacer(),
          Text(
            '${request.approvalCount}/2 Approved',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: request.isBothApproved ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual approval indicator
  Widget _buildApprovalIndicator(String label, bool approved) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: approved ? Colors.green : Colors.grey.shade300,
            border: Border.all(
              color: approved ? Colors.green : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: approved
              ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: approved ? Colors.green : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds action buttons based on request status
  Widget _buildActionButtons(BuildContext context) {
    if (request.isBothApproved) {
      return PrimaryButton(
        text: 'View Details',
        onPressed: () {
          // Navigate to request details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CatalogRequestViewPage(requestId: request.id),
            ),
          );
        },
      );
    }

    return Row(
      children: [
        if (!request.isArtisanApproved) ...[
          Expanded(
            child: PrimaryButton(
              text: 'Approve',
              onPressed: () {
                // Handle approve action
                _handleApprove(context);
              },
            ),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: OutlinedAppButton(
              text: 'Decline',
              onPressed: () {
                // Handle decline action
                _handleDecline(context);
              },
            ),
          ),
        ] else ...[
          Expanded(
            child: OutlinedAppButton(
              text: 'View Details',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CatalogRequestViewPage(requestId: request.id),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Gets status information (color and text)
  ({Color color, String text}) _getStatusInfo() {
    if (request.isBothApproved) {
      return (color: Colors.green, text: 'Approved');
    } else if (request.isArtisanApproved) {
      return (color: Colors.orange, text: 'Awaiting Client');
    } else if (request.isClientApproved) {
      return (color: Colors.blue, text: 'Awaiting Approval');
    } else {
      return (color: Colors.grey, text: 'Pending');
    }
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Handles approve action
  void _handleApprove(BuildContext context) {
    // This would typically trigger a bloc event
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request approved')),
    );
  }

  /// Handles decline action
  void _handleDecline(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Request'),
        content: const Text('Are you sure you want to decline this request?'),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          PrimaryButton(
            text: 'Decline',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request declined')),
              );
            },
          ),
        ],
      ),
    );
  }
}
