import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/theme.dart';
import '../../domain/entities/catalog_request.dart';
import '../bloc/catalog_requests_bloc.dart';
import '../widgets/material_management_widget.dart';

class CatalogRequestViewPage extends StatefulWidget {
  final String requestId;
  const CatalogRequestViewPage({super.key, required this.requestId});

  @override
  State<CatalogRequestViewPage> createState() => _CatalogRequestViewPageState();
}

class _CatalogRequestViewPageState extends State<CatalogRequestViewPage> {
  late final CatalogRequestsBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt<CatalogRequestsBloc>();
    bloc.add(LoadCatalogRequestDetails(widget.requestId));
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Request Details'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
        body: BlocConsumer<CatalogRequestsBloc, CatalogRequestsState>(
          listener: (context, state) {
            if (state is CatalogRequestActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Action completed successfully')),
              );
              Navigator.of(context).pop(true);
            } else if (state is CatalogRequestsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            if (state is CatalogRequestsLoading || state is CatalogRequestsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CatalogRequestsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => bloc.add(LoadCatalogRequestDetails(widget.requestId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is CatalogRequestDetailsLoaded) {
              return _buildRequestDetails(context, state.item);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRequestDetails(BuildContext context, CatalogRequest request) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Header card with title and status
        _buildHeaderCard(context, request),
        const SizedBox(height: 16),

        // Client information (if available)
        if (request.client != null) ...[
          _buildClientCard(context, request.client!),
          const SizedBox(height: 16),
        ],

        // Request description
        _buildDescriptionCard(context, request),
        const SizedBox(height: 16),

        // Delivery information
        if (request.deliveryDateTime != null) ...[
          _buildDeliveryCard(context, request),
          const SizedBox(height: 16),
        ],

        // Materials section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.subtleBorder),
          ),
          child: MaterialManagementWidget(
            requestId: request.id,
            initialMaterials: request.materials,
            isEditable: !request.isArtisanApproved,
          ),
        ),
        const SizedBox(height: 16),

        // Approval status
        _buildApprovalStatusCard(context, request),
        const SizedBox(height: 16),

        // Action buttons
        if (!request.isBothApproved) ...[
          _buildActionButtons(context, request),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, CatalogRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _buildStatusBadge(request),
            ],
          ),
          if (request.createdAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Created: ${_formatDate(request.createdAt!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, CatalogClient client) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.orange.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
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
                      client.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (client.email?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            client.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (client.phone?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            client.phone!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, CatalogRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            request.description.isNotEmpty ? request.description : 'No description provided',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, CatalogRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.local_shipping, size: 20, color: AppColors.orange),
              const SizedBox(width: 8),
              Text(
                'Expected Delivery: ${_formatDate(request.deliveryDateTime!)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalStatusCard(BuildContext context, CatalogRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approval Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildApprovalIndicator('Artisan', request.isArtisanApproved),
              const SizedBox(width: 24),
              _buildApprovalIndicator('Client', request.isClientApproved),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: request.isBothApproved
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: request.isBothApproved
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${request.approvalCount}/2 Approved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: request.isBothApproved ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalIndicator(String label, bool approved) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
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
                  size: 14,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: approved ? Colors.green : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, CatalogRequest request) {
    if (request.isArtisanApproved) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            // Already approved, maybe allow to revoke?
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Already Approved'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              context.read<CatalogRequestsBloc>().add(ApproveRequestEvent(request.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Approve', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showDeclineDialog(context, request),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.red.shade300),
            ),
            child: Text(
              'Decline',
              style: TextStyle(fontSize: 16, color: Colors.red.shade600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(CatalogRequest request) {
    Color statusColor;
    String statusText;

    if (request.isBothApproved) {
      statusColor = Colors.green;
      statusText = 'Approved';
    } else if (request.isArtisanApproved) {
      statusColor = Colors.orange;
      statusText = 'Awaiting Client';
    } else if (request.isClientApproved) {
      statusColor = Colors.blue;
      statusText = 'Awaiting Approval';
    } else {
      statusColor = Colors.grey;
      statusText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeclineDialog(BuildContext context, CatalogRequest request) {
    final reasonController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Decline Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for declining this request:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Additional message (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }

              context.read<CatalogRequestsBloc>().add(
                    DeclineRequestEvent(
                      request.id,
                      reason: reasonController.text.trim(),
                      message: messageController.text.trim().isEmpty
                          ? null
                          : messageController.text.trim(),
                    ),
                  );
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}
