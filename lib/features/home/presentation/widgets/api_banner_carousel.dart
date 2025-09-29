import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/models/banner_model.dart';
import 'package:artisans_circle/core/services/banner_service.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/home/presentation/widgets/banner_carousel.dart' as original;

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiResponse = await _bannerService.getBanners(category: widget.category);
      
      // Convert API banners to UI banners
      final uiBanners = apiResponse.banners
          .where((banner) => banner.isActive)
          .map((apiBanner) => _convertApiBannerToUiBanner(apiBanner))
          .toList();

      setState(() {
        _banners = uiBanners;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
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
    switch (category) {
      case BannerCategory.homepage:
        return original.DefaultBanners.defaultBanners;
      case BannerCategory.job:
        return [
          original.BannerModel(
            id: 'job-1',
            title: 'Find Your Perfect Job',
            subtitle: 'Browse thousands of opportunities',
            ctaText: 'Apply Now',
            backgroundColor: const Color(0xFF2E8B57),
          ),
        ];
      case BannerCategory.catalog:
        return [
          original.BannerModel(
            id: 'catalog-1',
            title: 'Featured Products',
            subtitle: 'Quality items from trusted artisans',
            ctaText: 'Browse',
            backgroundColor: const Color(0xFF6B4CD6),
          ),
        ];
      case BannerCategory.ads:
        return [
          original.BannerModel(
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