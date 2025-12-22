import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/entities/catalog_request.dart';
import '../bloc/catalog_requests_bloc.dart';
import '../widgets/material_management_widget.dart';
import '../../../../core/utils/responsive.dart';
import 'package:artisans_circle/features/clients/presentation/pages/client_profile_page.dart';

class CatalogRequestViewPage extends StatefulWidget {
  final String requestId;
  const CatalogRequestViewPage({required this.requestId, super.key});

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocProvider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Request Details'),
          elevation: 0,
          backgroundColor: colorScheme.surface.withValues(alpha: 0.0),
          leading: Navigator.canPop(context)
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.softPinkColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: colorScheme.onSurfaceVariant),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                )
              : null,
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
            if (state is CatalogRequestsLoading ||
                state is CatalogRequestsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is CatalogRequestsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.grey.shade400),
                    AppSpacing.spaceLG,
                    Text('Error: ${state.message}'),
                    AppSpacing.spaceLG,
                    PrimaryButton(
                      text: 'Retry',
                      onPressed: () =>
                          bloc.add(LoadCatalogRequestDetails(widget.requestId)),
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
      padding: context.responsivePadding,
      children: [
        // Header card with title and status
        _buildHeaderCard(context, request),
        AppSpacing.spaceLG,

        // Client information (if available)
        if (request.client != null) ...[
          _buildClientCard(context, request.client!),
          AppSpacing.spaceLG,
        ],

        // Request description
        _buildDescriptionCard(context, request),
        AppSpacing.spaceLG,

        // Delivery information
        if (request.deliveryDateTime != null) ...[
          _buildDeliveryCard(context, request),
          AppSpacing.spaceLG,
        ],

        // Materials section
        Container(
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(color: AppColors.subtleBorder),
          ),
          child: MaterialManagementWidget(
            requestId: request.id,
            initialMaterials: request.materials,
            isEditable: !request.isArtisanApproved,
          ),
        ),
        AppSpacing.spaceLG,

        // Approval status
        _buildApprovalStatusCard(context, request),
        AppSpacing.spaceLG,

        // Action buttons
        if (!request.isBothApproved) ...[
          _buildActionButtons(context, request),
          AppSpacing.spaceXXL,
        ],
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, CatalogRequest request) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: context.subtleBorderColor),
      ),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildStatusBadge(request),
            ],
          ),
          if (request.createdAt != null) ...[
            AppSpacing.spaceSM,
            Row(
              children: [
                Icon(Icons.schedule,
                    size: 16, color: colorScheme.onSurfaceVariant),
                AppSpacing.spaceXS,
                Text(
                  'Created: ${_formatDate(request.createdAt!)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
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
        color: context.cardBackgroundColor,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: context.subtleBorderColor),
      ),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceMD,
          Row(
            children: [
              Builder(
                builder: (context) => CircleAvatar(
                  radius: 24,
                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    color: context.primaryColor,
                    size: 24,
                  ),
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
                        fontSize: 16,
                      ),
                    ),
                    if (client.email?.isNotEmpty == true) ...[
                      AppSpacing.spaceXS,
                      Row(
                        children: [
                          Icon(Icons.email,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          AppSpacing.spaceXS,
                          Text(
                            client.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (client.phone?.isNotEmpty == true) ...[
                      AppSpacing.spaceXS,
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          AppSpacing.spaceXS,
                          Text(
                            client.phone!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PrimaryButton(
                text: 'View Profile',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ClientProfilePage(clientId: client.id),
                    ),
                  );
                },
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
        color: context.cardBackgroundColor,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: context.subtleBorderColor),
      ),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceSM,
          Text(
            request.description.isNotEmpty
                ? request.description
                : 'No description provided',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, CatalogRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: context.subtleBorderColor),
      ),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceSM,
          Row(
            children: [
              const Icon(Icons.local_shipping,
                  size: 20, color: AppColors.orange),
              AppSpacing.spaceSM,
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

  Widget _buildApprovalStatusCard(
      BuildContext context, CatalogRequest request) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: context.subtleBorderColor),
      ),
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approval Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.spaceMD,
          Row(
            children: [
              _buildApprovalIndicator('Artisan', request.isArtisanApproved),
              AppSpacing.spaceXXL,
              _buildApprovalIndicator('Client', request.isClientApproved),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: request.isBothApproved
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusLG,
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
                    color:
                        request.isBothApproved ? Colors.green : Colors.orange,
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
        AppSpacing.spaceSM,
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
      return OutlinedAppButton(
        text: 'Already Approved',
        onPressed: () {
          // Already approved, maybe allow to revoke?
        },
      );
    }

    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: 'Approve',
            onPressed: () {
              context
                  .read<CatalogRequestsBloc>()
                  .add(ApproveRequestEvent(request.id));
            },
          ),
        ),
        AppSpacing.spaceLG,
        Expanded(
          child: OutlinedAppButton(
            text: 'Decline',
            onPressed: () => _showDeclineDialog(context, request),
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
        borderRadius: AppRadius.radiusLG,
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
            AppSpacing.spaceMD,
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            AppSpacing.spaceMD,
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
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          PrimaryButton(
            text: 'Decline',
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
          ),
        ],
      ),
    );
  }
}
