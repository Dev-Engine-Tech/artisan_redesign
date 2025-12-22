import 'package:flutter/material.dart';
import '../../domain/entities/client_profile.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../jobs/domain/entities/job.dart';

class ClientJobsSection extends StatefulWidget {
  final ClientJobs jobs;

  const ClientJobsSection({
    super.key,
    required this.jobs,
  });

  @override
  State<ClientJobsSection> createState() => _ClientJobsSectionState();
}

class _ClientJobsSectionState extends State<ClientJobsSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jobs',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        AppSpacing.spaceSM,

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildTab(
                'Recent',
                0,
                widget.jobs.recent.length,
              ),
              _buildTab(
                'Ongoing',
                1,
                widget.jobs.ongoing.length,
              ),
              _buildTab(
                'Completed',
                2,
                widget.jobs.completed.length,
              ),
            ],
          ),
        ),
        AppSpacing.spaceMD,

        // Job list
        _buildJobList(),
      ],
    );
  }

  Widget _buildTab(String label, int index, int count) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  color: isSelected ? AppColors.orange : Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isSelected ? AppColors.orange : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobList() {
    final jobs = _selectedTab == 0
        ? widget.jobs.recent
        : _selectedTab == 1
            ? widget.jobs.ongoing
            : widget.jobs.completed;

    if (jobs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.work_outline,
                size: 48,
                color: Colors.grey.shade400,
              ),
              AppSpacing.spaceSM,
              Text(
                'No ${_selectedTab == 0 ? 'recent' : _selectedTab == 1 ? 'ongoing' : 'completed'} jobs',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: jobs.map((job) => _buildJobItem(job)).toList(),
    );
  }

  Widget _buildJobItem(Job job) {
    final budgetText = 'NGN ${job.minBudget} - ${job.maxBudget}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getStatusColor(job.status.name).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  job.status.name,
                  style: TextStyle(
                    color: _getStatusColor(job.status.name),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (job.description.isNotEmpty) ...[
            AppSpacing.spaceXS,
            Text(
              job.description,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          AppSpacing.spaceXS,
          Row(
            children: [
              const Icon(Icons.payments_outlined,
                  size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                budgetText,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: Colors.black54)),
              ),
              const Icon(Icons.access_time, size: 14, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                job.duration,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.green;
      case 'ongoing':
      case 'in progress':
        return AppColors.orange;
      case 'pending':
        return AppColors.amber;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.grey;
    }
  }
}
