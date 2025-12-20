import 'package:flutter/material.dart';
import '../../domain/entities/client_profile.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/image_url.dart';

class ClientReviewItem extends StatelessWidget {
  final ClientReview review;

  const ClientReviewItem({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = sanitizeImageUrl(review.rater.profilePicUrl);
    final hasAvatar = avatarUrl.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.orange.withValues(alpha: 0.1),
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: !hasAvatar
                    ? const Icon(
                        Icons.person,
                        color: AppColors.orange,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.rater.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      review.timeAgo,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Review comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            AppSpacing.spaceXS,
            Text(
              review.comment!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
