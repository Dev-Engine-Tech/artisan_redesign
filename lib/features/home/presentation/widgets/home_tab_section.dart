import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/data/models/job_model.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_request.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/home/presentation/widgets/tabs/jobs_tab_content.dart';
import 'package:artisans_circle/features/home/presentation/widgets/tabs/applications_tab_content.dart';
import 'package:artisans_circle/features/home/presentation/widgets/tabs/job_invite_tab_content.dart';
import 'package:artisans_circle/features/home/presentation/widgets/tabs/orders_tab_content.dart';

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

    // Load jobs data when widget is first created (Jobs tab is selected by default)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadJobsIfNeeded();
      }
    });
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

      // Load jobs data when Jobs tab is selected
      if (_selectedIndex == 0) {
        _loadJobsIfNeeded();
      }
    }
  }

  /// Load jobs data if not already loaded
  void _loadJobsIfNeeded() {
    try {
      final jobBloc = context.read<JobBloc>();
      final state = jobBloc.state;

      // Only load if not already loaded or loading
      if (state is! JobStateLoaded && state is! JobStateLoading) {
        jobBloc.add(LoadJobs(page: 1, limit: 10));
      }
    } catch (e) {
      debugPrint('❌ Failed to load jobs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: context.softPeachColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colorScheme.surface.withValues(alpha: 0.0),
        labelColor: context.darkBlueColor,
        unselectedLabelColor: context.darkBlueColor.withValues(alpha: 0.6),
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
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
