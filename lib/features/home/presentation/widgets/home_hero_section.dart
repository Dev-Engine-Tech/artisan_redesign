import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';

/// Optimized hero section widget that follows SOLID principles
/// Single Responsibility: Only handles hero content display
/// Open/Closed: Can be extended with different hero content without modification
class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({super.key});

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection>
    with AutomaticKeepAliveClientMixin {
  late final PageController _heroController;
  late final List<HeroItem> _heroItems;

  @override
  bool get wantKeepAlive =>
      true; // Performance: Keep state alive to avoid rebuilds

  @override
  void initState() {
    super.initState();
    _heroController = PageController(viewportFraction: 0.98);
    _heroItems = _createHeroItems();
  }

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  /// Factory method for creating hero items
  /// Follows Single Responsibility and makes testing easier
  List<HeroItem> _createHeroItems() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      HeroItem(
        title: 'Discover Your Ideal\nJob match',
        subtitle: 'Personalized Recommendations for Every Artisan',
        color: isDark ? const Color(0xFF1E3A5F) : AppColors.lightBlue,
        iconColor: isDark ? const Color(0xFF64B5F6) : AppColors.blue,
        icon: Icons.search,
      ),
      HeroItem(
        title: 'Build Your Professional\nNetwork',
        subtitle: 'Connect with clients and fellow artisans',
        color: isDark ? const Color(0xFF1E3D3D) : AppColors.lightCyan,
        iconColor: isDark ? const Color(0xFF4DD0E1) : AppColors.cyan,
        icon: Icons.people,
      ),
      HeroItem(
        title: 'Showcase Your\nCraftsmanship',
        subtitle: 'Create a stunning portfolio that stands out',
        color: isDark ? const Color(0xFF3D2E1E) : AppColors.lightOrange,
        iconColor: context.primaryColor,
        icon: Icons.star,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _heroController,
        itemCount: _heroItems.length,
        itemBuilder: (context, index) {
          return HeroCard(item: _heroItems[index]);
        },
      ),
    );
  }
}

/// Immutable data class for hero items
/// Follows Single Responsibility and Data Transfer Object pattern
@immutable
class HeroItem {
  const HeroItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final IconData icon;
}

/// Performance-optimized hero card widget with const constructor
/// Follows Single Responsibility: Only handles single hero card display
class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.item,
    super.key,
  });

  final HeroItem item;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? context.colorScheme.onSurface
        : context.darkBlueColor;

    return Container(
      margin: AppSpacing.horizontalXS,
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: AppRadius.radiusXL,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                AppSpacing.spaceSM,
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.spaceLG,
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: context.cardBackgroundColor.withValues(alpha: 0.5),
              borderRadius: AppRadius.radiusLG,
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
