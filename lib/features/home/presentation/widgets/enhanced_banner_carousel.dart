import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/models/banner_model.dart' as api;
import 'package:artisans_circle/core/services/banner_service.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/home/presentation/widgets/banner_carousel.dart';

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
    print('🚨🚨🚨 ENHANCED BANNER CONSTRUCTOR CALLED WITH $category 🚨🚨🚨');
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
    print('🎯 🎯 🎯 ENHANCED BANNER WIDGET CREATED!!! Category: ${widget.category}');
    print('🎯 ENHANCED BANNER: Initializing for category ${widget.category}');
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    print('🎯 ENHANCED BANNER: Starting to load banners for ${widget.category}');
    
    try {
      final bannerService = getIt<BannerService>();
      print('🎯 ENHANCED BANNER: Got banner service instance');
      
      final apiResponse = await bannerService.getBanners(category: widget.category);
      print('🎯 ENHANCED BANNER: Received ${apiResponse.banners.length} banners from API');
      
      // Convert API banners to UI banners
      final uiBanners = apiResponse.banners
          .where((banner) => banner.isActive)
          .map((apiBanner) => _convertApiBannerToUiBanner(apiBanner))
          .toList();

      print('🎯 ENHANCED BANNER: Converted to ${uiBanners.length} UI banners');
      if (mounted) {
        setState(() {
          _banners = uiBanners;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🎯 ENHANCED BANNER: Error loading banners: $e');
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
    return BannerModel(
      id: apiBanner.id.toString(),
      title: apiBanner.title,
      subtitle: _getSubtitleForCategory(),
      imageUrl: apiBanner.image,
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
    print('🎯 ENHANCED BANNER: Tapped banner ${banner.title}');
    // Handle banner tap based on category
  }

  List<BannerModel> _getDefaultBannersForCategory() {
    print('🎯 ENHANCED BANNER: Using default banners for ${widget.category}');
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
    print('🎯 ENHANCED BANNER: Building with ${_banners.length} banners, loading: $_isLoading');
    
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