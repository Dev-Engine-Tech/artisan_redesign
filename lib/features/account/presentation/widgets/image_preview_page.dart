import 'package:flutter/material.dart';
import '../../../../core/image_url.dart';

class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  const ImagePreviewPage({required this.imageUrl, super.key, this.heroTag});

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
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: InteractiveViewer(
          child: heroTag != null ? Hero(tag: heroTag!, child: image) : image,
        ),
      ),
    );
  }
}
