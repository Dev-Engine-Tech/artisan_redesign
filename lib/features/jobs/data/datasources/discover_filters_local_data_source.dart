import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for discover page filters and search
///
/// Handles persistence of user's filter selections and search queries
/// for the job discover page.
class DiscoverFiltersLocalDataSource {
  static const String _filtersKey = 'discover_filters';
  static const String _searchKey = 'discover_search';

  /// Load saved filters from local storage
  Future<Map<String, dynamic>?> loadFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final rawFilters = prefs.getString(_filtersKey);
    if (rawFilters == null) return null;

    try {
      return jsonDecode(rawFilters) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save filters to local storage
  Future<bool> saveFilters(Map<String, dynamic> filters) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(filters);
    return prefs.setString(_filtersKey, encoded);
  }

  /// Load saved search query
  Future<String> loadSearchQuery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_searchKey) ?? '';
  }

  /// Save search query
  Future<bool> saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_searchKey, query);
  }

  /// Clear all saved filters and search
  Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_filtersKey);
    await prefs.remove(_searchKey);
    return true;
  }
}
