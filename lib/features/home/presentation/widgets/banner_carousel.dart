import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';

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

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final double height;
  final Duration autoPlayInterval;
  final bool autoPlay;
  final EdgeInsets? padding;

  const BannerCarousel({
    super.key,
    required this.banners,
    this.height = 120,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.autoPlay = false, // Disabled to avoid flakiness in tests
    this.padding,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    
    if (widget.autoPlay && widget.banners.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(widget.autoPlayInterval, () {
      if (mounted && widget.banners.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % widget.banners.length;
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
    if (widget.banners.isEmpty) {
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
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.banners.length,
              itemBuilder: (context, index) {
                final banner = widget.banners[index];
                return _buildBannerCard(banner, index);
              },
            ),
          ),
          if (widget.banners.length > 1) ...[
            const SizedBox(height: 8),
            _buildPageIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildBannerCard(BannerModel banner, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: banner.backgroundColor ?? AppColors.orange,
          child: InkWell(
            onTap: banner.onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left content
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            banner.title,
                            style: TextStyle(
                              color: banner.textColor ?? Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Flexible(
                          child: Text(
                            banner.subtitle,
                            style: TextStyle(
                              color: (banner.textColor ?? Colors.white).withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (banner.ctaText != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              banner.ctaText!,
                              style: TextStyle(
                                color: banner.textColor ?? Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Right image or placeholder
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: double.infinity,
                      margin: const EdgeInsets.only(left: 12),
                      child: banner.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                banner.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return _buildImagePlaceholder();
                                },
                              ),
                            )
                          : _buildImagePlaceholder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.white.withValues(alpha: 0.7),
        size: 32,
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.banners.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentIndex == index 
                ? AppColors.orange 
                : AppColors.orange.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

// Default banners for demo purposes
class DefaultBanners {
  static List<BannerModel> get defaultBanners => [
    BannerModel(
      id: '1',
      title: 'Discover Your Ideal\nJob Match',
      subtitle: 'Find rewarding projects, connect with clients, and take your career to new heights.',
      ctaText: 'Apply',
      backgroundColor: AppColors.orange,
      onTap: () {
        // Navigate to jobs page
      },
    ),
    BannerModel(
      id: '2',
      title: 'Artisan Tips & Best Practices',
      subtitle: 'Improve your listings and win more orders with short tips.',
      ctaText: 'Learn',
      backgroundColor: const Color(0xFF6B4CD6),
      onTap: () {
        // Navigate to tips page
      },
    ),
    BannerModel(
      id: '3',
      title: 'Featured Projects',
      subtitle: 'Browse featured projects handpicked for you.',
      ctaText: 'Explore',
      backgroundColor: const Color(0xFF2E8B57),
      onTap: () {
        // Navigate to featured projects
      },
    ),
  ];
}