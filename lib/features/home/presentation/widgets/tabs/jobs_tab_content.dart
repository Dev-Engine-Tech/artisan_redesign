import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_card.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/home/presentation/widgets/empty_state_widget.dart';

/// Separate widget for Jobs tab following Single Responsibility Principle
class JobsTabContent extends StatelessWidget {
  const JobsTabContent({
    required this.onJobTap,
    super.key,
  });

  final Function(Job) onJobTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        if (state is JobStateLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is JobStateError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.danger),
                AppSpacing.spaceLG,
                Text(
                  'Failed to load jobs',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                AppSpacing.spaceSM,
                PrimaryButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<JobBloc>().add(LoadJobs());
                  },
                ),
              ],
            ),
          );
        }

        if (state is JobStateLoaded) {
          // Only show jobs that the artisan has NOT applied for
          final jobs = state.jobs.where((j) => !j.applied).toList();

          if (jobs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.work_outline,
              title: 'No Jobs Available',
              subtitle: 'Check back later for new opportunities',
            );
          }

          // Performance: Use ListView.builder for lazy loading with optimized scroll physics
          return ListView.builder(
            itemCount: jobs.length,
            padding: AppSpacing.verticalSM,
            physics:
                const AlwaysScrollableScrollPhysics(), // Smooth scrolling behavior
            cacheExtent: 400, // Cache more items offscreen for smoother scrolling
            addAutomaticKeepAlives:
                true, // Keep list items alive for better performance
            addRepaintBoundaries: true, // Isolate repaints for performance
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: JobCard(
                  job: job,
                  onTap: () => onJobTap(job),
                ),
              );
            },
          );
        }

        // Show loading indicator for initial/unknown states instead of blank space
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
