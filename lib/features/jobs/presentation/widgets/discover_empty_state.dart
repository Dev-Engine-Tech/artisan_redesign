import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

/// Empty state widget for Discover page tabs
///
/// Displays different empty states based on the active tab:
/// - Tab 0 (Best Matches): "No Jobs Found"
/// - Tab 1 (Saved Jobs): "No Saved Jobs"
/// - Tab 2+ (Other): Generic "No Jobs"
class DiscoverEmptyState extends StatelessWidget {
  final int tabIndex;
  final bool hasSearchQuery;

  const DiscoverEmptyState({
    required this.tabIndex,
    this.hasSearchQuery = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 0:
        title = 'No Jobs Found';
        subtitle = hasSearchQuery
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
        padding: AppSpacing.paddingXXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            AppSpacing.spaceLG,
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
            ),
            AppSpacing.spaceSM,
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
}
