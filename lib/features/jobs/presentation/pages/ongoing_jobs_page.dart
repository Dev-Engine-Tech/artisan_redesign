import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/progress_submission_modal.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_timeline_widget.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/jobs_filter_bar.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/jobs_empty_state.dart';
import 'package:artisans_circle/features/collaboration/presentation/pages/invite_collaborator_page_refactored.dart';
import 'package:artisans_circle/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:artisans_circle/core/di.dart';
import '../../../../core/utils/responsive.dart';

class OngoingJobsPage extends StatefulWidget {
  const OngoingJobsPage({super.key});

  @override
  State<OngoingJobsPage> createState() => _OngoingJobsPageState();
}

class _OngoingJobsPageState extends State<OngoingJobsPage> {
  String _filterStatus = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ PERFORMANCE FIX: Check state before loading
    final bloc = context.read<JobBloc>();
    final currentState = bloc.state;
    if (currentState is! JobStateOngoingLoaded) {
      bloc.add(LoadOngoingJobs());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lightPeachColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.0),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: context.softPinkColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Builder(
          builder: (context) => Text(
            'Ongoing Projects',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // ✅ PERFORMANCE FIX: Force refresh is intentional here
              context.read<JobBloc>().add(LoadOngoingJobs());
            },
            icon: Icon(Icons.refresh, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            JobsFilterBar(
              searchController: _searchController,
              searchQuery: _searchQuery,
              selectedFilter: _filterStatus,
              searchHint: 'Search ongoing projects...',
              filterOptions: const [
                FilterOption(label: 'All', value: 'all'),
                FilterOption(label: 'Started', value: 'inProgress'),
                FilterOption(label: 'Awaiting Client', value: 'pending_approval'),
                FilterOption(label: 'Paused', value: 'paused'),
                FilterOption(label: 'Near Deadline', value: 'urgent'),
              ],
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onSearchClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              onFilterChanged: (value) => setState(() => _filterStatus = value),
            ),
            Expanded(
              child: BlocBuilder<JobBloc, JobState>(
                builder: (context, state) {
                  if (state is JobStateLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is JobStateError) {
                    return _buildErrorState(state.message);
                  }

                  if (state is JobStateOngoingLoaded) {
                    final filteredJobs = _getFilteredJobs(state.ongoingJobs);
                    return _buildJobsList(filteredJobs);
                  }

                  return JobsEmptyState(
                    title: _searchQuery.isNotEmpty
                        ? 'No projects match your search'
                        : 'No ongoing projects',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try adjusting your search filters'
                        : 'Start working on projects to see them here',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UNUSED: Filters and search - replaced by JobsFilterBar widget
  // COMMENTED OUT: 2025-12-19 - Modularization
  // Can be safely deleted after testing
  /*
  Widget _buildFiltersAndSearch() {
    return Container(
      padding: context.responsivePadding,
      color: context.cardBackgroundColor,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: context.softBorderColor),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ongoing projects...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          AppSpacing.spaceMD,
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all'),
                AppSpacing.spaceSM,
                _buildFilterChip('Started', 'inProgress'),
                AppSpacing.spaceSM,
                _buildFilterChip('Awaiting Client', 'pending_approval'),
                AppSpacing.spaceSM,
                _buildFilterChip('Paused', 'paused'),
                AppSpacing.spaceSM,
                _buildFilterChip('Near Deadline', 'urgent'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return GestureDetector(
          onTap: () {
            setState(() {
              _filterStatus = value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? context.primaryColor : context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? context.primaryColor : context.softBorderColor,
              ),
            ),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? colorScheme.onPrimary : context.brownHeaderColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    // Method moved to JobsFilterBar widget
  }
  */

  List<Job> _getFilteredJobs(List<Job> jobs) {
    List<Job> filtered = jobs;

    if (_filterStatus != 'all') {
      filtered = filtered.where((job) {
        switch (_filterStatus) {
          case 'inProgress':
            return job.status == JobStatus.inProgress;
          case 'pending_approval':
            return job.status == JobStatus.pending;
          case 'paused':
            return job.projectStatus == AppliedProjectStatus.paused;
          case 'urgent':
            return _isNearDeadline(job);
          default:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((job) {
        return job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  bool _isNearDeadline(Job job) {
    if (job.agreement?.deadline == null) return false;
    final deadline = DateTime.parse(job.agreement!.deadline!);
    final now = DateTime.now();
    final daysUntilDeadline = deadline.difference(now).inDays;
    return daysUntilDeadline <= 3 && daysUntilDeadline >= 0;
  }

  Widget _buildJobsList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return JobsEmptyState(
        title: _searchQuery.isNotEmpty
            ? 'No projects match your search'
            : 'No ongoing projects',
        subtitle: _searchQuery.isNotEmpty
            ? 'Try adjusting your search filters'
            : 'Start working on projects to see them here',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // ✅ PERFORMANCE FIX: Force refresh is intentional here
        context.read<JobBloc>().add(LoadOngoingJobs());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return OngoingJobCard(
            job: job,
            onStatusUpdate: () {
              // ✅ PERFORMANCE FIX: Reload after status update to reflect changes
              context.read<JobBloc>().add(LoadOngoingJobs());
            },
          );
        },
      ),
    );
  }

  // UNUSED: Empty state - replaced by JobsEmptyState widget
  // COMMENTED OUT: 2025-12-19 - Modularization
  // Can be safely deleted after testing
  /*
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          AppSpacing.spaceLG,
          Text(
            _searchQuery.isNotEmpty
                ? 'No projects match your search'
                : 'No ongoing projects',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.spaceSM,
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search filters'
                : 'Start working on projects to see them here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  */

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          AppSpacing.spaceLG,
          Text(
            'Error loading projects',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.spaceSM,
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.spaceLG,
          PrimaryButton(
            text: 'Retry',
            onPressed: () {
              // ✅ PERFORMANCE FIX: Force refresh on error retry is intentional
              context.read<JobBloc>().add(LoadOngoingJobs());
            },
          ),
        ],
      ),
    );
  }
}

class OngoingJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onStatusUpdate;

  const OngoingJobCard({
    required this.job,
    required this.onStatusUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: AppRadius.radiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildContent(context),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.brownHeaderColor,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.spaceXS,
                Text(
                  job.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          AppSpacing.spaceSM,
          Builder(builder: (context) => _buildStatusBadge(context)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData icon;

    switch (job.status) {
      case JobStatus.inProgress:
        backgroundColor = isDark ? Colors.blue.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.1);
        textColor = isDark ? Colors.blue.shade200 : Colors.blue.shade700;
        statusText = 'In Progress';
        icon = Icons.work;
        break;
      case JobStatus.pending:
        backgroundColor = isDark ? Colors.orange.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.1);
        textColor = isDark ? Colors.orange.shade200 : Colors.orange.shade700;
        statusText = 'Pending Review';
        icon = Icons.pending;
        break;
      default:
        backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        textColor = Theme.of(context).colorScheme.onSurfaceVariant;
        statusText = 'Active';
        icon = Icons.work_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          AppSpacing.spaceXS,
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.spaceMD,
          _buildProgressIndicator(),
          AppSpacing.spaceMD,
          _buildProjectDetails(context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = job.progress ?? 0.0;
    final progressPercent = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => Text(
                'Progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.brownHeaderColor,
                  fontSize: 14,
                ),
              ),
            ),
            Builder(
              builder: (context) => Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.brownHeaderColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.spaceSM,
        ClipRRect(
          borderRadius: AppRadius.radiusSM,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.cardBackground,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress < 0.5 ? Colors.orange : Colors.green,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectDetails(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            Icons.attach_money,
            'NGN ${job.minBudget.toString().replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                  (match) => '${match[1]},',
                )}',
          ),
        ),
        Expanded(
          child: _buildDetailItem(
            Icons.schedule,
            job.agreement?.deadline != null
                ? _formatDeadline(job.agreement!.deadline!)
                : job.duration,
          ),
        ),
        Expanded(
          child: _buildDetailItem(
            Icons.location_on_outlined,
            job.address,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return Row(
          children: [
            Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
            AppSpacing.spaceXS,
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatDeadline(String deadline) {
    try {
      final date = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference < 0) {
        return 'Overdue';
      } else if (difference == 0) {
        return 'Due today';
      } else if (difference <= 3) {
        return '$difference days left';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return deadline;
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.softBorderColor),
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedAppButton(
                  text: 'Submit Progress',
                  onPressed: () => _showProgressSubmission(context),
                ),
              ),
              AppSpacing.spaceSM,
              Expanded(
                child: PrimaryButton(
                  text: 'View Details',
                  onPressed: () => _showJobDetails(context),
                ),
              ),
            ],
          ),
          AppSpacing.spaceSM,
          SizedBox(
            width: double.infinity,
            child: OutlinedAppButton(
              text: 'Invite Collaborator',
              icon: Icons.person_add_outlined,
              onPressed: () => _inviteCollaborator(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressSubmission(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProgressSubmissionModal(
        job: job,
        onSubmitted: () {
          Navigator.of(context).pop();
          onStatusUpdate();
        },
      ),
    );
  }

  void _showJobDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: JobTimelineWidget(
            job: job,
            scrollController: scrollController,
            onStatusUpdate: onStatusUpdate,
          ),
        ),
      ),
    );
  }

  void _inviteCollaborator(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<CollaborationBloc>(),
          child: InviteCollaboratorPageRefactored(job: job),
        ),
      ),
    );

    // Refresh if invitation was sent
    if (result == true) {
      onStatusUpdate();
    }
  }
}
