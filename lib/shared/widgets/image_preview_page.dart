import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';

/// Shared full-screen image preview page
///
/// Moved from features/account/presentation/widgets to shared location
/// since it's used across multiple features
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => ImagePreviewPage(
///       imageUrl: 'https://example.com/image.jpg',
///       heroTag: 'unique-tag',
///     ),
///   ),
/// );
/// ```
class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const ImagePreviewPage({
    required this.imageUrl,
    this.heroTag,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fixed = sanitizeImageUrl(imageUrl);
    final valid = fixed.startsWith('http');
    final image = valid
        ? Image.network(
            fixed,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
          )
        : const Icon(Icons.broken_image, size: 80);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: heroTag != null ? Hero(tag: heroTag!, child: image) : image,
        ),
      ),
    );
  }
}
