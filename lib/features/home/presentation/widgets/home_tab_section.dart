import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/applications_list.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_request.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';
import 'package:artisans_circle/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:artisans_circle/features/collaboration/presentation/bloc/collaboration_event.dart';
import 'package:artisans_circle/features/collaboration/presentation/bloc/collaboration_state.dart';
import 'package:artisans_circle/features/collaboration/presentation/widgets/collaboration_card.dart';
import 'package:artisans_circle/features/collaboration/domain/entities/collaboration.dart';
import 'package:artisans_circle/features/collaboration/presentation/pages/collaboration_details_page.dart';
import 'package:artisans_circle/features/collaboration/domain/repositories/collaboration_repository.dart';

/// Performance-optimized tab section following SOLID principles
/// Single Responsibility: Manages tab display and content
/// Open/Closed: Extensible for new tab types without modification
/// Dependency Inversion: Depends on abstractions (callbacks) not concrete implementations
class HomeTabSection extends StatefulWidget {
  const HomeTabSection({
    required this.onJobTap,
    required this.onRequestTap,
    required this.applications,
    required this.onApplicationUpdate,
    super.key,
  });

  final Function(Job) onJobTap;
  final Function(CatalogRequest) onRequestTap;
  final List<JobModel> applications;
  final Function(List<JobModel>) onApplicationUpdate;

  @override
  State<HomeTabSection> createState() => _HomeTabSectionState();
}

class _HomeTabSectionState extends State<HomeTabSection>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;
  int _selectedIndex = 0;

  @override
  bool get wantKeepAlive => true; // Performance: Keep tab state alive

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load Jobs for initial tab (Jobs tab is index 0) once after first frame
    if (_selectedIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          final state = context.read<JobBloc>().state;
          if (state is! JobStateLoaded) {
            context.read<JobBloc>().add(LoadJobs(page: 1, limit: 10));
          }
        } catch (_) {
          // JobBloc not available, ignore
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedIndex = _tabController.index;
      });

      // Load Jobs when user switches to Jobs tab (index 0) if not already loaded
      if (_selectedIndex == 0) {
        try {
          final state = context.read<JobBloc>().state;
          if (state is! JobStateLoaded) {
            context.read<JobBloc>().add(LoadJobs(page: 1, limit: 10));
          }
        } catch (e) {
          // JobBloc not available, ignore
        }
      }

      // Load Collaboration Invites when user switches to Job Invite tab (index 2)
      if (_selectedIndex == 2) {
        try {
          final state = context.read<CollaborationBloc>().state;
          if (state is! CollaborationsLoaded) {
            context.read<CollaborationBloc>().add(
                  LoadCollaborationsEvent(
                    status: CollaborationStatus.pending,
                    role: CollaborationRole.collaborator,
                    page: 1,
                    pageSize: 10,
                  ),
                );
          }
        } catch (e) {
          // CollaborationBloc not available, ignore
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // debug: selected tab index

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(),
        AppSpacing.spaceLG,
        _buildTabContent(),
      ],
    );
  }

  /// Builds performance-optimized tab bar with const widgets
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softPeach,
        borderRadius: AppRadius.radiusLG,
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.radiusMD,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.darkBlue,
        unselectedLabelColor: AppColors.darkBlue.withValues(alpha: 0.6),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        tabs: const [
          Tab(text: 'Jobs'),
          Tab(text: 'Applications'),
          Tab(text: 'Job Invite'),
          Tab(text: 'Orders'),
        ],
      ),
    );
  }

  /// Builds tab content with fixed height for stable layout
  Widget _buildTabContent() {
    return SizedBox(
      height: 500, // Increased from 400 for better content visibility
      child: _getSelectedTabContent(),
    );
  }

  Widget _getSelectedTabContent() {
    // debug: returning tab content for index
    switch (_selectedIndex) {
      case 0:
        return JobsTabContent(onJobTap: widget.onJobTap);
      case 1:
        return ApplicationsTabContent(
          applications: widget.applications,
          onJobTap: widget.onJobTap,
          onApplicationUpdate: widget.onApplicationUpdate,
        );
      case 2:
        return JobInviteTabContent(onJobTap: widget.onJobTap);
      case 3:
        return OrdersTabContent(onRequestTap: widget.onRequestTap);
      default:
        return JobsTabContent(onJobTap: widget.onJobTap);
    }
  }
}

/// Separate widget for Jobs tab following Single Responsibility Principle
class JobsTabContent extends StatelessWidget {
  const JobsTabContent({
    required this.onJobTap,
    super.key,
  });

  final Function(Job) onJobTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        if (state is JobStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobStateError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.danger),
                AppSpacing.spaceLG,
                Text(
                  'Failed to load jobs',
                  style: TextStyle(
                    color: AppColors.darkBlue.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                AppSpacing.spaceSM,
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<JobBloc>().add(LoadJobs());
                  },
                ),
              ],
            ),
          );
        }

        if (state is JobStateLoaded) {
          // Only show jobs that the artisan has NOT applied for
          final jobs = state.jobs.where((j) => !j.applied).toList();

          if (jobs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.work_outline,
              title: 'No Jobs Available',
              subtitle: 'Check back later for new opportunities',
            );
          }

          // Performance: Use ListView.builder for lazy loading with optimized scroll physics
          return ListView.builder(
            itemCount: jobs.length,
            padding: AppSpacing.verticalSM,
            physics:
                const ClampingScrollPhysics(), // Prevents overscroll within nested scroll
            cacheExtent: 200, // Cache items offscreen for smooth scrolling
            addAutomaticKeepAlives:
                true, // Keep list items alive for better performance
            addRepaintBoundaries: true, // Isolate repaints for performance
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JobCard(
                  job: job,
                  onTap: () => onJobTap(job),
                ),
              );
            },
          );
        }

        // Show loading indicator for initial/unknown states instead of blank space
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// Separate widget for Applications tab
class ApplicationsTabContent extends StatefulWidget {
  const ApplicationsTabContent({
    required this.applications,
    required this.onJobTap,
    required this.onApplicationUpdate,
    super.key,
  });

  final List<JobModel> applications;
  final Function(Job) onJobTap;
  final Function(List<JobModel>) onApplicationUpdate;

  @override
  State<ApplicationsTabContent> createState() => _ApplicationsTabContentState();
}

class _ApplicationsTabContentState extends State<ApplicationsTabContent> {
  @override
  void initState() {
    super.initState();
    // Applications are loaded by the parent HomePage, no need to duplicate the call
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        bool isLoading = state is JobStateLoading;
        String? errorMessage;
        List<Job> applications = [];

        if (state is JobStateError) {
          errorMessage = state.message;
        } else if (state is JobStateAppliedSuccess) {
          // Convert JobModel list to Job list for the ApplicationsList widget
          applications = state.jobs
              .map((jobModel) => Job(
                    id: jobModel.id,
                    title: jobModel.title,
                    category: jobModel.category,
                    description: jobModel.description,
                    address: jobModel.address,
                    minBudget: jobModel.minBudget,
                    maxBudget: jobModel.maxBudget,
                    duration: jobModel.duration,
                    applied: jobModel.applied,
                    thumbnailUrl: jobModel.thumbnailUrl,
                    status: jobModel.status,
                    agreement: jobModel.agreement,
                    changeRequest: jobModel.changeRequest,
                    materials: jobModel.materials,
                  ))
              .toList();
        } else {
          // Fallback to applications provided by parent when bloc doesn't currently hold applications
          applications = widget.applications
              .map((m) => Job(
                    id: m.id,
                    title: m.title,
                    category: m.category,
                    description: m.description,
                    address: m.address,
                    minBudget: m.minBudget,
                    maxBudget: m.maxBudget,
                    duration: m.duration,
                    applied: true,
                    thumbnailUrl: m.thumbnailUrl,
                    status: m.status,
                    agreement: m.agreement,
                    changeRequest: m.changeRequest,
                    materials: m.materials,
                  ))
              .toList();
        }

        return ApplicationsList(
          applications: applications,
          isLoading: isLoading,
          error: errorMessage,
          onRefresh: () {
            context.read<JobBloc>().add(LoadApplications(page: 1, limit: 10));
          },
          onApplicationUpdate: (updatedJob) {
            // Update the applications list in the parent
            final updatedApplications = applications.map((app) {
              if (app.id == updatedJob.id) {
                return updatedJob;
              }
              return app;
            }).toList();

            // Convert back to JobModel list for parent callback
            final updatedJobModels = updatedApplications
                .map((job) => JobModel(
                      id: job.id,
                      title: job.title,
                      category: job.category,
                      description: job.description,
                      address: job.address,
                      minBudget: job.minBudget,
                      maxBudget: job.maxBudget,
                      duration: job.duration,
                      applied: job.applied,
                      thumbnailUrl: job.thumbnailUrl,
                      status: job.status,
                      agreement: job.agreement,
                      changeRequest: job.changeRequest,
                      materials: job.materials,
                    ))
                .toList();

            widget.onApplicationUpdate(updatedJobModels);
          },
        );
      },
    );
  }
}

/// Separate widget for Job Invite tab - displays collaboration invites
class JobInviteTabContent extends StatefulWidget {
  const JobInviteTabContent({
    required this.onJobTap,
    super.key,
  });

  final Function(Job) onJobTap;

  @override
  State<JobInviteTabContent> createState() => _JobInviteTabContentState();
}

class _JobInviteTabContentState extends State<JobInviteTabContent> {
  @override
  void initState() {
    super.initState();
    // Load pending collaboration invites when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final state = context.read<CollaborationBloc>().state;
        if (state is! CollaborationsLoaded) {
          context.read<CollaborationBloc>().add(
                LoadCollaborationsEvent(
                  status: CollaborationStatus.pending,
                  role: CollaborationRole.collaborator,
                  page: 1,
                  pageSize: 10,
                ),
              );
        }
      } catch (_) {
        // CollaborationBloc not available, ignore
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollaborationBloc, CollaborationState>(
      listener: (context, state) {
        if (state is CollaborationResponseSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.action == CollaborationAction.accept
                    ? 'Collaboration accepted successfully!'
                    : 'Collaboration declined',
              ),
            ),
          );
          // Refresh the list
          context.read<CollaborationBloc>().add(
                RefreshCollaborationsEvent(
                  status: CollaborationStatus.pending,
                  role: CollaborationRole.collaborator,
                ),
              );
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CollaborationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.danger,
                  ),
                  AppSpacing.spaceLG,
                  Text(
                    'Failed to load collaboration invites',
                    style: TextStyle(
                      color: AppColors.darkBlue.withValues(alpha: 0.7),
                      fontSize: 16,
                    ),
                  ),
                  AppSpacing.spaceSM,
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: () {
                      context.read<CollaborationBloc>().add(
                            LoadCollaborationsEvent(
                              status: CollaborationStatus.pending,
                              role: CollaborationRole.collaborator,
                              page: 1,
                              pageSize: 10,
                            ),
                          );
                    },
                  ),
                ],
              ),
            );
          }

          if (state is CollaborationsLoaded) {
            final invites = state.collaborations;

            if (invites.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.mail_outline,
                title: 'No Collaboration Invites',
                subtitle:
                    'Collaboration invitations from other artisans will appear here',
              );
            }

            // Performance: Use ListView.builder for lazy loading with optimizations
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CollaborationBloc>().add(
                      RefreshCollaborationsEvent(
                        status: CollaborationStatus.pending,
                        role: CollaborationRole.collaborator,
                      ),
                    );
              },
              child: ListView.builder(
                itemCount: invites.length,
                padding: AppSpacing.verticalSM,
                physics:
                    const ClampingScrollPhysics(), // Prevents overscroll within nested scroll
                cacheExtent: 200, // Cache items offscreen for smooth scrolling
                addAutomaticKeepAlives:
                    true, // Keep list items alive for better performance
                addRepaintBoundaries: true, // Isolate repaints for performance
                itemBuilder: (context, index) {
                  final collaboration = invites[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CollaborationCard(
                      collaboration: collaboration,
                      onAccept: () => _handleAccept(collaboration),
                      onReject: () => _handleReject(collaboration),
                      onTap: () async {
                        // Navigate to collaboration details page
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollaborationDetailsPage(
                              collaboration: collaboration,
                            ),
                          ),
                        );
                        // Refresh list if collaboration was accepted/rejected
                        if (result == true && context.mounted) {
                          context.read<CollaborationBloc>().add(
                                RefreshCollaborationsEvent(
                                  status: CollaborationStatus.pending,
                                  role: CollaborationRole.collaborator,
                                ),
                              );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

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
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.danger),
                  AppSpacing.spaceLG,
                  Text(state.message,
                      style: TextStyle(
                          color: AppColors.darkBlue.withValues(alpha: 0.7),
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
                  const ClampingScrollPhysics(), // Prevents overscroll within nested scroll
              cacheExtent: 200, // Cache items offscreen for smooth scrolling
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

/// Reusable empty state widget following DRY principle
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.darkBlue.withValues(alpha: 0.3),
          ),
          AppSpacing.spaceLG,
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          AppSpacing.spaceSM,
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkBlue.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
