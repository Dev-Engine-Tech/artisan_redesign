import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../catalog/data/datasources/catalog_categories_remote_data_source.dart';

/// Manager for discover page filter state and persistence
///
/// Handles:
/// - Loading/saving filters from SharedPreferences
/// - Building API query parameters from filter selections
/// - Managing category name lookups
class DiscoverFilterManager {
  // Filter state
  String? postedDateFilter;
  String? workModeFilter;
  String? budgetTypeFilter;
  String? durationFilter;
  String? categoryFilter;
  final Set<String> categoryIds = {};
  Map<String, String> categoryNameById = {};

  String? postedDateLabel;
  String? workModeLabel;
  String? budgetTypeLabel;
  String? durationLabel;
  String? stateFilter;
  String? stateName;
  List<String> lgasList = [];
  String? lgasCsv;

  final CatalogCategoriesRemoteDataSource _categoriesDataSource;

  DiscoverFilterManager(this._categoriesDataSource);

  /// Get current filter count
  int get filterCount {
    int count = 0;
    if (postedDateFilter != null) count++;
    if (workModeFilter != null) count++;
    if (budgetTypeFilter != null) count++;
    if (durationFilter != null) count++;
    if (categoryFilter != null) count++;
    if (stateFilter != null) count++;
    return count;
  }

  /// Load filters and search from storage
  Future<InitialFilterState> loadFromStorage() async {
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

      // Parse categories
      if (filters['categories'] is List) {
        final ids =
            (filters['categories'] as List).map((e) => e.toString()).toList();
        if (ids.isNotEmpty) categoriesCsv = ids.join(',');
        categoryIds
          ..clear()
          ..addAll(ids);
        await _ensureCategoryNamesLoaded();
      }

      // Parse posted date
      if (filters['postedDate'] != null) {
        final map = filters['postedDate'] as Map<String, dynamic>;
        postedDateLabel = map['label'];
        postedDateApi = map['value'];
      }

      // Parse work mode
      if (filters['workMode'] != null) {
        final map = filters['workMode'] as Map<String, dynamic>;
        workModeLabel = map['label'];
        workModeApi = map['value'];
      }

      // Parse budget type
      if (filters['budgetType'] != null) {
        final map = filters['budgetType'] as Map<String, dynamic>;
        budgetTypeLabel = map['label'];
        budgetTypeApi = map['value'];
      }

      // Parse duration
      if (filters['duration'] != null) {
        final map = filters['duration'] as Map<String, dynamic>;
        durationLabel = map['label'];
        durationApi = map['value'];
      }

      // Parse location
      if (filters['state'] is Map) {
        final stateMap = filters['state'] as Map<String, dynamic>;
        stateName = stateMap['name'];
        stateIdParam = stateMap['id']?.toString();
      }

      if (filters['lgas'] is List) {
        lgaNames = (filters['lgas'] as List).map((e) => e.toString()).toList();
        lgasList = List.from(lgaNames);
        if (lgaNames.isNotEmpty) lgaIdsCsv = lgaNames.join(',');
      }
    }

    // Set instance variables
    postedDateFilter = postedDateApi;
    workModeFilter = workModeApi;
    budgetTypeFilter = budgetTypeApi;
    durationFilter = durationApi;
    categoryFilter = categoriesCsv;
    stateFilter = stateIdParam;
    lgasCsv = lgaIdsCsv;

    return InitialFilterState(
      searchQuery: savedSearch,
      categoriesCsv: categoriesCsv,
      postedDateFilter: postedDateApi,
      workModeFilter: workModeApi,
      budgetTypeFilter: budgetTypeApi,
      durationFilter: durationApi,
      stateFilter: stateIdParam,
      lgasCsv: lgaIdsCsv,
    );
  }

  /// Save current filters to storage
  Future<void> saveToStorage(String searchQuery) async {
    final prefs = await SharedPreferences.getInstance();

    // Build filter map
    final filtersMap = <String, dynamic>{};

    if (categoryIds.isNotEmpty) {
      filtersMap['categories'] = categoryIds.toList();
    }

    if (postedDateLabel != null && postedDateFilter != null) {
      filtersMap['postedDate'] = {
        'label': postedDateLabel,
        'value': postedDateFilter
      };
    }

    if (workModeLabel != null && workModeFilter != null) {
      filtersMap['workMode'] = {
        'label': workModeLabel,
        'value': workModeFilter
      };
    }

    if (budgetTypeLabel != null && budgetTypeFilter != null) {
      filtersMap['budgetType'] = {
        'label': budgetTypeLabel,
        'value': budgetTypeFilter
      };
    }

    if (durationLabel != null && durationFilter != null) {
      filtersMap['duration'] = {
        'label': durationLabel,
        'value': durationFilter
      };
    }

    if (stateName != null && stateFilter != null) {
      filtersMap['state'] = {'name': stateName, 'id': stateFilter};
    }

    if (lgasList.isNotEmpty) {
      filtersMap['lgas'] = lgasList;
    }

    if (filtersMap.isNotEmpty) {
      await prefs.setString('discover_filters', jsonEncode(filtersMap));
    }

    if (searchQuery.isNotEmpty) {
      await prefs.setString('discover_search', searchQuery);
    }
  }

  /// Clear all filters
  void clearFilters() {
    postedDateFilter = null;
    workModeFilter = null;
    budgetTypeFilter = null;
    durationFilter = null;
    categoryFilter = null;
    categoryIds.clear();
    postedDateLabel = null;
    workModeLabel = null;
    budgetTypeLabel = null;
    durationLabel = null;
    stateFilter = null;
    stateName = null;
    lgasList.clear();
    lgasCsv = null;
  }

  /// Ensure category names are loaded
  Future<void> _ensureCategoryNamesLoaded() async {
    if (categoryNameById.isEmpty) {
      final categories = await _categoriesDataSource.fetchCategories();
      for (final cat in categories) {
        categoryNameById[cat.id.toString()] = cat.name;
        for (final sub in cat.subcategories) {
          categoryNameById[sub.id.toString()] = sub.name;
        }
      }
    }
  }

  /// Get category name by ID
  String getCategoryName(String id) {
    return categoryNameById[id] ?? 'Unknown';
  }
}

/// Initial filter state loaded from storage
class InitialFilterState {
  final String searchQuery;
  final String? categoriesCsv;
  final String? postedDateFilter;
  final String? workModeFilter;
  final String? budgetTypeFilter;
  final String? durationFilter;
  final String? stateFilter;
  final String? lgasCsv;

  InitialFilterState({
    required this.searchQuery,
    this.categoriesCsv,
    this.postedDateFilter,
    this.workModeFilter,
    this.budgetTypeFilter,
    this.durationFilter,
    this.stateFilter,
    this.lgasCsv,
  });
}
