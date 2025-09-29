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

class _HomeHeroSectionState extends State<HomeHeroSection> with AutomaticKeepAliveClientMixin {
  late final PageController _heroController;
  late final List<HeroItem> _heroItems;

  @override
  bool get wantKeepAlive => true; // Performance: Keep state alive to avoid rebuilds

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
    return const [
      HeroItem(
        title: 'Discover Your Ideal\nJob match',
        subtitle: 'Personalized Recommendations for Every Artisan',
        color: Color(0xFFE8F4FD),
        iconColor: Color(0xFF3B82F6),
        icon: Icons.search,
      ),
      HeroItem(
        title: 'Build Your Professional\nNetwork',
        subtitle: 'Connect with clients and fellow artisans',
        color: Color(0xFFF0F9FF),
        iconColor: Color(0xFF0EA5E9),
        icon: Icons.people,
      ),
      HeroItem(
        title: 'Showcase Your\nCraftsmanship',
        subtitle: 'Create a stunning portfolio that stands out',
        color: Color(0xFFFEF3E2),
        iconColor: Color(0xFFEA580C),
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
    super.key,
    required this.item,
  });

  final HeroItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkBlue.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
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
