import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme.dart';

/// Performance-optimized image widget following SOLID principles
/// Single Responsibility: Handles optimized image display with caching
/// Open/Closed: Extensible through composition and configuration
/// Interface Segregation: Provides focused interface for image display
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.heroTag,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheWidth,
    this.memCacheHeight,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final Duration fadeInDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    if (!_isValidHttpUrl(imageUrl)) {
      // Invalid URL: show error widget or placeholder gracefully
      return errorWidget ?? _buildPlaceholder(context);
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
      imageBuilder: (context, imageProvider) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            image: DecorationImage(
              image: imageProvider,
              fit: fit,
            ),
          ),
        );
      },
    );

    // Wrap with Hero widget if heroTag is provided
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  bool _isValidHttpUrl(String? url) {
    if (url == null) return false;
    final s = url.trim();
    if (!(s.startsWith('http://') || s.startsWith('https://'))) return false;
    try {
      final u = Uri.parse(s);
      return u.hasScheme && (u.scheme == 'http' || u.scheme == 'https') && u.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.error_outline,
        color: Colors.grey.shade600,
        size: (width != null && height != null)
            ? (width! < height! ? width! * 0.3 : height! * 0.3)
            : 24,
      ),
    );
  }
}

/// Avatar-specific optimized image widget
/// Follows Single Responsibility Principle
class OptimizedAvatar extends StatelessWidget {
  const OptimizedAvatar({
    required this.imageUrl,
    super.key,
    this.size = 40,
    this.initials,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.heroTag,
  });

  final String? imageUrl;
  final double size;
  final String? initials;
  final Color? backgroundColor;
  final Color textColor;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = OptimizedImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(size / 2),
        memCacheWidth: (size * MediaQuery.of(context).devicePixelRatio).round(),
        memCacheHeight:
            (size * MediaQuery.of(context).devicePixelRatio).round(),
        placeholder: _buildInitialsAvatar(context),
        errorWidget: _buildInitialsAvatar(context),
        heroTag: heroTag,
      );
    } else {
      avatar = _buildInitialsAvatar(context);
    }

    return SizedBox(
      width: size,
      height: size,
      child: avatar,
    );
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials ?? '?',
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Thumbnail image widget for lists and grids
/// Optimized for performance in scrollable views
class OptimizedThumbnail extends StatelessWidget {
  const OptimizedThumbnail({
    required this.imageUrl,
    super.key,
    this.width = 80,
    this.height = 80,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.md)),
    this.heroTag,
  });

  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    // Calculate optimal memory cache size based on device pixel ratio
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final memCacheWidth = (width * devicePixelRatio).round();
    final memCacheHeight = (height * devicePixelRatio).round();

    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      heroTag: heroTag,
      placeholder: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Icon(
            Icons.image,
            color: Colors.grey.shade400,
            size: width * 0.3,
          ),
        ),
      ),
    );
  }
}

/// Full-screen image viewer optimized for performance
/// Follows Single Responsibility Principle
class OptimizedImageViewer extends StatelessWidget {
  const OptimizedImageViewer({
    required this.imageUrl,
    super.key,
    this.heroTag,
    this.backgroundColor = Colors.black,
  });

  final String imageUrl;
  final String? heroTag;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: OptimizedImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          heroTag: heroTag,
          placeholder: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Static method to show image viewer
  static Future<void> show(
    BuildContext context, {
    required String imageUrl,
    String? heroTag,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return OptimizedImageViewer(
            imageUrl: imageUrl,
            heroTag: heroTag,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
