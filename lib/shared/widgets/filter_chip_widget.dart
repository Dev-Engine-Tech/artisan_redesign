import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Shared filter chip widget following DRY principle
/// Use this instead of creating duplicate _buildFilterChip methods
class FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? deleteIconColor;
  final IconData? leadingIcon;

  const FilterChipWidget({
    required this.label,
    required this.onDeleted,
    super.key,
    this.backgroundColor,
    this.textColor,
    this.deleteIconColor,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.softPeach,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: AppColors.softBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingSM,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: 14,
                color: textColor ?? AppColors.orange,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor ?? AppColors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: 14,
                color: deleteIconColor ?? AppColors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable list of filter chips
class FilterChipList extends StatelessWidget {
  final List<FilterChipData> filters;
  final VoidCallback? onClearAll;
  final String clearAllLabel;

  const FilterChipList({
    required this.filters,
    super.key,
    this.onClearAll,
    this.clearAllLabel = 'Clear All',
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.horizontalLG,
      child: Row(
        children: [
          ...filters.map((filter) => FilterChipWidget(
                label: filter.label,
                onDeleted: filter.onDelete,
                leadingIcon: filter.icon,
              )),
          if (onClearAll != null && filters.isNotEmpty)
            GestureDetector(
              onTap: onClearAll,
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                padding: AppSpacing.paddingSM,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: AppRadius.radiusLG,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.clear_all,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      clearAllLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Data class for filter chip
class FilterChipData {
  final String label;
  final VoidCallback onDelete;
  final IconData? icon;

  const FilterChipData({
    required this.label,
    required this.onDelete,
    this.icon,
  });
}

/// Wrap style filter chips (for non-scrollable layouts)
class FilterChipWrap extends StatelessWidget {
  final List<FilterChipData> filters;
  final VoidCallback? onClearAll;
  final String clearAllLabel;

  const FilterChipWrap({
    required this.filters,
    super.key,
    this.onClearAll,
    this.clearAllLabel = 'Clear All',
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...filters.map((filter) => FilterChipWidget(
              label: filter.label,
              onDeleted: filter.onDelete,
              leadingIcon: filter.icon,
            )),
        if (onClearAll != null && filters.isNotEmpty)
          GestureDetector(
            onTap: onClearAll,
            child: Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: AppRadius.radiusLG,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.clear_all,
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    clearAllLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
