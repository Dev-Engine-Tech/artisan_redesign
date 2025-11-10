import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';

class DiscoverSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClearTap;
  final String hintText;
  final int filterCount;
  final bool showFilterBadge;

  const DiscoverSearchBar({
    required this.controller,
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onClearTap,
    this.hintText = 'Search products, services and artisans',
    this.filterCount = 0,
    this.showFilterBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.4),
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black.withValues(alpha: 0.4),
                    size: 22,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            controller.clear();
                            onClearTap?.call();
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          AppSpacing.spaceMD,

          // Filter button
          Container(
            decoration: BoxDecoration(
              color: AppColors.softPink,
              borderRadius: AppRadius.radiusLG,
            ),
            child: Stack(
              children: [
                IconButton(
                  onPressed: onFilterTap,
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.brownHeader,
                    size: 24,
                  ),
                  padding: AppSpacing.paddingMD,
                ),

                // Filter count badge
                if (showFilterBadge && filterCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: AppSpacing.paddingXS,
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        filterCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Search suggestions widget for enhanced UX
class SearchSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;
  final bool isVisible;

  const SearchSuggestions({
    required this.suggestions,
    required this.onSuggestionTap,
    super.key,
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: AppSpacing.horizontalLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.subtleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: suggestions.take(5).map((suggestion) {
          return ListTile(
            leading: const Icon(
              Icons.search,
              color: Colors.grey,
              size: 20,
            ),
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () => onSuggestionTap(suggestion),
            dense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Popular searches widget
class PopularSearches extends StatelessWidget {
  final List<String> popularSearches;
  final ValueChanged<String> onSearchTap;

  const PopularSearches({
    required this.popularSearches,
    required this.onSearchTap,
    super.key,
  });

  static const List<String> defaultSearches = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Home Repair',
    'Installation',
    'Maintenance',
  ];

  @override
  Widget build(BuildContext context) {
    final searches =
        popularSearches.isNotEmpty ? popularSearches : defaultSearches;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brownHeader,
            ),
          ),
          AppSpacing.spaceMD,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((search) {
              return GestureDetector(
                onTap: () => onSearchTap(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusXXL,
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.brownHeader,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
