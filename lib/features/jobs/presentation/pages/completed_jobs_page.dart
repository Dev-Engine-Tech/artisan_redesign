import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/payment_summary_widget.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/project_review_modal.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_completion_certificate.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/completed_jobs_earnings_summary.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/jobs_filter_bar.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/jobs_empty_state.dart';
import '../../../../core/utils/responsive.dart';

class CompletedJobsPage extends StatefulWidget {
  const CompletedJobsPage({super.key});

  @override
  State<CompletedJobsPage> createState() => _CompletedJobsPageState();
}

class _CompletedJobsPageState extends State<CompletedJobsPage> {
  String _filterStatus = 'all';
  String _searchQuery = '';
  String _sortBy = 'date_desc';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ PERFORMANCE FIX: Check state before loading
    final bloc = context.read<JobBloc>();
    final currentState = bloc.state;
    if (currentState is! JobStateCompletedLoaded) {
      bloc.add(LoadCompletedJobs());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: context.lightPeachColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.0),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: context.softPinkColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'Completed Projects',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: Icon(Icons.sort, color: colorScheme.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {
              // ✅ PERFORMANCE FIX: Force refresh is intentional here
              context.read<JobBloc>().add(LoadCompletedJobs());
            },
            icon: Icon(Icons.refresh, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const CompletedJobsEarningsSummary(
              totalEarnings: '₦1,250,000',
              completedProjectsCount: 12,
              percentageIncrease: '+23%',
            ),
            JobsFilterBar(
              searchController: _searchController,
              searchQuery: _searchQuery,
              selectedFilter: _filterStatus,
              searchHint: 'Search completed projects...',
              filterOptions: const [
                FilterOption(label: 'All', value: 'all'),
                FilterOption(label: 'Paid', value: 'paid'),
                FilterOption(label: 'Pending Payment', value: 'pending_payment'),
                FilterOption(label: 'Reviewed', value: 'reviewed'),
                FilterOption(label: 'High Rating', value: 'high_rating'),
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

                  if (state is JobStateCompletedLoaded) {
                    final filteredJobs = _getFilteredJobs(state.completedJobs);
                    return _buildJobsList(filteredJobs);
                  }

                  return const JobsEmptyState(
                    title: 'No Completed Jobs',
                    subtitle: 'Your completed projects will appear here',
                    icon: Icons.work_off_outlined,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UNUSED: Earnings summary builder - replaced by CompletedJobsEarningsSummary widget
  // COMMENTED OUT: 2025-12-18 - Modularization
  // Can be safely deleted after testing
  /*
  Widget _buildEarningsSummary() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Container(
          margin: AppSpacing.paddingLG,
          padding: context.responsivePadding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.primaryColor, context.primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.radiusXL,
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: colorScheme.onPrimary,
                    size: 24,
                  ),
                  AppSpacing.spaceSM,
                  Text(
                    'Total Earnings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'This Month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              AppSpacing.spaceMD,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NGN 2,850,000',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'From 12 completed projects',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withValues(alpha: 0.2),
                      borderRadius: AppRadius.radiusLG,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                        AppSpacing.spaceXS,
                        Text(
                          '+23%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  */

  // UNUSED: Filters and search builder - replaced by CompletedJobsFilterBar widget
  // COMMENTED OUT: 2025-12-18 - Modularization
  // Can be safely deleted after testing
  /*
  Widget _buildFiltersAndSearch() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
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
                    hintText: 'Search completed projects...',
                    prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
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
                    _buildFilterChip('Paid', 'paid'),
                    AppSpacing.spaceSM,
                    _buildFilterChip('Pending Payment', 'pending_payment'),
                    AppSpacing.spaceSM,
                    _buildFilterChip('Reviewed', 'reviewed'),
                    AppSpacing.spaceSM,
                    _buildFilterChip('High Rating', 'high_rating'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    // Method moved to CompletedJobsFilterBar widget
  }
  */

  List<Job> _getFilteredJobs(List<Job> jobs) {
    List<Job> filtered =
        jobs.where((job) => job.status == JobStatus.completed).toList();

    if (_filterStatus != 'all') {
      filtered = filtered.where((job) {
        switch (_filterStatus) {
          case 'paid':
            return job.paymentStatus == 'paid';
          case 'pending_payment':
            return job.paymentStatus == 'pending';
          case 'reviewed':
            return job.clientReview != null;
          case 'high_rating':
            return (job.rating ?? 0) >= 4.0;
          default:
            return true;
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((job) {
        return job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (job.clientName
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'date_desc':
        filtered.sort((a, b) => (b.completedDate ?? DateTime.now())
            .compareTo(a.completedDate ?? DateTime.now()));
        break;
      case 'date_asc':
        filtered.sort((a, b) => (a.completedDate ?? DateTime.now())
            .compareTo(b.completedDate ?? DateTime.now()));
        break;
      case 'amount_desc':
        filtered.sort((a, b) => b.minBudget.compareTo(a.minBudget));
        break;
      case 'amount_asc':
        filtered.sort((a, b) => a.minBudget.compareTo(b.minBudget));
        break;
      case 'rating_desc':
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }

    return filtered;
  }

  Widget _buildJobsList(List<Job> jobs) {
    if (jobs.isEmpty) {
      return const JobsEmptyState(
        title: 'No Completed Jobs',
        subtitle: 'Your completed projects will appear here',
        icon: Icons.work_off_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // ✅ PERFORMANCE FIX: Force refresh is intentional here
        context.read<JobBloc>().add(LoadCompletedJobs());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return CompletedJobCard(
            job: job,
            onViewDetails: () => _showJobDetails(job),
            onViewCertificate: () => _showCompletionCertificate(job),
            onLeaveReview: () => _showReviewModal(job),
          );
        },
      ),
    );
  }

  // UNUSED: Empty state builder - replaced by CompletedJobsEmptyState widget
  // COMMENTED OUT: 2025-12-18 - Modularization
  // Can be safely deleted after testing
  /*
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          AppSpacing.spaceLG,
          Text(
            _searchQuery.isNotEmpty
                ? 'No projects match your search'
                : 'No completed projects yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          AppSpacing.spaceSM,
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search filters'
                : 'Complete projects to see them here with earnings and reviews',
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
            'Error loading completed projects',
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
              context.read<JobBloc>().add(LoadCompletedJobs());
            },
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (modalContext) => Container(
        padding: modalContext.responsivePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort by',
              style: Theme.of(modalContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: modalContext.brownHeaderColor,
                  ),
            ),
            AppSpacing.spaceLG,
            ...[
              {'label': 'Date (Newest First)', 'value': 'date_desc'},
              {'label': 'Date (Oldest First)', 'value': 'date_asc'},
              {'label': 'Amount (Highest First)', 'value': 'amount_desc'},
              {'label': 'Amount (Lowest First)', 'value': 'amount_asc'},
              {'label': 'Rating (Highest First)', 'value': 'rating_desc'},
            ].map((option) => ListTile(
                  title: Text(option['label']!),
                  leading: Radio<String>(
                    value: option['value']!,
                    groupValue: _sortBy,
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                      });
                      Navigator.of(context).pop();
                    },
                    activeColor: modalContext.primaryColor,
                  ),
                  onTap: () {
                    setState(() {
                      _sortBy = option['value']!;
                    });
                    Navigator.of(context).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showJobDetails(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentSummaryWidget(job: job),
    );
  }

  void _showCompletionCertificate(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobCompletionCertificate(job: job),
    );
  }

  void _showReviewModal(Job job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectReviewModal(job: job),
    );
  }
}

class CompletedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onViewDetails;
  final VoidCallback onViewCertificate;
  final VoidCallback onLeaveReview;

  const CompletedJobCard({
    required this.job,
    required this.onViewDetails,
    required this.onViewCertificate,
    required this.onLeaveReview,
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
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMD,
            ),
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade600,
              size: 20,
            ),
          ),
          AppSpacing.spaceMD,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.spaceXS,
                Row(
                  children: [
                    Text(
                      'Completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.spaceSM,
                    Text(
                      _formatCompletionDate(job.completedDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildPaymentBadge(),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge() {
    final isPaid = job.paymentStatus == 'paid';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusLG,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.account_balance_wallet : Icons.schedule,
            size: 12,
            color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          AppSpacing.spaceXS,
          Text(
            isPaid ? 'Paid' : 'Pending',
            style: TextStyle(
              color: isPaid ? Colors.green.shade700 : Colors.orange.shade700,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.spaceMD,
          _buildRatingSection(),
          AppSpacing.spaceMD,
          _buildProjectMetrics(context),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final rating = job.rating ?? 0.0;
    final hasReview = job.clientReview != null;

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(color: context.softBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Client Rating',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.brownHeaderColor,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (rating > 0) ...[
                    ...List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                    AppSpacing.spaceXS,
                    Text(
                      rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.brownHeaderColor,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Not rated yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (hasReview) ...[
                AppSpacing.spaceSM,
                Text(
                  job.clientReview!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectMetrics(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            Icons.attach_money,
            'Earnings',
            'NGN ${job.minBudget.toString().replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                  (match) => '${match[1]},',
                )}',
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            Icons.person,
            'Client',
            job.clientName ?? 'Private Client',
          ),
        ),
        Expanded(
          child: _buildMetricItem(
            Icons.category,
            'Category',
            job.category,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
                AppSpacing.spaceXS,
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            AppSpacing.spaceXS,
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: context.brownHeaderColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedAppButton(
              text: 'Payment Details',
              onPressed: onViewDetails,
            ),
          ),
          AppSpacing.spaceSM,
          Expanded(
            child: PrimaryButton(
              text: 'Certificate',
              onPressed: onViewCertificate,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCompletionDate(DateTime? date) {
    if (date == null) return 'Recently';
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
