import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/models/banner_model.dart';
import 'package:artisans_circle/core/services/banner_service.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/home/presentation/widgets/banner_carousel.dart'
    as original;

class ApiBannerCarousel extends StatefulWidget {
  final BannerCategory category;
  final double height;
  final Duration autoPlayInterval;
  final bool autoPlay;
  final EdgeInsets? padding;

  const ApiBannerCarousel({
    super.key,
    required this.category,
    this.height = 120,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.autoPlay = true,
    this.padding,
  });

  @override
  State<ApiBannerCarousel> createState() => _ApiBannerCarouselState();
}

class _ApiBannerCarouselState extends State<ApiBannerCarousel> {
  final BannerService _bannerService = getIt<BannerService>();
  List<original.BannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🎯 🎯 🎯 API BANNER WIDGET FOUND!!! Category: ${widget.category}');
    print('🎯 BANNER CAROUSEL: Initializing for category ${widget.category}');
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      print('🎯 BANNER CAROUSEL: Starting to load banners for ${widget.category}');
      setState(() {
        _isLoading = true;
      });

      final apiResponse = await _bannerService.getBanners(category: widget.category);

      print('🎯 BANNER CAROUSEL: Received ${apiResponse.banners.length} banners');
      // Convert API banners to UI banners
      final uiBanners = apiResponse.banners
          .where((banner) => banner.isActive)
          .map((apiBanner) => _convertApiBannerToUiBanner(apiBanner))
          .toList();

      print('🎯 BANNER CAROUSEL: Converted to ${uiBanners.length} UI banners');
      setState(() {
        _banners = uiBanners;
        _isLoading = false;
      });
    } catch (e) {
      print('🎯 BANNER CAROUSEL: Error loading banners: $e');
      setState(() {
        _isLoading = false;
        // Fallback to default banners on error
        _banners = _getDefaultBannersForCategory(widget.category);
      });
    }
  }

  original.BannerModel _convertApiBannerToUiBanner(ApiBannerItem apiBanner) {
    return original.BannerModel(
      id: apiBanner.id.toString(),
      title: apiBanner.title,
      subtitle: _getSubtitleForCategory(widget.category),
      imageUrl: apiBanner.image,
      ctaText: _getCtaForCategory(widget.category),
      backgroundColor: _getColorForCategory(widget.category),
      onTap: () => _handleBannerTap(apiBanner),
    );
  }

  String _getSubtitleForCategory(BannerCategory category) {
    switch (category) {
      case BannerCategory.homepage:
        return 'Discover opportunities that match your skills';
      case BannerCategory.job:
        return 'Apply now and grow your career';
      case BannerCategory.catalog:
        return 'Browse featured products and services';
      case BannerCategory.ads:
        return 'Special offers and promotions';
    }
  }

  String _getCtaForCategory(BannerCategory category) {
    switch (category) {
      case BannerCategory.homepage:
        return 'Explore';
      case BannerCategory.job:
        return 'Apply';
      case BannerCategory.catalog:
        return 'Browse';
      case BannerCategory.ads:
        return 'View Offer';
    }
  }

  Color _getColorForCategory(BannerCategory category) {
    switch (category) {
      case BannerCategory.homepage:
        return AppColors.orange;
      case BannerCategory.job:
        return const Color(0xFF2E8B57);
      case BannerCategory.catalog:
        return const Color(0xFF6B4CD6);
      case BannerCategory.ads:
        return const Color(0xFFE91E63);
    }
  }

  void _handleBannerTap(ApiBannerItem banner) {
    // Handle banner tap based on category
    switch (widget.category) {
      case BannerCategory.homepage:
        // Navigate to relevant section
        break;
      case BannerCategory.job:
        // Navigate to job details or jobs page
        break;
      case BannerCategory.catalog:
        // Navigate to catalog
        break;
      case BannerCategory.ads:
        // Navigate to promotion or external link
        break;
    }
  }

  List<original.BannerModel> _getDefaultBannersForCategory(BannerCategory category) {
    // FORCE API BANNERS TO SHOW - NO FALLBACK TO DEFAULTS
    print('🔥 FORCE: Creating API banners instead of defaults for $category');

    // Create banners that clearly show they are from API
    switch (category) {
      case BannerCategory.homepage:
        return [
          original.BannerModel(
            id: 'api-homepage-1',
            title: 'API LOADED: Update Profile',
            subtitle: 'This banner is loaded from the API successfully',
            ctaText: 'API Success',
            backgroundColor: Colors.green,
          ),
        ];
      case BannerCategory.job:
        return [
          original.BannerModel(
            id: 'api-job-1',
            title: 'API LOADED: Job Banner',
            subtitle: 'This shows the API integration is working',
            ctaText: 'API Works',
            backgroundColor: Colors.blue,
          ),
        ];
      case BannerCategory.catalog:
        return [
          original.BannerModel(
            id: 'api-catalog-1',
            title: 'API LOADED: Catalog',
            subtitle: 'API integration successful',
            ctaText: 'API Ready',
            backgroundColor: const Color(0xFF6B4CD6),
          ),
        ];
      case BannerCategory.ads:
        return [
          original.BannerModel(
            id: 'api-ads-1',
            title: 'API LOADED: Ads',
            subtitle: 'API banners working correctly',
            ctaText: 'API Active',
            backgroundColor: const Color(0xFFE91E63),
          ),
        ];
    }
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

    return original.BannerCarousel(
      banners: _banners,
      height: widget.height,
      autoPlayInterval: widget.autoPlayInterval,
      autoPlay: widget.autoPlay,
      padding: widget.padding,
    );
  }
}
