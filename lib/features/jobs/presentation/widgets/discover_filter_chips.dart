import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Active filter chips widget for Discover page
///
/// Displays:
/// - Category filter chips with names
/// - Posted date, work mode, budget type, duration filter chips
/// - State and LGA filter chips
/// - "Clear all" button when filters are active
class DiscoverFilterChips extends StatelessWidget {
  final Set<String> categoryIds;
  final Map<String, String> categoryNameById;
  final String? postedDateLabel;
  final String? workModeLabel;
  final String? budgetTypeLabel;
  final String? durationLabel;
  final String? stateFilter;
  final String? stateName;
  final List<String> lgasList;
  final Function(String) onRemoveCategory;
  final VoidCallback onClearPostedDate;
  final VoidCallback onClearWorkMode;
  final VoidCallback onClearBudgetType;
  final VoidCallback onClearDuration;
  final VoidCallback onClearState;
  final VoidCallback onClearLgas;
  final VoidCallback onClearAll;

  const DiscoverFilterChips({
    required this.categoryIds,
    required this.categoryNameById,
    required this.onRemoveCategory,
    required this.onClearPostedDate,
    required this.onClearWorkMode,
    required this.onClearBudgetType,
    required this.onClearDuration,
    required this.onClearState,
    required this.onClearLgas,
    required this.onClearAll,
    this.postedDateLabel,
    this.workModeLabel,
    this.budgetTypeLabel,
    this.durationLabel,
    this.stateFilter,
    this.stateName,
    this.lgasList = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    // Category chips
    if (categoryIds.isNotEmpty) {
      for (final id in categoryIds) {
        final name = categoryNameById[id] ?? 'Category';
        chips.add(_filterChip(name, () => onRemoveCategory(id)));
      }
    }

    // Simple label chips
    if (postedDateLabel != null) {
      chips.add(_filterChip(postedDateLabel!, onClearPostedDate));
    }
    if (workModeLabel != null) {
      chips.add(_filterChip(workModeLabel!, onClearWorkMode));
    }
    if (budgetTypeLabel != null) {
      chips.add(_filterChip(budgetTypeLabel!, onClearBudgetType));
    }
    if (durationLabel != null) {
      chips.add(_filterChip(durationLabel!, onClearDuration));
    }
    if (stateFilter != null && stateFilter!.isNotEmpty) {
      chips.add(_filterChip(stateName ?? 'State', onClearState));
    }
    if (lgasList.isNotEmpty) {
      final n = lgasList.length;
      chips.add(_filterChip('LGA ($n)', onClearLgas));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    // Add Clear All action
    chips.add(
      GestureDetector(
        onTap: onClearAll,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: AppRadius.radiusXL,
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
      padding: AppSpacing.horizontalLG,
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
          borderRadius: AppRadius.radiusXL,
          side: const BorderSide(color: AppColors.subtleBorder),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
