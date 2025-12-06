import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/models/banner_model.dart' as api;
import 'package:artisans_circle/core/services/banner_service.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/core/image_url.dart';

/// Model for banner UI data
class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? ctaText;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.ctaText,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });
}

/// Data source for banner carousel
enum BannerDataSource {
  /// Load banners from API
  api,

  /// Use static banners provided
  static,

  /// Use default fallback banners
  defaults,
}

/// Unified banner carousel that handles all banner display scenarios
///
/// This replaces BannerCarousel, ApiBannerCarousel, and EnhancedBannerCarousel
///
/// Usage:
/// ```dart
/// // Static banners
/// UnifiedBannerCarousel(
///   dataSource: BannerDataSource.static,
///   staticBanners: myBanners,
/// )
///
/// // API banners
/// UnifiedBannerCarousel(
///   dataSource: BannerDataSource.api,
///   apiCategory: BannerCategory.homepage,
/// )
/// ```
class UnifiedBannerCarousel extends StatefulWidget {
  final BannerDataSource dataSource;
  final List<BannerModel>? staticBanners;
  final api.BannerCategory? apiCategory;
  final double height;
  final Duration autoPlayInterval;
  final bool autoPlay;
  final EdgeInsets? padding;

  const UnifiedBannerCarousel({
    super.key,
    this.dataSource = BannerDataSource.defaults,
    this.staticBanners,
    this.apiCategory,
    this.height = 120,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.autoPlay = false,
    this.padding,
  }) : assert(
            dataSource == BannerDataSource.static && staticBanners != null ||
                dataSource == BannerDataSource.api && apiCategory != null ||
                dataSource == BannerDataSource.defaults,
            'Must provide staticBanners for static source or apiCategory for API source');

  /// Create carousel with static banners
  factory UnifiedBannerCarousel.static({
    required List<BannerModel> banners,
    double height = 120,
    Duration autoPlayInterval = const Duration(seconds: 5),
    bool autoPlay = false,
    EdgeInsets? padding,
  }) {
    return UnifiedBannerCarousel(
      dataSource: BannerDataSource.static,
      staticBanners: banners,
      height: height,
      autoPlayInterval: autoPlayInterval,
      autoPlay: autoPlay,
      padding: padding,
    );
  }

  /// Create carousel with API banners
  factory UnifiedBannerCarousel.api({
    required api.BannerCategory category,
    double height = 120,
    Duration autoPlayInterval = const Duration(seconds: 5),
    bool autoPlay = true,
    EdgeInsets? padding,
  }) {
    return UnifiedBannerCarousel(
      dataSource: BannerDataSource.api,
      apiCategory: category,
      height: height,
      autoPlayInterval: autoPlayInterval,
      autoPlay: autoPlay,
      padding: padding,
    );
  }

  @override
  State<UnifiedBannerCarousel> createState() => _UnifiedBannerCarouselState();
}

class _UnifiedBannerCarouselState extends State<UnifiedBannerCarousel> {
  late PageController _pageController;
  List<BannerModel> _banners = [];
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _loadBanners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    switch (widget.dataSource) {
      case BannerDataSource.static:
        setState(() {
          _banners = widget.staticBanners!;
          _isLoading = false;
        });
        _startAutoPlayIfNeeded();
        break;

      case BannerDataSource.api:
        await _loadApiBanners();
        break;

      case BannerDataSource.defaults:
        setState(() {
          _banners = _getDefaultBanners();
          _isLoading = false;
        });
        _startAutoPlayIfNeeded();
        break;
    }
  }

  Future<void> _loadApiBanners() async {
    if (widget.apiCategory == null) return;

    setState(() => _isLoading = true);

    try {
      final bannerService = getIt<BannerService>();
      final apiResponse = await bannerService.getBanners(
        category: widget.apiCategory!,
      );

      final uiBanners = apiResponse.banners
          .where((banner) => banner.isActive)
          .map(_convertApiBannerToUiBanner)
          .toList();

      if (mounted) {
        setState(() {
          _banners =
              uiBanners.isEmpty ? _getDefaultBannersForCategory() : uiBanners;
          _isLoading = false;
        });
        _startAutoPlayIfNeeded();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading banners: $e');
      if (mounted) {
        setState(() {
          _banners = _getDefaultBannersForCategory();
          _isLoading = false;
        });
      }
    }
  }

  BannerModel _convertApiBannerToUiBanner(api.ApiBannerItem apiBanner) {
    String normalizeUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      final fixed = sanitizeImageUrl(url);
      if (fixed.startsWith('http')) return fixed;
      final base = ApiEndpoints.baseUrl;
      final sep = fixed.startsWith('/') ? '' : '/';
      return '$base$sep$fixed';
    }

    return BannerModel(
      id: apiBanner.id.toString(),
      title: apiBanner.title,
      subtitle: _getSubtitleForCategory(),
      imageUrl: normalizeUrl(apiBanner.image),
      ctaText: _getCtaForCategory(),
      backgroundColor: _getColorForCategory(),
      onTap: () => _handleBannerTap(apiBanner),
    );
  }

  String _getSubtitleForCategory() {
    if (widget.apiCategory == null) return '';
    switch (widget.apiCategory!) {
      case api.BannerCategory.homepage:
        return 'Discover opportunities that match your skills';
      case api.BannerCategory.job:
        return 'Apply now and grow your career';
      case api.BannerCategory.catalog:
        return 'Browse featured products and services';
      case api.BannerCategory.ads:
        return 'Special offers and promotions';
    }
  }

  String _getCtaForCategory() {
    if (widget.apiCategory == null) return 'View';
    switch (widget.apiCategory!) {
      case api.BannerCategory.homepage:
        return 'Explore';
      case api.BannerCategory.job:
        return 'Apply';
      case api.BannerCategory.catalog:
        return 'Browse';
      case api.BannerCategory.ads:
        return 'View Offer';
    }
  }

  Color _getColorForCategory() {
    if (widget.apiCategory == null) return AppColors.orange;
    switch (widget.apiCategory!) {
      case api.BannerCategory.homepage:
        return AppColors.orange;
      case api.BannerCategory.job:
        return AppColors.green;
      case api.BannerCategory.catalog:
        return AppColors.purple;
      case api.BannerCategory.ads:
        return AppColors.pink;
    }
  }

  void _handleBannerTap(api.ApiBannerItem banner) {
    // Handle banner tap based on category
  }

  List<BannerModel> _getDefaultBannersForCategory() {
    if (widget.apiCategory == null) return _getDefaultBanners();
    switch (widget.apiCategory!) {
      case api.BannerCategory.homepage:
        return _getDefaultBanners();
      case api.BannerCategory.job:
        return [
          const BannerModel(
            id: 'job-1',
            title: 'Find Your Perfect Job',
            subtitle: 'Browse thousands of opportunities',
            ctaText: 'Apply Now',
            backgroundColor: AppColors.green,
          ),
        ];
      case api.BannerCategory.catalog:
        return [
          const BannerModel(
            id: 'catalog-1',
            title: 'Featured Products',
            subtitle: 'Quality items from trusted artisans',
            ctaText: 'Browse',
            backgroundColor: AppColors.purple,
          ),
        ];
      case api.BannerCategory.ads:
        return [
          const BannerModel(
            id: 'ads-1',
            title: 'Special Offers',
            subtitle: 'Limited time promotions',
            ctaText: 'View Deals',
            backgroundColor: AppColors.pink,
          ),
        ];
    }
  }

  List<BannerModel> _getDefaultBanners() {
    return [
      const BannerModel(
        id: '1',
        title: 'Welcome to Artisan Circle',
        subtitle: 'Connect with opportunities',
        ctaText: 'Get Started',
        backgroundColor: AppColors.orange,
      ),
    ];
  }

  void _startAutoPlayIfNeeded() {
    if (widget.autoPlay && _banners.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && _banners.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height,
        padding: widget.padding,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
          ),
        ),
      );
    }

    if (_banners.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return Container(
      height: widget.height,
      padding: widget.padding,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _banners.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                return _BannerCard(banner: _banners[index]);
              },
            ),
          ),
          if (_banners.length > 1) ...[
            AppSpacing.spaceSM,
            _PageIndicator(
              count: _banners.length,
              currentIndex: _currentIndex,
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: banner.onTap,
      child: Container(
        margin: AppSpacing.horizontalXS,
        decoration: (() {
          final fixedUrl = sanitizeImageUrl(banner.imageUrl ?? '');
          final hasImage = fixedUrl.startsWith('http');
          return BoxDecoration(
            color: banner.backgroundColor ?? AppColors.orange,
            borderRadius: AppRadius.radiusLG,
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(fixedUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          );
        })(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusLG,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.onSurface.withValues(alpha: 0.6),
                colorScheme.surface.withValues(alpha: 0.0),
              ],
            ),
          ),
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                banner.title,
                style: context.textTheme.titleLarge?.copyWith(
                  color: banner.textColor ?? colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSpacing.spaceXS,
              Text(
                banner.subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: banner.textColor?.withValues(alpha: 0.9) ??
                      colorScheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
              if (banner.ctaText != null) ...[
                AppSpacing.spaceSM,
                Text(
                  banner.ctaText!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: banner.textColor ?? colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: 8,
          height: 8,
          margin: AppSpacing.horizontalXS,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == index
                ? AppColors.orange
                : AppColors.subtleBorder,
          ),
        ),
      ),
    );
  }
}

/// Legacy export for backward compatibility
typedef BannerCarousel = UnifiedBannerCarousel;

/// Default banners for fallback scenarios
class DefaultBanners {
  static final List<BannerModel> defaultBanners = [
    const BannerModel(
      id: '1',
      title: 'Find Your Next Project',
      subtitle: 'Browse available jobs in your area',
      ctaText: 'Explore Jobs',
      backgroundColor: AppColors.orange,
    ),
    const BannerModel(
      id: '2',
      title: 'Grow Your Skills',
      subtitle: 'Access training and resources',
      ctaText: 'Learn More',
      backgroundColor: AppColors.purple,
    ),
    const BannerModel(
      id: '3',
      title: 'Join Our Community',
      subtitle: 'Connect with fellow artisans',
      ctaText: 'Get Started',
      backgroundColor: AppColors.green,
    ),
  ];
}
