import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/applications_list.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_request.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/catalog/presentation/bloc/catalog_requests_bloc.dart';

/// Performance-optimized tab section following SOLID principles
/// Single Responsibility: Manages tab display and content
/// Open/Closed: Extensible for new tab types without modification
/// Dependency Inversion: Depends on abstractions (callbacks) not concrete implementations
class HomeTabSection extends StatefulWidget {
  HomeTabSection({
    super.key,
    required this.onJobTap,
    required this.onRequestTap,
    required this.applications,
    required this.onApplicationUpdate,
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
        const SizedBox(height: 16),
        _buildTabContent(),
      ],
    );
  }

  /// Builds performance-optimized tab bar with const widgets
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softPeach,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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

  /// Builds tab content with simple conditional rendering
  Widget _buildTabContent() {
    return SizedBox(
      height: 400, // Fixed height for performance
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
    super.key,
    required this.onJobTap,
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
                const SizedBox(height: 16),
                Text(
                  'Failed to load jobs',
                  style: TextStyle(
                    color: AppColors.darkBlue.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<JobBloc>().add(LoadJobs());
                  },
                  child: const Text('Retry'),
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

          // Performance: Use ListView.builder for lazy loading
          return ListView.builder(
            itemCount: jobs.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
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

        return const SizedBox.shrink();
      },
    );
  }
}

/// Separate widget for Applications tab
class ApplicationsTabContent extends StatefulWidget {
  const ApplicationsTabContent({
    super.key,
    required this.applications,
    required this.onJobTap,
    required this.onApplicationUpdate,
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

/// Separate widget for Job Invite tab
class JobInviteTabContent extends StatelessWidget {
  const JobInviteTabContent({
    super.key,
    required this.onJobTap,
  });

  final Function(Job) onJobTap;

  List<Job> _getSampleInvites() {
    return List.generate(
      3,
      (i) => Job(
        id: 'invite_$i',
        title: 'Job Invite: Electrical Home Wiring',
        category: 'Electrical Engineering',
        description:
            'You have been invited to quote for this job. Client is looking for professional electrical work.',
        address: 'Client location - Lagos',
        minBudget: 200000,
        maxBudget: 300000,
        duration: 'Less than a month',
        applied: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invites = _getSampleInvites();

    if (invites.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.mail_outline,
        title: 'No Job Invites',
        subtitle: 'Job invitations from clients will appear here',
      );
    }

    // Performance: Use ListView.builder for large lists
    return ListView.builder(
      itemCount: invites.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final job = invites[index];
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
}

/// Separate widget for Orders tab
class OrdersTabContent extends StatefulWidget {
  const OrdersTabContent({
    super.key,
    required this.onRequestTap,
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
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: TextStyle(
                          color: AppColors.darkBlue.withValues(alpha: 0.7),
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context
                        .read<CatalogRequestsBloc>()
                        .add(LoadCatalogRequests()),
                    child: const Text('Retry'),
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
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Reject')),
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
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
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
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
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
