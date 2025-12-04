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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: colorScheme.surface,
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
              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
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
                        request.catalogTitle?.isNotEmpty == true
                            ? request.catalogTitle!
                            : request.title,
                        style: theme.textTheme.titleMedium
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

                // Price display
                _buildPriceInfo(),

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

  /// Builds price information display
  Widget _buildPriceInfo() {
    // Priority: paymentBudget > priceMin/Max > calculate from materials
    String? priceDisplay;

    if (request.paymentBudget != null && request.paymentBudget!.isNotEmpty) {
      final budget = double.tryParse(request.paymentBudget!);
      if (budget != null) {
        priceDisplay = '₦${budget.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
      }
    } else if (request.priceMin != null || request.priceMax != null) {
      final minPrice = double.tryParse(request.priceMin ?? '0') ?? 0;
      final maxPrice = double.tryParse(request.priceMax ?? request.priceMin ?? '0') ?? 0;

      if (minPrice == maxPrice && minPrice > 0) {
        priceDisplay = '₦${minPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
      } else if (minPrice > 0 && maxPrice > 0) {
        priceDisplay = '₦${minPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )} - ₦${maxPrice.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
      }
    } else if (request.materials.isNotEmpty) {
      // Calculate total from materials
      final total = request.materials.fold<int>(
        0,
        (sum, material) => sum + ((material.price ?? 0) * (material.quantity ?? 1)),
      );
      if (total > 0) {
        priceDisplay = '₦${total.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
      }
    }

    if (priceDisplay == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.attach_money,
            size: 18,
            color: AppColors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            priceDisplay,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.orange,
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (client.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    client.email!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (client.phone?.isNotEmpty == true) ...[
                  const SizedBox(height: 2),
                  Text(
                    client.phone!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (request.description.isNotEmpty) ...[
          Text(
            'Description:',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          AppSpacing.spaceXS,
          Text(
            request.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
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
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              AppSpacing.spaceXS,
              Text(
                'Delivery: ${_formatDate(request.deliveryDateTime!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildApprovalIndicator('Artisan', request.isArtisanApproved),
          AppSpacing.spaceLG,
          _buildApprovalIndicator('Client', request.isClientApproved),
          const Spacer(),
          Text(
            '${request.approvalCount}/2 Approved',
            style: theme.textTheme.bodySmall?.copyWith(
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: approved ? Colors.green : colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: approved ? Colors.green : colorScheme.outline,
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: approved ? Colors.green : colorScheme.onSurface.withValues(alpha: 0.7),
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
