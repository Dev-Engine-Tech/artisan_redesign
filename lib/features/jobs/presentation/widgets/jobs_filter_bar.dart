import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../core/utils/responsive.dart';

/// Reusable filter and search bar for jobs pages
///
/// Generic component used by:
/// - OngoingJobsPage
/// - CompletedJobsPage
/// - Any other jobs listing page
class JobsFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedFilter;
  final String searchHint;
  final List<FilterOption> filterOptions;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onFilterChanged;

  const JobsFilterBar({
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilter,
    required this.searchHint,
    required this.filterOptions,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onFilterChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: context.responsivePadding,
      color: context.cardBackgroundColor,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: context.softBorderColor),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon:
                    Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: colorScheme.onSurfaceVariant),
                        onPressed: onSearchClear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: onSearchChanged,
            ),
          ),
          AppSpacing.spaceMD,
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filterOptions.length,
              separatorBuilder: (_, __) => AppSpacing.spaceSM,
              itemBuilder: (context, index) {
                final option = filterOptions[index];
                final isSelected = selectedFilter == option.value;
                return GestureDetector(
                  onTap: () => onFilterChanged(option.value),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.primaryColor
                          : context.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? context.primaryColor
                            : context.softBorderColor,
                      ),
                    ),
                    child: Text(
                      option.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : context.brownHeaderColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter option model
class FilterOption {
  final String label;
  final String value;

  const FilterOption({required this.label, required this.value});
}
