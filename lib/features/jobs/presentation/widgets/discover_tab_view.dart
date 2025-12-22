import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';

class DiscoverTabView extends StatefulWidget {
  final List<DiscoverTab> tabs;
  final int initialIndex;
  final Function(int) onTabChanged;
  final Widget Function(int) contentBuilder;
  final double height;

  const DiscoverTabView({
    required this.tabs,
    required this.contentBuilder,
    required this.onTabChanged,
    super.key,
    this.initialIndex = 0,
    this.height = 46,
  });

  @override
  State<DiscoverTabView> createState() => _DiscoverTabViewState();
}

class _DiscoverTabViewState extends State<DiscoverTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      _currentIndex = _tabController.index;
    });
    widget.onTabChanged(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom tab bar
        Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: AppSpacing.horizontalSM,
            indicator: const BoxDecoration(),
            dividerColor: Colors.transparent,
            tabs: widget.tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = _currentIndex == index;

              return _buildTabChip(tab, isSelected);
            }).toList(),
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(
              widget.tabs.length,
              (index) => widget.contentBuilder(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabChip(DiscoverTab tab, bool isSelected) {
    return Container(
      height: widget.height,
      padding: AppSpacing.horizontalLG,
      decoration: BoxDecoration(
        color: isSelected ? context.softPinkColor : context.cardBackgroundColor,
        borderRadius: AppRadius.radiusXXXL,
        border: Border.all(
          color: isSelected ? context.softPinkColor : context.subtleBorderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tab.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.brownHeaderColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
          if (tab.count != null) ...[
            AppSpacing.spaceSM,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppRadius.radiusLG,
              ),
              child: Text(
                tab.count!.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.brownHeaderColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
          if (tab.icon != null) ...[
            const SizedBox(width: 6),
            Icon(
              tab.icon,
              size: 16,
              color: context.brownHeaderColor,
            ),
          ],
        ],
      ),
    );
  }
}

class DiscoverTab {
  final String label;
  final int? count;
  final IconData? icon;
  final String? key;

  const DiscoverTab({
    required this.label,
    this.count,
    this.icon,
    this.key,
  });
}

// Tab content wrapper with loading and error states
class DiscoverTabContent extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;
  final Widget? emptyState;

  const DiscoverTabContent({
    required this.child,
    super.key,
    this.isLoading = false,
    this.error,
    this.onRetry,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.orange,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              AppSpacing.spaceLG,
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.spaceSM,
              Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                AppSpacing.spaceLG,
                PrimaryButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return child;
  }
}

// Shimmer loading placeholder for tabs
class DiscoverTabsShimmer extends StatelessWidget {
  final int tabCount;
  final double height;

  const DiscoverTabsShimmer({
    super.key,
    this.tabCount = 3,
    this.height = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(tabCount, (index) {
          return Builder(
            builder: (context) => Container(
              width: 100 + (index * 20), // Varying widths
              height: height,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                borderRadius: AppRadius.radiusXXXL,
              ),
            ),
          );
        }),
      ),
    );
  }
}
