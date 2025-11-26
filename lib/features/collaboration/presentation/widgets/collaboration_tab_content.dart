import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import '../../domain/entities/collaboration.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../bloc/collaboration_bloc.dart';
import '../bloc/collaboration_event.dart';
import '../bloc/collaboration_state.dart';
import '../pages/collaboration_details_page.dart';
import 'collaboration_card.dart';

/// Tab content for viewing all collaborations with status filters
class CollaborationTabContent extends StatefulWidget {
  const CollaborationTabContent({super.key});

  @override
  State<CollaborationTabContent> createState() =>
      _CollaborationTabContentState();
}

class _CollaborationTabContentState extends State<CollaborationTabContent>
    with SingleTickerProviderStateMixin {
  late TabController _statusTabController;
  int _selectedStatusIndex = 0;

  final List<_StatusTab> _statusTabs = const [
    _StatusTab(
      label: 'All',
      status: null,
      icon: Icons.all_inclusive,
    ),
    _StatusTab(
      label: 'Pending',
      status: CollaborationStatus.pending,
      icon: Icons.pending_outlined,
    ),
    _StatusTab(
      label: 'Active',
      status: CollaborationStatus.accepted,
      icon: Icons.check_circle_outline,
    ),
    _StatusTab(
      label: 'Completed',
      status: CollaborationStatus.completed,
      icon: Icons.task_alt,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _statusTabController = TabController(
      length: _statusTabs.length,
      vsync: this,
    );
    _statusTabController.addListener(_onStatusTabChanged);

    // Load all collaborations initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCollaborations(null);
      }
    });
  }

  @override
  void dispose() {
    _statusTabController.removeListener(_onStatusTabChanged);
    _statusTabController.dispose();
    super.dispose();
  }

  void _onStatusTabChanged() {
    if (_statusTabController.indexIsChanging) return;

    setState(() {
      _selectedStatusIndex = _statusTabController.index;
    });

    _loadCollaborations(_statusTabs[_selectedStatusIndex].status);
  }

  void _loadCollaborations(CollaborationStatus? status) {
    context.read<CollaborationBloc>().add(
          LoadCollaborationsEvent(
            status: status,
            page: 1,
            pageSize: 50,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status filter tabs
        _buildStatusFilterTabs(),

        // Collaboration list
        Expanded(
          child: BlocListener<CollaborationBloc, CollaborationState>(
            listener: (context, state) {
              if (state is CollaborationResponseSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.action == CollaborationAction.accept
                          ? 'Collaboration accepted!'
                          : 'Collaboration declined',
                    ),
                  ),
                );
                // Refresh current filter
                _loadCollaborations(_statusTabs[_selectedStatusIndex].status);
              } else if (state is CollaborationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: BlocBuilder<CollaborationBloc, CollaborationState>(
              builder: (context, state) {
                if (state is CollaborationLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.orange,
                    ),
                  );
                }

                if (state is CollaborationError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.danger,
                          ),
                          AppSpacing.spaceLG,
                          const Text(
                            'Failed to load collaborations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.spaceSM,
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          AppSpacing.spaceLG,
                          PrimaryButton(
                            text: 'Retry',
                            onPressed: () => _loadCollaborations(
                              _statusTabs[_selectedStatusIndex].status,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CollaborationsLoaded) {
                  final collaborations = state.collaborations;

                  if (collaborations.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadCollaborations(
                        _statusTabs[_selectedStatusIndex].status,
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: collaborations.length,
                      itemBuilder: (context, index) {
                        final collaboration = collaborations[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CollaborationCard(
                            collaboration: collaboration,
                            onAccept: collaboration.canRespond
                                ? () => _handleAccept(collaboration)
                                : null,
                            onReject: collaboration.canRespond
                                ? () => _handleReject(collaboration)
                                : null,
                            onTap: () => _navigateToDetails(collaboration),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusTabs.length,
        itemBuilder: (context, index) {
          final tab = _statusTabs[index];
          final isSelected = _selectedStatusIndex == index;

          return GestureDetector(
            onTap: () {
              _statusTabController.animateTo(index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.softPink : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? AppColors.softPink
                      : AppColors.subtleBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tab.icon,
                    size: 18,
                    color: AppColors.brownHeader,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: AppColors.brownHeader,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final selectedTab = _statusTabs[_selectedStatusIndex];
    String message;

    switch (selectedTab.status) {
      case CollaborationStatus.pending:
        message = 'No pending collaboration invites';
        break;
      case CollaborationStatus.accepted:
        message = 'No active collaborations';
        break;
      case CollaborationStatus.completed:
        message = 'No completed collaborations';
        break;
      default:
        message = 'No collaborations yet';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[300],
            ),
            AppSpacing.spaceLG,
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            AppSpacing.spaceSM,
            const Text(
              'Collaborations with other artisans will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccept(Collaboration collaboration) {
    context.read<CollaborationBloc>().add(
          RespondToCollaborationEvent(
            collaborationId: collaboration.id,
            action: CollaborationAction.accept,
          ),
        );
  }

  void _handleReject(Collaboration collaboration) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Decline Collaboration'),
        content: const Text(
          'Are you sure you want to decline this collaboration invite?',
        ),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(ctx),
          ),
          TextAppButton(
            text: 'Decline',
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CollaborationBloc>().add(
                    RespondToCollaborationEvent(
                      collaborationId: collaboration.id,
                      action: CollaborationAction.reject,
                    ),
                  );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(Collaboration collaboration) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollaborationDetailsPage(
          collaboration: collaboration,
        ),
      ),
    );

    // Refresh if collaboration was updated
    if (result == true && mounted) {
      _loadCollaborations(_statusTabs[_selectedStatusIndex].status);
    }
  }
}

class _StatusTab {
  final String label;
  final CollaborationStatus? status;
  final IconData icon;

  const _StatusTab({
    required this.label,
    required this.status,
    required this.icon,
  });
}
