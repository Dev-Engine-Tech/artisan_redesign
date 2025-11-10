import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';

/// Inline filter controls that can be embedded in the Discover page.
/// Accepts an optional onApply callback which receives a Map of selected filters.
class FilterInline extends StatefulWidget {
  final void Function(Map<String, dynamic> filters)? onApply;
  const FilterInline({super.key, this.onApply});

  @override
  State<FilterInline> createState() => _FilterInlineState();
}

class _FilterInlineState extends State<FilterInline> {
  String? _selectedCategory;

  final Map<String, bool> _postedDate = {
    'Less than 24hrs': false,
    'Less than a week': false,
    'Less than a month': false,
    'More than a month': false,
  };

  final Map<String, bool> _workspace = {
    'On-site': false,
    'Hybrid': false,
    'Remote': false,
  };

  String? _selectedState = 'Abia';
  final Map<String, List<String>> _lgasByState = {
    'Abia': [
      'Aba North',
      'Aba South',
      'Arochukwu',
      'Bende',
      'Ikwuano',
      'Isiala Ngwa North',
      'Isiala Ngwa South',
      'Isuikwuato',
      'Obi Ngwa'
    ],
    'Lagos': ['Ikeja', 'Epe', 'Badagry', 'Ikorodu']
  };

  final Set<String> _selectedLgas = {};
  final TextEditingController _lgaSearchController = TextEditingController();

  final Map<String, bool> _budgetType = {
    'Fixed Price': false,
    'Weekly Pay': false,
    'Daily Pay': false,
  };

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

  void _openLgaSelector() async {
    final lgas = _lgasByState[_selectedState] ?? [];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (c) {
        String query = '';
        return StatefulBuilder(builder: (context, setModalState) {
          final filtered = lgas
              .where((l) => l.toLowerCase().contains(query.toLowerCase()))
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
                          borderRadius: AppRadius.radiusMD,
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => setModalState(() => query = v),
                  ),
                ),
                AppSpacing.spaceSM,
                Flexible(
                    child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final name = filtered[i];
                      final selected = _selectedLgas.contains(name);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (v) {
                          setModalState(() {
                            if (v == true) {
                              _selectedLgas.add(name);
                            } else {
                              _selectedLgas.remove(name);
                            }
                          });
                        },
                        title: Text(name),
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
    _lgaSearchController.clear();
    setState(() {});
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLgasChips = _selectedLgas
        .map((e) => Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Chip(
                label: Text(e), backgroundColor: AppColors.cardBackground)))
        .toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Categories'),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Select Categories')),
              DropdownMenuItem(value: 'design', child: Text('Design')),
              DropdownMenuItem(value: 'electrical', child: Text('Electrical')),
              DropdownMenuItem(value: 'carpentry', child: Text('Carpentry')),
            ],
            onChanged: (v) => setState(() => _selectedCategory = v),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            items: _lgasByState.keys
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() {
              _selectedState = v;
              _selectedLgas.clear();
            }),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
          AppSpacing.spaceMD,
          const Text('Local Government',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _openLgaSelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(color: AppColors.subtleBorder)),
              child: Row(
                children: [
                  Expanded(
                      child: _selectedLgas.isEmpty
                          ? const Text('Select Location')
                          : Wrap(children: selectedLgasChips)),
                  const Icon(Icons.keyboard_arrow_down)
                ],
              ),
            ),
          ),
          AppSpacing.spaceMD,
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
          AppSpacing.spaceMD,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: PrimaryButton(
              text: 'Apply Filters',
              onPressed: () {
                final filters = {
                  'category': _selectedCategory,
                  'postedDate': _postedDate,
                  'workspace': _workspace,
                  'state': _selectedState,
                  'lgas': _selectedLgas.toList(),
                  'budget': _budgetType,
                  'duration': _projectDuration,
                };
                if (widget.onApply != null) widget.onApply!(filters);
              },
            ),
          ),
          AppSpacing.spaceMD,
        ],
      ),
    );
  }
}
