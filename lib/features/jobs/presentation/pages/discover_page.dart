import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_job_card.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/filter_page.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/home/presentation/widgets/banner_carousel.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_search_bar.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_tab_view.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

class DiscoverPage extends StatefulWidget {
  final bool showHeader;
  const DiscoverPage({super.key, this.showHeader = true});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late final JobBloc bloc;
  late final TextEditingController _searchController;
  int _currentTabIndex = 0;
  int _filterCount = 0;
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  
  final List<DiscoverTab> _tabs = [
    const DiscoverTab(label: 'Best Matches', key: 'matches'),
    const DiscoverTab(label: 'Saved Jobs', key: 'saved'),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Use GetIt to create a fresh bloc (registered as factory)
    bloc = getIt<JobBloc>();
    // Load jobs when page becomes visible to avoid race condition with HomePage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        bloc.add(LoadJobs());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Blocs created by factory should be closed when page is disposed.
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JobBloc>.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: widget.showHeader ? AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
                onPressed: () {
                  // In shell the back may not pop; keep as placeholder
                },
              ),
            ),
          ),
          title: const Text('Discover',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600)),
          centerTitle: false,
          actions: const [],
        ) : null,
        body: SafeArea(
          child: Column(
            children: [
              // Header widgets
              if (widget.showHeader) ..._buildHeader(),
              
              // Tab navigation and content
              Expanded(
                child: DiscoverTabView(
                  tabs: _tabs,
                  initialIndex: _currentTabIndex,
                  onTabChanged: (index) {
                    setState(() {
                      _currentTabIndex = index;
                    });
                    _loadTabContent(index);
                  },
                  contentBuilder: (index) => _buildTabContent(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildHeader() {
    return [
      const SizedBox(height: 8),
      
      // Banner carousel
      BannerCarousel(
        banners: DefaultBanners.defaultBanners,
        height: 140,
        autoPlay: true,
      ),
      
      const SizedBox(height: 16),
      
      // Search bar with filter
      DiscoverSearchBar(
        controller: _searchController,
        onChanged: _handleSearch,
        onSubmitted: _handleSearch,
        onFilterTap: _showFilterModal,
        onClearTap: _clearSearch,
        filterCount: _filterCount,
        showFilterBadge: _filterCount > 0,
      ),
      
      const SizedBox(height: 8),
    ];
  }

  Widget _buildTabContent(int index) {
    return BlocBuilder<JobBloc, JobState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is JobStateLoading || state is JobStateInitial) {
          return const DiscoverTabContent(
            isLoading: true,
            child: SizedBox.shrink(),
          );
        }

        if (state is JobStateError) {
          return DiscoverTabContent(
            error: state.message,
            onRetry: () => bloc.add(LoadJobs()),
            child: const SizedBox.shrink(),
          );
        }

        final jobs = _getJobsForTab(index, state);
        
        if (jobs.isEmpty) {
          return DiscoverTabContent(
            child: _buildEmptyState(index),
          );
        }

        return DiscoverTabContent(
          child: RefreshIndicator(
            onRefresh: () async {
              bloc.add(RefreshJobs());
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return DiscoverJobCard(
                  job: job,
                  onTap: () => _navigateToJobDetails(job),
                  showSaveButton: _currentTabIndex != 1, // Hide on saved jobs tab
                  onSave: () => _toggleSaveJob(job),
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<Job> _getJobsForTab(int index, JobState state) {
    List<Job> allJobs = [];
    
    if (state is JobStateLoaded) {
      allJobs = state.jobs;
      _allJobs = allJobs; // Store for search
    } else if (state is JobStateAppliedSuccess) {
      allJobs = state.jobs;
      _allJobs = allJobs; // Store for search
    }

    switch (index) {
      case 0: // Best Matches
        return _filteredJobs.isNotEmpty ? _filteredJobs : allJobs;
      case 1: // Saved Jobs
        return allJobs.where((job) => job.saved).toList();
      default:
        return allJobs;
    }
  }

  Widget _buildEmptyState(int tabIndex) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 0:
        title = 'No Jobs Found';
        subtitle = _searchController.text.isNotEmpty
            ? 'No jobs match your search criteria'
            : 'No job matches available right now';
        icon = Icons.work_outline;
        break;
      case 1:
        title = 'No Saved Jobs';
        subtitle = 'Start saving jobs to see them here';
        icon = Icons.bookmark_outline;
        break;
      default:
        title = 'No Jobs';
        subtitle = 'No jobs available';
        icon = Icons.work_outline;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    // Implement search logic
    setState(() {
      if (query.isEmpty) {
        _filteredJobs = [];
      } else {
        _filteredJobs = _allJobs.where((job) {
          return job.title.toLowerCase().contains(query.toLowerCase()) ||
                 job.category.toLowerCase().contains(query.toLowerCase()) ||
                 job.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredJobs = [];
    });
  }

  Future<void> _showFilterModal() async {
    final filters = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const FilterPage(),
        ),
      ),
    );
    
    if (filters != null && mounted) {
      setState(() {
        _filterCount = 3; // Mock filter count
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filters applied')),
      );
    }
  }

  void _loadTabContent(int index) {
    switch (index) {
      case 0: // Best Matches
        bloc.add(LoadJobs());
        break;
      case 1: // Saved Jobs
        // Load saved jobs
        break;
    }
  }

  void _navigateToJobDetails(Job job) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: JobDetailsPage(job: job),
      ),
    ));
  }

  void _toggleSaveJob(Job job) {
    // Implement save/unsave job logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(job.saved ? 'Job removed from saved' : 'Job saved'),
      ),
    );
  }
}