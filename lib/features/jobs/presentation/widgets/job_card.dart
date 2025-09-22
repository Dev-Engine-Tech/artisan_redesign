import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_details_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/theme.dart';

/// Polished job card aiming to match the provided designs:
/// - soft rounded container with subtle border
/// - left thumbnail, title/category/address, budget/duration row
/// - action row with prominent Apply button and lightweight Reviews button
class JobCard extends StatelessWidget {
  final Job job;
  final void Function()? onTap;
  final String? primaryLabel;
  final VoidCallback? primaryAction;
  final String? secondaryLabel;
  final VoidCallback? secondaryAction;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.primaryLabel,
    this.primaryAction,
    this.secondaryLabel,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final budgetText =
        '₦${job.minBudget.toString()} - ₦${job.maxBudget.toString()}';
    final titleStyle = Theme.of(context)
        .textTheme
        .titleLarge
        ?.copyWith(fontWeight: FontWeight.w600);
    final subtitleStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.subtleBorder),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.softPink,
                        image: job.thumbnailUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                    sanitizeImageUrl(job.thumbnailUrl)),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: job.thumbnailUrl.isEmpty
                          ? const Center(
                              child: Icon(Icons.home_repair_service_outlined,
                                  color: AppColors.orange, size: 28))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Title + category + address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job.title, style: titleStyle),
                          const SizedBox(height: 4),
                          Text(job.category, style: subtitleStyle),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.softPink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              job.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.brownHeader),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // menu icon
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_vert,
                          size: 20, color: Colors.black54),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // budget & duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(budgetText,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.subtleBorder),
                      ),
                      child: Text(job.duration,
                          style: Theme.of(context).textTheme.bodyMedium),
                    )
                  ],
                ),

                const SizedBox(height: 12),

                // description snippet
                Text(
                  job.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                // actions (primary larger, secondary smaller)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: primaryAction ??
                              (job.applied
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (ctx) {
                                        // Ensure pushed route has access to the same JobBloc instance.
                                        JobBloc bloc;
                                        try {
                                          bloc =
                                              BlocProvider.of<JobBloc>(context);
                                        } catch (_) {
                                          bloc = getIt<JobBloc>();
                                        }
                                        return BlocProvider.value(
                                          value: bloc,
                                          child: JobDetailsPage(job: job),
                                        );
                                      }));
                                    }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: job.applied
                                ? AppColors.darkBlue
                                : AppColors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                              primaryLabel ??
                                  (job.applied ? 'Applied' : 'Apply'),
                              style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: secondaryAction ?? () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.softPeach,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            foregroundColor: AppColors.brownHeader,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.reviews,
                                  size: 16, color: AppColors.orange),
                              const SizedBox(width: 6),
                              Text(secondaryLabel ?? 'Reviews',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.brownHeader)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
