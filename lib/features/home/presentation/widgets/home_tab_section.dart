import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/applications_list.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_request.dart';
import 'package:artisans_circle/core/theme.dart';

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
  }) {
    print('DEBUG: HomeTabSection - Constructor called with ${applications.length} applications');
  }

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
    
    print('DEBUG: HomeTabSection - Building with selected index: $_selectedIndex');
    
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
    print('DEBUG: HomeTabSection - _getSelectedTabContent called with index: $_selectedIndex');
    switch (_selectedIndex) {
      case 0:
        print('DEBUG: HomeTabSection - Returning JobsTabContent');
        return JobsTabContent(onJobTap: widget.onJobTap);
      case 1:
        print('DEBUG: HomeTabSection - Returning ApplicationsTabContent with ${widget.applications.length} applications');
        return ApplicationsTabContent(
          applications: widget.applications,
          onJobTap: widget.onJobTap,
          onApplicationUpdate: widget.onApplicationUpdate,
        );
      case 2:
        print('DEBUG: HomeTabSection - Returning JobInviteTabContent');
        return JobInviteTabContent(onJobTap: widget.onJobTap);
      case 3:
        print('DEBUG: HomeTabSection - Returning OrdersTabContent');
        return OrdersTabContent(onRequestTap: widget.onRequestTap);
      default:
        print('DEBUG: HomeTabSection - Returning default JobsTabContent');
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
        print('DEBUG: JobsTabContent - Current state: ${state.runtimeType}');
        print('DEBUG: JobsTabContent - Widget building with state: $state');
        
        if (state is JobStateLoading) {
          print('DEBUG: JobsTabContent - Showing loading indicator');
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is JobStateError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
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
          final jobs = state.jobs;

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
        print('DEBUG: ApplicationsTabContent - Current state: ${state.runtimeType}');
        print('DEBUG: ApplicationsTabContent - Widget building with state: $state');
        
        bool isLoading = state is JobStateLoading;
        String? errorMessage;
        List<Job> applications = [];
        
        if (state is JobStateError) {
          errorMessage = state.message;
        } else if (state is JobStateAppliedSuccess) {
          // Convert JobModel list to Job list for the ApplicationsList widget
          applications = state.jobs.map((jobModel) => Job(
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
          )).toList();
          
          print('DEBUG: ApplicationsTabContent - JobStateAppliedSuccess received with ${applications.length} applications');
          print('DEBUG: ApplicationsTabContent - First application: ${applications.isNotEmpty ? applications.first.title : 'none'}');
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
            final updatedJobModels = updatedApplications.map((job) => JobModel(
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
            )).toList();
            
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
        description: 'You have been invited to quote for this job. Client is looking for professional electrical work.',
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
  List<CatalogRequest> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // For now, let's show sample data based on the API response structure we saw
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Sample orders data based on the actual API response
      final orders = [
        CatalogRequest(
          id: '11',
          title: 'FFMPEG Material UI',
          description: 'This app leverages the power of ffmpeg, a leading multimedia framework, and the flexibility of Flutter to provide a seamless and efficient user experience for screen recording.',
          status: 'PENDING',
          clientName: 'Mobile Development Client',
          catalogPictures: ['https://d3gzzv4si5l8ga.cloudfront.net/catalog-pictures/image_picker_BE846886-6CFB-4790-925F-2556A4E8804B-67427-0000421C3454EC0C.jpg'],
          materials: [],
          priceMin: '700000.00',
          priceMax: '800000.00',
        ),
        CatalogRequest(
          id: '6',
          title: 'DeepAR Flutter Plus',
          description: 'An AR SDK for loading effects like filters, mask, virtual try-on and anything augmented reality.',
          status: 'IN_PROGRESS',
          clientName: 'AR Development Client',
          catalogPictures: ['https://d3gzzv4si5l8ga.cloudfront.net/catalog-pictures/deepar_plus.png'],
          materials: [],
          priceMin: '800000.00',
          priceMax: '1200000.00',
        ),
      ];

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: AppColors.darkBlue.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'No Orders',
        subtitle: 'Catalog requests will appear here',
      );
    }

    // Performance: Use ListView.builder
    return ListView.builder(
      itemCount: _orders.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final request = _orders[index];
        // Convert CatalogRequest to Job for consistent UI
        final jobFromRequest = Job(
          id: request.id,
          title: request.title,
          category: 'Catalog Request',
          description: request.description,
          address: request.clientName ?? 'Client',
          minBudget: (double.tryParse(request.priceMin ?? '0') ?? 0).toInt(),
          maxBudget: (double.tryParse(request.priceMax ?? '0') ?? 0).toInt(),
          duration: request.status?.toUpperCase() ?? 'PENDING',
          applied: false,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: JobCard(
            job: jobFromRequest,
            onTap: () => widget.onRequestTap(request),
          ),
        );
      },
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
