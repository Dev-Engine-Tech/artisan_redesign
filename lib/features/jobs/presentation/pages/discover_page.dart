import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_job_card.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/filter_page.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/home/presentation/widgets/banner_carousel.dart';
import 'package:artisans_circle/features/home/presentation/widgets/enhanced_banner_carousel.dart';
import 'package:artisans_circle/core/models/banner_model.dart' as api;
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_search_bar.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/discover_tab_view.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/utils/filtering_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_categories_remote_data_source.dart';
import 'package:get_it/get_it.dart';

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
  // Active filter query params derived from filter modal selections
  String? _postedDateFilter;
  String? _workModeFilter;
  String? _budgetTypeFilter;
  String? _durationFilter;
  String? _categoryFilter;
  final Set<String> _categoryIds = {};
  Map<String, String> _categoryNameById = {};
  String? _postedDateLabel;
  String? _workModeLabel;
  String? _budgetTypeLabel;
  String? _durationLabel;
  String? _stateFilter; // State id for API
  String? _stateName; // Human-readable for chips
  List<String> _lgasList = [];
  String? _lgasCsv; // CSV for API

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
    // Load saved filters/search and then fetch jobs
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _initializeFromStorage());
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Blocs created by factory should be closed when page is disposed.
    bloc.close();
    super.dispose();
  }

  Future<void> _initializeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawFilters = prefs.getString('discover_filters');
      final savedSearch = prefs.getString('discover_search') ?? '';
      String? categoriesCsv;
      String? postedDateApi;
      String? workModeApi;
      String? budgetTypeApi;
      String? durationApi;
      String? stateIdParam;
      List<String> lgaNames = [];
      String? lgaIdsCsv;

      if (rawFilters != null) {
        final filters = jsonDecode(rawFilters) as Map<String, dynamic>;
        // categories as list -> csv
        if (filters['categories'] is List) {
          final ids =
              (filters['categories'] as List).map((e) => e.toString()).toList();
          if (ids.isNotEmpty) categoriesCsv = ids.join(',');
          _categoryIds
            ..clear()
            ..addAll(ids);
          await _ensureCategoryNamesLoaded();
        } else if (filters['category'] is String) {
          categoriesCsv = filters['category'] as String?;
        }

        String labelFromMap(Map<dynamic, dynamic> m) {
          for (final entry in m.entries) {
            if (entry.value == true) return entry.key.toString();
          }
          return '';
        }

        if (filters['postedDate'] is Map) {
          final label = labelFromMap(filters['postedDate']);
          if (label.isNotEmpty) {
            postedDateApi = filteringValue(FilteringField.postedDate, [label]);
            _postedDateLabel = label;
          }
        }
        if (filters['workspace'] is Map) {
          final label = labelFromMap(filters['workspace']);
          if (label.isNotEmpty) {
            workModeApi = filteringValue(FilteringField.workMode, [label]);
            _workModeLabel = label;
          }
        }
        if (filters['budget'] is Map) {
          final label = labelFromMap(filters['budget']);
          if (label.isNotEmpty) {
            budgetTypeApi = filteringValue(FilteringField.budgetType, [label]);
            _budgetTypeLabel = label;
          }
        }
        if (filters['duration'] is Map) {
          final label = labelFromMap(filters['duration']);
          if (label.isNotEmpty) {
            durationApi = filteringValue(FilteringField.duration, [label]);
            _durationLabel = label;
          }
        }
        if (filters['stateId'] != null) {
          stateIdParam = filters['stateId'].toString();
        }
        if (filters['state'] is String &&
            (filters['state'] as String).isNotEmpty) {
          _stateName = filters['state'] as String;
        }
        if (filters['lgas'] is List) {
          lgaNames =
              (filters['lgas'] as List).map((e) => e.toString()).toList();
        }
        if (filters['lgaIds'] is List &&
            (filters['lgaIds'] as List).isNotEmpty) {
          final ids =
              (filters['lgaIds'] as List).map((e) => e.toString()).toList();
          lgaIdsCsv = ids.join(',');
        }
      }

      setState(() {
        _searchController.text = savedSearch;
        _categoryFilter = categoriesCsv;
        _postedDateFilter = postedDateApi;
        _workModeFilter = workModeApi;
        _budgetTypeFilter = budgetTypeApi;
        _durationFilter = durationApi;
        _stateFilter = stateIdParam;
        _lgasList = lgaNames;
        _lgasCsv = lgaIdsCsv;

        int count = 0;
        if (_categoryFilter != null && _categoryFilter!.isNotEmpty) count++;
        if (_postedDateFilter != null && _postedDateFilter!.isNotEmpty) count++;
        if (_workModeFilter != null && _workModeFilter!.isNotEmpty) count++;
        if (_budgetTypeFilter != null && _budgetTypeFilter!.isNotEmpty) count++;
        if (_durationFilter != null && _durationFilter!.isNotEmpty) count++;
        if (_stateFilter != null && _stateFilter!.isNotEmpty) count++;
        if (_lgasCsv != null && _lgasCsv!.isNotEmpty) count++;
        _filterCount = count;
      });

      // Initial load
      _loadTabContent(_currentTabIndex);
    } catch (_) {
      // ✅ PERFORMANCE FIX: Fallback load on error is intentional
      bloc.add(LoadJobs());
    }
  }

  Future<void> _ensureCategoryNamesLoaded() async {
    if (_categoryNameById.isNotEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('job_categories_cache_data');
      if (cached != null) {
        final list = jsonDecode(cached) as List;
        _categoryNameById = {
          for (final e in list)
            (e['id'] ?? e['ID'] ?? e['Id']).toString():
                (e['name'] ?? e['Name'] ?? '').toString()
        };
      }
      if (_categoryNameById.isEmpty) {
        final ds = GetIt.I<CatalogCategoriesRemoteDataSource>();
        final groups = await ds.fetchCategories();
        final subs = groups.expand((g) => g.subcategories).toList();
        _categoryNameById = {
          for (final e in (subs.isNotEmpty
              ? subs
              : groups.map((g) => CategoryItem(g.id, g.name))))
            e.id: e.name,
        };
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JobBloc>.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: widget.showHeader
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.softPink,
                        borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon:
                          const Icon(Icons.chevron_left, color: Colors.black54),
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
              )
            : null,
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
      EnhancedBannerCarousel(
        category: api.BannerCategory.job,
        height: 110,
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

      // Active filters chips row
      _buildActiveFiltersChips(),

      const SizedBox(height: 8),
    ];
  }

  Widget _buildActiveFiltersChips() {
    final chips = <Widget>[];

    // Category chips
    if (_categoryIds.isNotEmpty) {
      for (final id in _categoryIds) {
        final name = _categoryNameById[id] ?? 'Category';
        chips.add(_filterChip(name, () => _removeCategory(id)));
      }
    }

    // Simple label chips
    if (_postedDateLabel != null) {
      chips.add(_filterChip(_postedDateLabel!, _clearPostedDate));
    }
    if (_workModeLabel != null) {
      chips.add(_filterChip(_workModeLabel!, _clearWorkMode));
    }
    if (_budgetTypeLabel != null) {
      chips.add(_filterChip(_budgetTypeLabel!, _clearBudgetType));
    }
    if (_durationLabel != null) {
      chips.add(_filterChip(_durationLabel!, _clearDuration));
    }
    if (_stateFilter != null && _stateFilter!.isNotEmpty) {
      chips.add(_filterChip(_stateName ?? 'State', _clearState));
    }
    if (_lgasList.isNotEmpty) {
      final n = _lgasList.length;
      chips.add(_filterChip('LGA ($n)', _clearLgas));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    // Add Clear All action
    chips.add(
      GestureDetector(
        onTap: _clearAllFilters,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.subtleBorder),
          ),
          child: const Text(
            'Clear all',
            style: TextStyle(fontSize: 12, color: AppColors.brownHeader),
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: chips,
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDelete,
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.subtleBorder),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Future<void> _updatePersistedFilters(
      void Function(Map<String, dynamic>) mutate) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('discover_filters');
    final map = raw != null
        ? (jsonDecode(raw) as Map<String, dynamic>)
        : <String, dynamic>{};
    mutate(map);
    await prefs.setString('discover_filters', jsonEncode(map));
  }

  void _removeCategory(String id) {
    setState(() {
      _categoryIds.remove(id);
      _categoryFilter = _categoryIds.isEmpty ? null : _categoryIds.join(',');
      _recountFilters();
    });
    _updatePersistedFilters((m) {
      final list =
          (m['categories'] as List?)?.map((e) => e.toString()).toList() ?? [];
      list.remove(id);
      m['categories'] = list;
    });
    _triggerFetch();
  }

  void _clearPostedDate() {
    setState(() {
      _postedDateFilter = null;
      _postedDateLabel = null;
      _recountFilters();
    });
    _updatePersistedFilters((m) => m['postedDate'] = {});
    _triggerFetch();
  }

  void _clearWorkMode() {
    setState(() {
      _workModeFilter = null;
      _workModeLabel = null;
      _recountFilters();
    });
    _updatePersistedFilters((m) => m['workspace'] = {});
    _triggerFetch();
  }

  void _clearBudgetType() {
    setState(() {
      _budgetTypeFilter = null;
      _budgetTypeLabel = null;
      _recountFilters();
    });
    _updatePersistedFilters((m) => m['budget'] = {});
    _triggerFetch();
  }

  void _clearDuration() {
    setState(() {
      _durationFilter = null;
      _durationLabel = null;
      _recountFilters();
    });
    _updatePersistedFilters((m) => m['duration'] = {});
    _triggerFetch();
  }

  void _clearState() {
    setState(() {
      _stateFilter = null;
      _stateName = null;
      _recountFilters();
    });
    _updatePersistedFilters((m) {
      m['state'] = '';
      m['stateId'] = null;
    });
    _triggerFetch();
  }

  void _clearLgas() {
    setState(() {
      _lgasList.clear();
      _lgasCsv = null;
      _recountFilters();
    });
    _updatePersistedFilters((m) => m['lgas'] = []);
    _triggerFetch();
  }

  void _clearAllFilters() {
    setState(() {
      _categoryIds.clear();
      _categoryFilter = null;
      _postedDateFilter = null;
      _workModeFilter = null;
      _budgetTypeFilter = null;
      _durationFilter = null;
      _postedDateLabel = null;
      _workModeLabel = null;
      _budgetTypeLabel = null;
      _durationLabel = null;
      _stateFilter = null;
      _lgasList.clear();
      _lgasCsv = null;
      _recountFilters();
    });
    _updatePersistedFilters((m) {
      m['categories'] = [];
      m['postedDate'] = {};
      m['workspace'] = {};
      m['budget'] = {};
      m['duration'] = {};
      m['state'] = '';
      m['lgas'] = [];
    });
    _triggerFetch();
  }

  void _recountFilters() {
    int count = 0;
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) count++;
    if (_postedDateFilter != null && _postedDateFilter!.isNotEmpty) count++;
    if (_workModeFilter != null && _workModeFilter!.isNotEmpty) count++;
    if (_budgetTypeFilter != null && _budgetTypeFilter!.isNotEmpty) count++;
    if (_durationFilter != null && _durationFilter!.isNotEmpty) count++;
    if (_stateFilter != null && _stateFilter!.isNotEmpty) count++;
    if (_lgasCsv != null && _lgasCsv!.isNotEmpty) count++;
    _filterCount = count;
  }

  void _triggerFetch() {
    bloc.add(LoadJobs(
      page: 1,
      limit: 20,
      search: _searchController.text,
      match: false,
      saved: _currentTabIndex == 1,
      postedDate: _postedDateFilter,
      workMode: _workModeFilter,
      budgetType: _budgetTypeFilter,
      duration: _durationFilter,
      category: _categoryFilter,
      state: _stateFilter,
      lgas: _lgasCsv,
    ));
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
            // ✅ PERFORMANCE FIX: Force reload on error retry is intentional
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
              // ✅ PERFORMANCE FIX: Force refresh on pull-to-refresh is intentional
              bloc.add(LoadJobs(
                page: 1,
                limit: 20,
                search: _searchController.text,
                match: false,
                saved: _currentTabIndex == 1,
                postedDate: _postedDateFilter,
                workMode: _workModeFilter,
                budgetType: _budgetTypeFilter,
                duration: _durationFilter,
                category: _categoryFilter,
              ));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return DiscoverJobCard(
                  job: job,
                  onTap: () => _navigateToJobDetails(job),
                  showSaveButton:
                      _currentTabIndex != 1, // Hide on saved jobs tab
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
        return allJobs;
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
    // ✅ PERFORMANCE FIX: Reload with new search query is intentional
    // Use server-side search to mirror upstream app
    bloc.add(LoadJobs(
      page: 1,
      limit: 20,
      search: query,
      match: false,
      saved: _currentTabIndex == 1,
      postedDate: _postedDateFilter,
      workMode: _workModeFilter,
      budgetType: _budgetTypeFilter,
      duration: _durationFilter,
      category: _categoryFilter,
      state: _stateName ?? _stateFilter, // prefer name for compatibility
      lgas: _lgasCsv,
    ));
    // Persist search
    SharedPreferences.getInstance()
        .then((p) => p.setString('discover_search', query));
  }

  void _clearSearch() {
    // ✅ PERFORMANCE FIX: Reload after clearing search is intentional
    _searchController.clear();
    bloc.add(LoadJobs(
      page: 1,
      limit: 20,
      search: '',
      match: false,
      saved: _currentTabIndex == 1,
      postedDate: _postedDateFilter,
      workMode: _workModeFilter,
      budgetType: _budgetTypeFilter,
      duration: _durationFilter,
      category: _categoryFilter,
      state: _stateName ?? _stateFilter,
      lgas: _lgasCsv,
    ));
    SharedPreferences.getInstance().then((p) => p.remove('discover_search'));
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
      // Expecting the shape from FilterPage
      // {'categories': List<String>, 'postedDate': Map<String,bool>, 'workspace': Map<String,bool>,
      //  'state': String?, 'stateId': int?, 'lgas': List<String>, 'lgaIds': List<int>, 'budget': Map<String,bool>, 'duration': Map<String,bool>}
      String? categoriesCsv;
      String? postedDateApi;
      String? workModeApi;
      String? budgetTypeApi;
      String? durationApi;
      String? stateParam; // state id string
      String? stateName;
      List<String> selectedLgaNames = [];
      String? lgaIdsCsv;

      try {
        // categories (list of ids) -> first id for API
        if (filters['categories'] is List &&
            (filters['categories'] as List).isNotEmpty) {
          final ids =
              (filters['categories'] as List).map((e) => e.toString()).toList();
          categoriesCsv = ids.join(',');
          _categoryIds
            ..clear()
            ..addAll(ids);
          _ensureCategoryNamesLoaded();
        }

        String firstTrueKey(Map<dynamic, dynamic> m) {
          for (final entry in m.entries) {
            if (entry.value == true) return entry.key.toString();
          }
          return '';
        }

        final postedDateLabel = filters['postedDate'] is Map
            ? firstTrueKey(filters['postedDate'])
            : '';
        final workModeLabel = filters['workspace'] is Map
            ? firstTrueKey(filters['workspace'])
            : '';
        final budgetLabel =
            filters['budget'] is Map ? firstTrueKey(filters['budget']) : '';
        final durationLabel =
            filters['duration'] is Map ? firstTrueKey(filters['duration']) : '';

        postedDateApi = postedDateLabel.isNotEmpty
            ? filteringValue(FilteringField.postedDate, [postedDateLabel])
            : null;
        workModeApi = workModeLabel.isNotEmpty
            ? filteringValue(FilteringField.workMode, [workModeLabel])
            : null;
        budgetTypeApi = budgetLabel.isNotEmpty
            ? filteringValue(FilteringField.budgetType, [budgetLabel])
            : null;
        durationApi = durationLabel.isNotEmpty
            ? filteringValue(FilteringField.duration, [durationLabel])
            : null;

        // Optional state/LGAs
        if (filters['stateId'] != null) {
          stateParam = filters['stateId'].toString();
        }
        if (filters['state'] is String &&
            (filters['state'] as String).isNotEmpty) {
          stateName = filters['state'] as String;
        }
        if (filters['lgas'] is List) {
          selectedLgaNames =
              (filters['lgas'] as List).map((e) => e.toString()).toList();
        }
        if (filters['lgaIds'] is List &&
            (filters['lgaIds'] as List).isNotEmpty) {
          final ids =
              (filters['lgaIds'] as List).map((e) => e.toString()).toList();
          lgaIdsCsv = ids.join(',');
        }

        setState(() {
          _categoryFilter = categoriesCsv;
          _postedDateFilter = postedDateApi;
          _workModeFilter = workModeApi;
          _budgetTypeFilter = budgetTypeApi;
          _durationFilter = durationApi;
          _postedDateLabel =
              postedDateLabel.isNotEmpty ? postedDateLabel : null;
          _workModeLabel = workModeLabel.isNotEmpty ? workModeLabel : null;
          _budgetTypeLabel = budgetLabel.isNotEmpty ? budgetLabel : null;
          _durationLabel = durationLabel.isNotEmpty ? durationLabel : null;
          _stateFilter = stateParam;
          _stateName = stateName;
          _lgasList = selectedLgaNames; // names for chips
          _lgasCsv = lgaIdsCsv; // ids for API

          // Count active filters like in the upstream app
          int count = 0;
          if (_categoryFilter != null && _categoryFilter!.isNotEmpty) count++;
          if (_postedDateFilter != null && _postedDateFilter!.isNotEmpty)
            count++;
          if (_workModeFilter != null && _workModeFilter!.isNotEmpty) count++;
          if (_budgetTypeFilter != null && _budgetTypeFilter!.isNotEmpty)
            count++;
          if (_durationFilter != null && _durationFilter!.isNotEmpty) count++;
          if (_stateFilter != null && _stateFilter!.isNotEmpty) count++;
          if (_lgasCsv != null && _lgasCsv!.isNotEmpty) count++;
          _filterCount = count;
        });

        // Persist filters
        SharedPreferences.getInstance()
            .then((p) => p.setString('discover_filters', jsonEncode(filters)));

        // ✅ PERFORMANCE FIX: Reload with new filters is intentional
        // Fetch with new filters
        bloc.add(LoadJobs(
          page: 1,
          limit: 20,
          search: _searchController.text,
          match: false,
          saved: _currentTabIndex == 1,
          postedDate: _postedDateFilter,
          workMode: _workModeFilter,
          budgetType: _budgetTypeFilter,
          duration: _durationFilter,
          category: _categoryFilter,
          state: _stateFilter,
          lgas: _lgasCsv,
        ));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filters applied')),
        );
      } catch (_) {
        // Best-effort; ignore mapping errors
      }
    }
  }

  void _loadTabContent(int index) {
    // ✅ PERFORMANCE FIX: Check if data is already loaded before fetching
    final currentState = bloc.state;
    if (currentState is JobStateLoaded ||
        currentState is JobStateAppliedSuccess) {
      // Data already loaded, no need to reload unless filters changed
      return;
    }

    switch (index) {
      case 0: // Best Matches
        bloc.add(LoadJobs(
          page: 1,
          limit: 20,
          search: _searchController.text,
          match: false,
          saved: false,
          postedDate: _postedDateFilter,
          workMode: _workModeFilter,
          budgetType: _budgetTypeFilter,
          duration: _durationFilter,
          category: _categoryFilter,
          state: _stateName ?? _stateFilter,
          lgas: _lgasCsv,
        ));
        break;
      case 1: // Saved Jobs
        bloc.add(LoadJobs(
          page: 1,
          limit: 20,
          search: _searchController.text,
          match: false,
          saved: true,
          postedDate: _postedDateFilter,
          workMode: _workModeFilter,
          budgetType: _budgetTypeFilter,
          duration: _durationFilter,
          category: _categoryFilter,
          state: _stateName ?? _stateFilter,
          lgas: _lgasCsv,
        ));
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
