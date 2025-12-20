import 'package:flutter/material.dart';
import '../../domain/entities/client_profile.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';

class ClientRatingStats extends StatelessWidget {
  final RatingStats ratingStats;

  const ClientRatingStats({
    super.key,
    required this.ratingStats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Star icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star,
              color: AppColors.orange,
              size: 28,
            ),
          ),
          AppSpacing.spaceMD,

          // Rating details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ratingStats.averageRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(width: 8),
                    // Star rating display
                    ...List.generate(5, (index) {
                      final rating = ratingStats.averageRating;
                      if (index < rating.floor()) {
                        return const Icon(Icons.star, color: AppColors.orange, size: 16);
                      } else if (index < rating && rating % 1 != 0) {
                        return const Icon(Icons.star_half, color: AppColors.orange, size: 16);
                      } else {
                        return Icon(Icons.star_border, color: Colors.grey.shade400, size: 16);
                      }
                    }),
                  ],
                ),
                AppSpacing.spaceXS,
                Text(
                  '${ratingStats.totalRatings} ${ratingStats.totalRatings == 1 ? 'review' : 'reviews'}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
