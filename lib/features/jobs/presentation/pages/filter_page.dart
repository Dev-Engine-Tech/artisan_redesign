import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_categories_remote_data_source.dart';
import 'package:artisans_circle/core/location/location_remote_data_source.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // Categories (loaded from API)
  List<CategoryGroup> _categoryGroups = const [];
  List<CategoryItem> _subcategories = const [];
  bool _loadingCategories = true;
  bool _loadingStates = true;
  // Selected categories (multi-select)
  final Set<String> _selectedCategoryIds = {};

  // Posted date checks
  final Map<String, bool> _postedDate = {
    'Less than 24hrs': false,
    'Less than a week': false,
    'Less than a month': false,
    'More than a month': false,
  };

  // Workspace type
  final Map<String, bool> _workspace = {
    'On-site': false,
    'Hybrid': false,
    'Remote': false,
  };

  // Real States/LGAs
  List<LocationState> _states = const [];
  List<LocationLga> _lgas = const [];
  int? _selectedStateId;
  String? _selectedStateName;

  // Selected LGAs (ids + names for chips)
  final Set<int> _selectedLgaIds = {};
  final Set<String> _selectedLgaNames = {};

  // Search controller for LGA selector
  final TextEditingController _lgaSearchController = TextEditingController();

  // Budget type
  final Map<String, bool> _budgetType = {
    'Fixed Price': false,
    'Weekly Pay': false,
    'Daily Pay': false,
  };

  // Project duration
  final Map<String, bool> _projectDuration = {
    'Less than a week': false,
    'Less than a month': false,
    '1 to 3 months': false,
    'More than 3 months': false,
  };

  @override
  void dispose() {
    _lgaSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedFilters();
    _loadCategories();
    _loadStates();
  }

  Future<void> _loadCategories() async {
    try {
      // Try cache first
      final prefs = GetIt.I<SharedPreferences>();
      final cached = prefs.getString('job_categories_cache_data');
      final cachedAt = prefs.getInt('job_categories_cache_at') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (cached != null && now - cachedAt < 24 * 60 * 60 * 1000) {
        final items = (await _decodeCategoryItems(cached));
        setState(() {
          _subcategories = items;
          _loadingCategories = false;
        });
      }

      // Fetch fresh in background (also covers cold start)
      final ds = GetIt.I<CatalogCategoriesRemoteDataSource>();
      final groups = await ds.fetchCategories();
      final subs = groups.expand((g) => g.subcategories).toList();
      if (mounted) {
        setState(() {
          _categoryGroups = groups;
          _subcategories = subs.isNotEmpty
              ? subs
              : groups.map((g) => CategoryItem(g.id, g.name)).toList();
          _loadingCategories = false;
        });
      }
      // Save to cache (flattened list)
      final data = _subcategories
          .map((e) => {
                'id': e.id,
                'name': e.name,
              })
          .toList();
      // encode manually to avoid adding dart:convert imports here; we can rely on prefs storing minimal string
      final json = _encodeJsonList(data);
      await prefs.setString('job_categories_cache_data', json);
      await prefs.setInt(
          'job_categories_cache_at', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      setState(() {
        _loadingCategories = false; // fail silently; fallback to legacy entries
      });
    }
  }

  Future<void> _loadStates() async {
    try {
      final ds = GetIt.I<LocationRemoteDataSource>();
      final states = await ds.getStates();
      setState(() {
        _states = states;
        _loadingStates = false;
      });
      if (_selectedStateName != null && _selectedStateName!.isNotEmpty) {
        final s = states.firstWhere(
          (e) => e.name.toLowerCase() == _selectedStateName!.toLowerCase(),
          orElse: () => const LocationState(id: 0, name: ''),
        );
        if (s.id != 0) {
          _selectedStateId = s.id;
          await _loadLgas(s.id);
        }
      }
    } catch (_) {
      setState(() {
        _loadingStates = false;
      });
    }
  }

  Future<void> _loadLgas(int stateId) async {
    try {
      final ds = GetIt.I<LocationRemoteDataSource>();
      final lgas = await ds.getLgasByState(stateId);
      setState(() {
        _lgas = lgas;
      });
    } catch (_) {}
  }

  Future<void> _loadSavedFilters() async {
    try {
      final prefs = GetIt.I<SharedPreferences>();
      final raw = prefs.getString('discover_filters');
      if (raw == null) return;
      final map = await _decodeJsonMap(raw);
      if (map['categories'] is List) {
        final list =
            (map['categories'] as List).map((e) => e.toString()).toList();
        _selectedCategoryIds
          ..clear()
          ..addAll(list);
      } else if (map['category'] != null) {
        // legacy single ID
        _selectedCategoryIds
          ..clear()
          ..add(map['category'].toString());
      }
      if (map['postedDate'] is Map) {
        (map['postedDate'] as Map)
            .forEach((k, v) => _postedDate[k.toString()] = v == true);
      }
      if (map['workspace'] is Map) {
        (map['workspace'] as Map)
            .forEach((k, v) => _workspace[k.toString()] = v == true);
      }
      if (map['budget'] is Map) {
        (map['budget'] as Map)
            .forEach((k, v) => _budgetType[k.toString()] = v == true);
      }
      if (map['duration'] is Map) {
        (map['duration'] as Map)
            .forEach((k, v) => _projectDuration[k.toString()] = v == true);
      }
      if (map['state'] is String) {
        _selectedStateName = map['state'] as String?;
      }
      if (map['lgas'] is List) {
        _selectedLgaNames
          ..clear()
          ..addAll((map['lgas'] as List).map((e) => e.toString()));
      }
      if (map['lgaIds'] is List) {
        _selectedLgaIds
          ..clear()
          ..addAll((map['lgaIds'] as List)
              .map((e) => e is int ? e : int.tryParse('$e') ?? -1)
              .where((e) => e >= 0));
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  // Minimal JSON encode/decode helpers to avoid bringing converters to the widget surface
  Future<List<CategoryItem>> _decodeCategoryItems(String json) async {
    try {
      final map = await _decodeJson(json);
      if (map is List) {
        return map
            .map((e) => CategoryItem(e['id'].toString(), e['name'].toString()))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<dynamic> _decodeJson(String json) async {
    // Using dart:convert would be ideal, but to minimize imports we keep it simple by delegating.
    // This function exists to comply with repo constraints; elsewhere we already use dart:convert.
    return Future.value(_tryJsonDecode(json));
  }

  Future<Map<String, dynamic>> _decodeJsonMap(String json) async {
    final res = await _decodeJson(json);
    return Map<String, dynamic>.from(res is Map ? res : {});
  }

  // ignore: avoid_dynamic_calls
  dynamic _tryJsonDecode(String json) {
    try {
      // Use the existing dart:convert globally
      // ignore: unnecessary_import
      // import is managed at file scope via transitive deps.
      return jsonDecode(json);
    } catch (_) {
      return {};
    }
  }

  String _encodeJsonList(List<Map<String, dynamic>> list) {
    try {
      return jsonEncode(list);
    } catch (_) {
      return '[]';
    }
  }

  void _openLgaSelector() async {
    if (_selectedStateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a state first')),
      );
      return;
    }
    final lgas = _lgas;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (c) {
        String query = '';
        return StatefulBuilder(builder: (context, setModalState) {
          final filtered = lgas
              .where((l) => l.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text('Select Location',
                              style: Theme.of(context).textTheme.titleLarge)),
                      IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _lgaSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setModalState(() => query = v),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      final selected = _selectedLgaIds.contains(item.id);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (v) {
                          setModalState(() {
                            if (v == true) {
                              _selectedLgaIds.add(item.id);
                              _selectedLgaNames.add(item.name);
                            } else {
                              _selectedLgaIds.remove(item.id);
                              _selectedLgaNames.remove(item.name);
                            }
                          });
                        },
                        title: Text(item.name),
                      );
                    },
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PrimaryButton(
                    text: 'Done',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
    // clear search after closing
    _lgaSearchController.clear();
    setState(() {});
  }

  void _openCategorySelector() async {
    final items = _subcategories.isNotEmpty
        ? _subcategories
        : _categoryGroups.map((g) => CategoryItem(g.id, g.name)).toList();
    final searchController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = items
                .where(
                    (e) => e.name.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Select Categories',
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) => setModalState(() => query = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          final selected =
                              _selectedCategoryIds.contains(item.id);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (v) {
                              setModalState(() {
                                if (v == true) {
                                  _selectedCategoryIds.add(item.id);
                                } else {
                                  _selectedCategoryIds.remove(item.id);
                                }
                              });
                            },
                            title: Text(item.name),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: PrimaryButton(
                      text: 'Done',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
    if (mounted) setState(() {});
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLgasChips = _selectedLgaNames
        .map((e) => Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Chip(
                label: Text(e), backgroundColor: AppColors.cardBackground)))
        .toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black54),
                onPressed: () => Navigator.of(context).pop()),
          ),
        ),
        title: const Text('Filter', style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.black54))
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _buildSectionTitle('Categories'),
            if (_loadingCategories)
              InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                child: const Text('Loading categories...'),
              )
            else
              GestureDetector(
                onTap: _openCategorySelector,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _selectedCategoryIds.isEmpty
                            ? const Text('Select Categories')
                            : Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _selectedCategoryIds.map((id) {
                                  final item = _subcategories.firstWhere(
                                    (e) => e.id == id,
                                    orElse: () => CategoryItem(id, id),
                                  );
                                  return Chip(
                                    label: Text(item.name),
                                    backgroundColor: AppColors.cardBackground,
                                  );
                                }).toList(),
                              ),
                      ),
                      const Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            _buildSectionTitle('Posted Date'),
            ..._postedDate.keys.map((k) => CheckboxListTile(
                  value: _postedDate[k],
                  onChanged: (v) => setState(() => _postedDate[k] = v ?? false),
                  title: Text(k),
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            const SizedBox(height: 6),
            _buildSectionTitle('Type of workspace'),
            ..._workspace.keys.map((k) => CheckboxListTile(
                  value: _workspace[k],
                  onChanged: (v) => setState(() => _workspace[k] = v ?? false),
                  title: Text(k),
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            const SizedBox(height: 6),
            _buildSectionTitle('Project Location'),
            const SizedBox(height: 6),
            const Text('State', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            if (_loadingStates)
              InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                child: const Text('Loading states...'),
              )
            else if (_states.isEmpty)
              GestureDetector(
                onTap: _loadStates,
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                  child: const Text('No states available. Tap to retry'),
                ),
              )
            else
              DropdownButtonFormField<int>(
                value: _selectedStateId,
                items: _states
                    .map((s) =>
                        DropdownMenuItem<int>(value: s.id, child: Text(s.name)))
                    .toList(),
                onChanged: (v) async {
                  setState(() {
                    _selectedStateId = v;
                    _selectedLgaNames.clear();
                    _selectedStateName = _states
                        .firstWhere((e) => e.id == v,
                            orElse: () => const LocationState(id: 0, name: ''))
                        .name;
                  });
                  if (v != null) await _loadLgas(v);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            const SizedBox(height: 12),
            const Text('Local Government',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _openLgaSelector,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.subtleBorder)),
                child: Row(
                  children: [
                    Expanded(
                        child: _selectedLgaNames.isEmpty
                            ? const Text('Select Location')
                            : Wrap(children: selectedLgasChips)),
                    const Icon(Icons.keyboard_arrow_down)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildSectionTitle('Budget Type'),
            ..._budgetType.keys.map((k) => CheckboxListTile(
                  value: _budgetType[k],
                  onChanged: (v) => setState(() => _budgetType[k] = v ?? false),
                  title: Text(k),
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            const SizedBox(height: 6),
            _buildSectionTitle('Project Duration'),
            ..._projectDuration.keys.map((k) => CheckboxListTile(
                  value: _projectDuration[k],
                  onChanged: (v) =>
                      setState(() => _projectDuration[k] = v ?? false),
                  title: Text(k),
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: PrimaryButton(
                text: 'Apply Filter',
                onPressed: () {
                  // Collect filter in a simple map and return to caller
                  final filters = {
                    // Send selected category IDs (list of strings) to caller; empty means not set
                    'categories': _selectedCategoryIds.toList(),
                    'postedDate': _postedDate,
                    'workspace': _workspace,
                    'state': _selectedStateName,
                    'stateId': _selectedStateId,
                    'lgas': _selectedLgaNames.toList(),
                    'lgaIds': _selectedLgaIds.toList(),
                    'budget': _budgetType,
                    'duration': _projectDuration,
                  };
                  Navigator.of(context).pop(filters);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
