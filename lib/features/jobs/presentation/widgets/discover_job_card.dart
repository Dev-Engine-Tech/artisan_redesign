import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/services/job_share_service.dart';

/// Discover-specific job card updated to closely match the provided design:
/// - large image banner with rounded corners
/// - title, vendor (category) below image
/// - price range badge on the right of the title row
/// - duration pill below
/// - subtle card background and rounded corners
class DiscoverJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool showShareButton;
  final VoidCallback? onShare;
  final bool showSaveButton;
  final VoidCallback? onSave;

  const DiscoverJobCard({
    super.key,
    required this.job,
    this.onTap,
    this.showShareButton = true,
    this.onShare,
    this.showSaveButton = true,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 20);
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black45);
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
                // Image banner with overlay actions
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: job.thumbnailUrl.isNotEmpty
                          ? Image.network(
                              sanitizeImageUrl(job.thumbnailUrl),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 180,
                              errorBuilder: (c, e, s) => _buildSubtlePlaceholder(context),
                            )
                          : _buildSubtlePlaceholder(context),
                    ),

                    // Top right actions
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showShareButton) ...[
                            _buildActionButton(
                              icon: Icons.share_outlined,
                              onTap: () {
                                if (onShare != null) {
                                  onShare!();
                                } else {
                                  JobShareService.shareJob(job);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (showSaveButton)
                            _buildActionButton(
                              icon: Icons.bookmark_border,
                              onTap: onSave,
                            ),
                        ],
                      ),
                    ),

                    // Posted time badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getTimeAgo(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // content area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.softPeach,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                                job.minBudget == job.maxBudget
                                    ? 'Price\n₦${job.maxBudget.toStringAsFixed(0)}'
                                    : 'Price Range\n₦${job.minBudget.toStringAsFixed(0)} - ₦${job.maxBudget.toStringAsFixed(0)}',
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  Widget _buildActionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.brownHeader,
        ),
      ),
    );
  }

  String _getTimeAgo() {
    // Since the Job entity doesn't have a createdAt field,
    // we'll return a placeholder for now
    // In a real implementation, this would calculate time difference
    return 'Posted recently';
  }

  // Subtle avatar placeholder for when there's no thumbnail
  Widget _buildSubtlePlaceholder(BuildContext context) {
    final bg = Colors.grey.shade200;
    final avatarBg = Colors.grey.shade400;
    String initial = 'J';
    final trimmed = job.title.trim();
    if (trimmed.isNotEmpty) {
      initial = trimmed[0].toUpperCase();
    }
    return Container(
      width: double.infinity,
      height: 180,
      color: bg,
      child: Center(
        child: CircleAvatar(
          radius: 32,
          backgroundColor: avatarBg,
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
