import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';

/// Discover-specific job card updated to closely match the provided design:
/// - large image banner with rounded corners
/// - title, vendor (category) below image
/// - price range badge on the right of the title row
/// - duration pill below
/// - subtle card background and rounded corners
class DiscoverJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;

  const DiscoverJobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.w700, fontSize: 20);
    final subtitleStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black45);
    final priceStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.brownHeader);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.subtleBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image banner
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: job.thumbnailUrl.isNotEmpty
                      ? Image.network(sanitizeImageUrl(job.thumbnailUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 180,
                          errorBuilder: (c, e, s) => Container(
                              color: Colors.black12,
                              child: const Icon(Icons.image_not_supported)))
                      : Container(
                          width: double.infinity,
                          height: 180,
                          color: AppColors.softPink,
                          child: const Center(
                            child: Icon(Icons.home_repair_service_outlined,
                                size: 48, color: AppColors.orange),
                          ),
                        ),
                ),

                // content area
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title row with price badge on the right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(job.title, style: titleStyle)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.softPeach,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                                'Price Range\n₦${job.minBudget}k - ₦${job.maxBudget}k',
                                textAlign: TextAlign.right,
                                style: priceStyle),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(job.category, style: subtitleStyle),
                      const SizedBox(height: 10),

                      // Duration pill that spans full width
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.softBorder),
                        ),
                        child: Text('Duration: ${job.duration}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.brownHeader)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
