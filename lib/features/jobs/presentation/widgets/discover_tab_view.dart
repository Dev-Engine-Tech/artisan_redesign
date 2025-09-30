import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';

class DiscoverTabView extends StatefulWidget {
  final List<DiscoverTab> tabs;
  final int initialIndex;
  final Function(int) onTabChanged;
  final Widget Function(int) contentBuilder;
  final double height;

  const DiscoverTabView({
    super.key,
    required this.tabs,
    required this.contentBuilder,
    required this.onTabChanged,
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
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.softPink : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.softPink : AppColors.subtleBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tab.label,
            style: TextStyle(
              color: AppColors.brownHeader,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (tab.count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tab.count!.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.brownHeader,
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
              color: AppColors.brownHeader,
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
    super.key,
    required this.child,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Try Again'),
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
          return Container(
            width: 100 + (index * 20), // Varying widths
            height: height,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(24),
            ),
          );
        }),
      ),
    );
  }
}
