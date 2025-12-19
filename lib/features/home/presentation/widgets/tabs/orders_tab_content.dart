import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_request.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';
import 'package:artisans_circle/features/home/presentation/widgets/empty_state_widget.dart';

/// Separate widget for Orders tab
class OrdersTabContent extends StatefulWidget {
  const OrdersTabContent({
    required this.onRequestTap,
    super.key,
  });

  final Function(CatalogRequest) onRequestTap;

  @override
  State<OrdersTabContent> createState() => _OrdersTabContentState();
}

class _OrdersTabContentState extends State<OrdersTabContent> {
  String? _processingId; // request id currently being processed

  @override
  Widget build(BuildContext context) {
    // Drive UI from CatalogRequestsBloc state
    return BlocListener<CatalogRequestsBloc, CatalogRequestsState>(
      listener: (context, state) {
        if (state is CatalogRequestApproving ||
            state is CatalogRequestDeclining) {
          setState(() {
            _processingId = (state is CatalogRequestApproving)
                ? state.id
                : (state as CatalogRequestDeclining).id;
          });
        } else if (state is CatalogRequestActionSuccess) {
          // Reset processing id; and refresh real data
          setState(() {
            _processingId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request updated successfully')),
          );
          context.read<CatalogRequestsBloc>().add(RefreshCatalogRequests());
        } else if (state is CatalogRequestsError) {
          setState(() {
            _processingId = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<CatalogRequestsBloc, CatalogRequestsState>(
        builder: (context, state) {
          if (state is CatalogRequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CatalogRequestsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: context.dangerColor),
                  AppSpacing.spaceLG,
                  Text(state.message,
                      style: TextStyle(
                          color: context.darkBlueColor.withValues(alpha: 0.7),
                          fontSize: 16)),
                  AppSpacing.spaceSM,
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: () => context
                        .read<CatalogRequestsBloc>()
                        .add(LoadCatalogRequests()),
                  ),
                ],
              ),
            );
          }
          if (state is CatalogRequestsLoaded) {
            final orders = state.items;
            if (orders.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.shopping_cart_outlined,
                title: 'No Orders',
                subtitle: 'Catalog requests will appear here',
              );
            }
            return ListView.builder(
              itemCount: orders.length,
              padding: AppSpacing.verticalSM,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Smooth scrolling behavior
              cacheExtent: 400, // Cache more items offscreen for smoother scrolling
              addAutomaticKeepAlives:
                  true, // Keep list items alive for better performance
              addRepaintBoundaries: true, // Isolate repaints for performance
              itemBuilder: (context, index) {
                final request = orders[index];
                final jobFromRequest = Job(
                  id: request.id,
                  title: request.title,
                  category: 'Catalog Request',
                  description: request.description,
                  address: request.clientName ?? 'Client',
                  minBudget:
                      (double.tryParse(request.priceMin ?? '0') ?? 0).toInt(),
                  maxBudget:
                      (double.tryParse(request.priceMax ?? '0') ?? 0).toInt(),
                  duration: request.status?.toUpperCase() ?? 'PENDING',
                  applied: false,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(
                    job: jobFromRequest,
                    onTap: () => widget.onRequestTap(request),
                    primaryLabel: 'Accept',
                    secondaryLabel: 'Reject',
                    primaryAction: (_processingId == request.id)
                        ? null
                        : () {
                            context
                                .read<CatalogRequestsBloc>()
                                .add(ApproveRequestEvent(request.id));
                          },
                    secondaryAction: (_processingId == request.id)
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Reject Request'),
                                content: const Text(
                                    'Are you sure you want to reject this request?'),
                                actions: [
                                  TextAppButton(
                                    text: 'Cancel',
                                    onPressed: () => Navigator.pop(ctx, false),
                                  ),
                                  TextAppButton(
                                    text: 'Reject',
                                    onPressed: () => Navigator.pop(ctx, true),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              context
                                  .read<CatalogRequestsBloc>()
                                  .add(DeclineRequestEvent(request.id));
                            }
                          },
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
