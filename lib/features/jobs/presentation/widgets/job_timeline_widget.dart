import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_material_management_widget.dart';

class JobTimelineWidget extends StatelessWidget {
  final Job job;
  final ScrollController scrollController;
  final VoidCallback onStatusUpdate;

  const JobTimelineWidget({
    required this.job,
    required this.scrollController,
    required this.onStatusUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: AppSpacing.paddingXL,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownHeader,
                          ),
                    ),
                    AppSpacing.spaceXS,
                    Text(
                      'Track progress and manage project milestones',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMD,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: AppSpacing.horizontalXL,
            children: [
              _buildProjectHeader(),
              AppSpacing.spaceXL,
              _buildProgressSection(),
              AppSpacing.spaceXL,
              _buildAgreementSection(),
              AppSpacing.spaceXL,
              _buildMaterialsSection(),
              AppSpacing.spaceXL,
              _buildTimelineSection(),
              AppSpacing.spaceXL,
              _buildActionButtons(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.brownHeader,
                      ),
                    ),
                    AppSpacing.spaceXS,
                    Text(
                      job.category,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusLG,
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.spaceMD,
          Text(
            job.description,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          AppSpacing.spaceLG,
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.attach_money,
                  'Budget',
                  'NGN ${job.minBudget.toString().replaceAllMapped(
                        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                        (match) => '${match[1]},',
                      )}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.schedule,
                  'Duration',
                  job.duration,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.black54),
            AppSpacing.spaceXS,
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        AppSpacing.spaceXS,
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.brownHeader,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final progressList = job.progressUpdates ?? [];

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.orange),
              AppSpacing.spaceSM,
              const Text(
                'Progress Updates',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.brownHeader,
                ),
              ),
              const Spacer(),
              Text(
                '${progressList.length} updates',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (progressList.isEmpty) ...[
            AppSpacing.spaceLG,
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.timeline,
                    size: 48,
                    color: Colors.black26,
                  ),
                  AppSpacing.spaceSM,
                  Text(
                    'No progress updates yet',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            AppSpacing.spaceLG,
            ...progressList.map((update) => _buildProgressItem(update)),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressItem(Map<String, dynamic> update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${update['progress'] ?? 0}%',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                update['date'] ?? 'Recently',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          AppSpacing.spaceSM,
          Text(
            update['description'] ?? 'Progress update',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: AppColors.orange),
              AppSpacing.spaceSM,
              Text(
                'Agreement Details',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.brownHeader,
                ),
              ),
            ],
          ),
          AppSpacing.spaceLG,
          if (job.agreement != null) ...[
            _buildAgreementItem(
                'Amount', 'NGN ${job.agreement!.amount ?? job.minBudget}'),
            _buildAgreementItem('Status', job.agreement!.status),
            if (job.agreement!.description != null)
              _buildAgreementItem('Description', job.agreement!.description!),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: Colors.black26,
                  ),
                  AppSpacing.spaceSM,
                  Text(
                    'No agreement details available',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAgreementItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          AppSpacing.spaceSM,
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.brownHeader,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection() {
    return JobMaterialManagementWidget(
      materials: job.materials,
      readOnly: true,
      title: 'Project Materials',
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.schedule, color: AppColors.orange),
              AppSpacing.spaceSM,
              Text(
                'Project Timeline',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.brownHeader,
                ),
              ),
            ],
          ),
          AppSpacing.spaceLG,
          _buildTimelineItem(
            'Project Started',
            'Agreement accepted and work began',
            Icons.play_circle,
            true,
          ),
          _buildTimelineItem(
            'Progress Updates',
            'Regular updates submitted to client',
            Icons.update,
            job.progressUpdates?.isNotEmpty ?? false,
          ),
          _buildTimelineItem(
            'Project Completion',
            'Final delivery and payment processing',
            Icons.check_circle,
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String title, String description, IconData icon, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isCompleted ? Colors.white : Colors.grey.shade600,
            ),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isCompleted ? AppColors.brownHeader : Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Submit Progress Update',
          onPressed: () {
            Navigator.of(context).pop();
            // Show progress submission modal
          },
        ),
        AppSpacing.spaceSM,
        Row(
          children: [
            Expanded(
              child: OutlinedAppButton(
                text: 'Pause Project',
                onPressed: () => _pauseProject(context),
              ),
            ),
            AppSpacing.spaceSM,
            Expanded(
              child: OutlinedAppButton(
                text: 'Mark Complete',
                onPressed: () => _completeProject(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pauseProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pause Project'),
        content: const Text(
            'Are you sure you want to pause this project? You can resume it later.'),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextAppButton(
            text: 'Pause',
            onPressed: () {
              context.read<JobBloc>().add(PauseJobEvent(jobId: job.id));
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              onStatusUpdate();
            },
          ),
        ],
      ),
    );
  }

  void _completeProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Project'),
        content: const Text(
            'Are you sure you want to mark this project as complete? This action cannot be undone.'),
        actions: [
          TextAppButton(
            text: 'Cancel',
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextAppButton(
            text: 'Complete',
            onPressed: () {
              context.read<JobBloc>().add(CompleteJobEvent(jobId: job.id));
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              onStatusUpdate();
            },
          ),
        ],
      ),
    );
  }
}
