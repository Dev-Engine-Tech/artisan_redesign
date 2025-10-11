import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/models/banner_model.dart' as api;
import 'package:artisans_circle/core/services/banner_service.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/home/presentation/widgets/banner_carousel.dart';
import 'package:artisans_circle/core/api/endpoints.dart';

class EnhancedBannerCarousel extends StatefulWidget {
  final api.BannerCategory category;
  final double height;
  final Duration autoPlayInterval;
  final bool autoPlay;
  final EdgeInsets? padding;

  EnhancedBannerCarousel({
    super.key,
    required this.category,
    this.height = 120,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.autoPlay = true,
    this.padding,
  }) {
    if (kDebugMode) {
      debugPrint('EnhancedBanner: constructor called with $category');
    }
  }

  @override
  State<EnhancedBannerCarousel> createState() => _EnhancedBannerCarouselState();
}

class _EnhancedBannerCarouselState extends State<EnhancedBannerCarousel> {
  List<BannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('EnhancedBanner: created for category ${widget.category}');
    }
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    if (kDebugMode) {
      debugPrint('EnhancedBanner: loading banners for ${widget.category}');
    }

    try {
      final bannerService = getIt<BannerService>();
      if (kDebugMode) debugPrint('EnhancedBanner: got banner service');

      final apiResponse =
          await bannerService.getBanners(category: widget.category);
      if (kDebugMode)
        debugPrint(
            'EnhancedBanner: received ${apiResponse.banners.length} banners');

      // Convert API banners to UI banners
      var uiBanners = apiResponse.banners
          .where((banner) => banner.isActive)
          .map((apiBanner) => _convertApiBannerToUiBanner(apiBanner))
          .toList();

      // If API returns empty, fallback to defaults so the UI is never blank
      if (uiBanners.isEmpty) {
        if (kDebugMode)
          debugPrint('EnhancedBanner: empty response, using defaults');
        uiBanners = _getDefaultBannersForCategory();
      }

      if (kDebugMode)
        debugPrint(
            'EnhancedBanner: converted to ${uiBanners.length} UI banners');
      if (mounted) {
        setState(() {
          _banners = uiBanners;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('EnhancedBanner: error loading banners: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Fallback to default banners on error
          _banners = _getDefaultBannersForCategory();
        });
      }
    }
  }

  BannerModel _convertApiBannerToUiBanner(api.ApiBannerItem apiBanner) {
    String normalize(String? url) {
      if (url == null || url.isEmpty) return '';
      // Fix common backend bug: '/media/https:/...' should be 'https://...'
      if (url.startsWith('/media/https:/')) {
        return 'https://' + url.replaceFirst('/media/https:/', '');
      }
      if (url.startsWith('/media/http:/')) {
        return 'http://' + url.replaceFirst('/media/http:/', '');
      }
      if (url.startsWith('http')) return url;
      final base = ApiEndpoints.baseUrl;
      final sep = url.startsWith('/') ? '' : '/';
      return '$base$sep$url';
    }

    return BannerModel(
      id: apiBanner.id.toString(),
      title: apiBanner.title,
      subtitle: _getSubtitleForCategory(),
      imageUrl: normalize(apiBanner.image),
      ctaText: _getCtaForCategory(),
      backgroundColor: _getColorForCategory(),
      onTap: () => _handleBannerTap(apiBanner),
    );
  }

  String _getSubtitleForCategory() {
    switch (widget.category) {
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
    switch (widget.category) {
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
    switch (widget.category) {
      case api.BannerCategory.homepage:
        return AppColors.orange;
      case api.BannerCategory.job:
        return const Color(0xFF2E8B57);
      case api.BannerCategory.catalog:
        return const Color(0xFF6B4CD6);
      case api.BannerCategory.ads:
        return const Color(0xFFE91E63);
    }
  }

  void _handleBannerTap(api.ApiBannerItem banner) {
    // Handle banner tap based on category
  }

  List<BannerModel> _getDefaultBannersForCategory() {
    if (kDebugMode)
      debugPrint(
          'EnhancedBanner: using default banners for ${widget.category}');
    switch (widget.category) {
      case api.BannerCategory.homepage:
        return DefaultBanners.defaultBanners;
      case api.BannerCategory.job:
        return [
          BannerModel(
            id: 'job-1',
            title: 'Find Your Perfect Job',
            subtitle: 'Browse thousands of opportunities',
            ctaText: 'Apply Now',
            backgroundColor: const Color(0xFF2E8B57),
          ),
        ];
      case api.BannerCategory.catalog:
        return [
          BannerModel(
            id: 'catalog-1',
            title: 'Featured Products',
            subtitle: 'Quality items from trusted artisans',
            ctaText: 'Browse',
            backgroundColor: const Color(0xFF6B4CD6),
          ),
        ];
      case api.BannerCategory.ads:
        return [
          BannerModel(
            id: 'ads-1',
            title: 'Special Offers',
            subtitle: 'Limited time promotions',
            ctaText: 'View Deals',
            backgroundColor: const Color(0xFFE91E63),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode)
      debugPrint(
          'EnhancedBanner: build banners=${_banners.length} loading=$_isLoading');

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

    return BannerCarousel(
      banners: _banners,
      height: widget.height,
      autoPlayInterval: widget.autoPlayInterval,
      autoPlay: widget.autoPlay,
      padding: widget.padding,
    );
  }
}
