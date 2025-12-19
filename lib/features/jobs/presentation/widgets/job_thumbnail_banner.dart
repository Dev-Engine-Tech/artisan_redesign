import 'package:flutter/material.dart';
import '../../../../core/image_url.dart';
import '../../../../core/theme.dart';

/// Job thumbnail banner widget
///
/// Displays:
/// - Large image banner (200px height)
/// - Network image with error fallback
/// - Placeholder icon for invalid URLs
class JobThumbnailBanner extends StatelessWidget {
  final String? thumbnailUrl;

  const JobThumbnailBanner({
    this.thumbnailUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: (() {
        final imgUrl = sanitizeImageUrl(thumbnailUrl);
        final valid = imgUrl.startsWith('http');
        return valid
            ? Image.network(
                imgUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 200,
                  color: AppColors.softPink,
                  child: const Center(
                    child: Icon(Icons.image),
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                height: 200,
                color: AppColors.softPink,
                child: const Center(
                  child: Icon(
                    Icons.home_repair_service_outlined,
                    size: 56,
                    color: AppColors.orange,
                  ),
                ),
              );
      })(),
    );
  }
}
