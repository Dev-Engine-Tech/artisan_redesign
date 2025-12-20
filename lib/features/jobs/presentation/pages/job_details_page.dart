import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/features/jobs/domain/entities/agreement.dart';
import 'package:artisans_circle/features/jobs/domain/entities/change_request.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart'
    as domain;
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/apply_for_job_page.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/agreement_modal.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/change_request_status_modal.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_material_management_widget.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/change_request_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/ongoing_jobs_page.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/job_summary_page.dart';
import 'package:artisans_circle/core/utils/responsive.dart';
import 'package:artisans_circle/features/clients/presentation/pages/client_profile_page.dart';
import '../widgets/job_action_buttons.dart';
import '../widgets/job_client_header.dart';
import '../widgets/job_thumbnail_banner.dart';
import '../widgets/job_status_chip.dart';
import '../widgets/job_description_card.dart';
import '../widgets/job_duration_pill.dart';
import '../widgets/job_review_item.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;

  /// When true the page will auto-scroll to the reviews section after opening.
  final bool showReviews;

  const JobDetailsPage(
      {required this.job, super.key, this.showReviews = false});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  final _scrollController = ScrollController();
  final _reviewsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.showReviews) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToReviews());
    }
  }

  void _scrollToReviews() {
    final context = _reviewsKey.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(context,
        duration: const Duration(milliseconds: 400), alignment: 0.1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prefer the job data from JobBloc state if available so the page reflects live updates.
    Job job = widget.job;

    // Try to obtain the JobBloc from the widget tree; if it's not provided (e.g. caller
    // didn't wrap the route), fall back to the DI instance so the page remains functional.
    JobBloc bloc;
    try {
      bloc = BlocProvider.of<JobBloc>(context);
    } catch (_) {
      bloc = getIt<JobBloc>();
    }

    final state = bloc.state;
    List<Job> jobs = [];
    if (state is JobStateLoaded) {
      jobs = state.jobs;
    } else if (state is JobStateAppliedSuccess) {
      jobs = state.jobs;
    } else if (state is JobStateAgreementAccepted) {
      jobs = state.jobs;
    }
    if (jobs.isNotEmpty) {
      job = jobs.firstWhere((j) => j.id == widget.job.id,
          orElse: () => widget.job);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(10)),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              )
            : null,
        title:
            Text('Job Details', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: context.maxContentWidth,
            ),
            child: ListView(
              controller: _scrollController,
              padding: context.responsivePadding,
              children: [
                // Buyer info header (rounded card with avatar + view profile)
                JobClientHeader(
                  job: job,
                  onViewProfile: () {
                    // Debug logging for troubleshooting
                    // ignore: avoid_print
                    print('[JobDetails] View Profile tapped: jobId=${job.id}, clientId="${job.clientId}", clientName="${job.clientName}"');
                    final clientIdStr = job.clientId?.trim();
                    if (clientIdStr != null && clientIdStr.isNotEmpty) {
                      final clientId = int.tryParse(clientIdStr);
                      if (clientId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ClientProfilePage(clientId: clientId),
                          ),
                        );
                      } else {
                        // ignore: avoid_print
                        print('[JobDetails] Invalid client ID format: $clientIdStr');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid client ID')),
                        );
                      }
                    }
                  },
                ),

                const SizedBox(height: 14),

                // Large image banner
                JobThumbnailBanner(thumbnailUrl: job.thumbnailUrl),

                const SizedBox(height: 14),

                // Title row + price badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(job.category,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                            if (job.invitationId != null) ...[
                              const SizedBox(height: 8),
                              _buildInvitationStatusBadge(context, job),
                            ],
                          ]),
                    ),
                    AppSpacing.spaceSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                          color: AppColors.softPeach,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Price Range',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
                          const SizedBox(height: 6),
                          Text('₦${job.minBudget}k - ₦${job.maxBudget}k',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87))),
                        ],
                      ),
                    )
                  ],
                ),

                AppSpacing.spaceMD,

                // Status chip
                Align(
                  alignment: Alignment.centerLeft,
                  child: JobStatusChip(status: job.applicationStatus),
                ),

                // Duration pill
                JobDurationPill(duration: job.duration),

                const SizedBox(height: 18),

                // Description card
                JobDescriptionCard(description: job.description),

                const SizedBox(height: 18),

                // Skills
                Text('Skills',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SkillChip(label: 'Pattern Making'),
                    _SkillChip(label: 'Sewing Technique'),
                    _SkillChip(label: 'Hand Stitching'),
                    _SkillChip(label: 'Machine Operation'),
                    _SkillChip(label: 'Attention to details'),
                  ],
                ),

                const SizedBox(height: 22),

                // Application Status Section (if applied)
                if (job.applied) ...[
                  _buildApplicationStatusSection(job),
                  const SizedBox(height: 18),
                ],

                // Agreement Section (if exists)
                if (job.agreement != null) ...[
                  _buildAgreementSection(job.agreement!),
                  const SizedBox(height: 18),
                ],

                // Change Request Section (if exists)
                if (job.changeRequest != null) ...[
                  _buildChangeRequestSection(job.changeRequest!),
                  const SizedBox(height: 18),
                ],

                // Materials Section (if applied)
                if (job.applied) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppRadius.radiusLG,
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    padding: AppSpacing.paddingLG,
                    child: JobMaterialManagementWidget(
                      materials: job.materials,
                      readOnly: job.agreement != null ||
                          job.status == JobStatus.accepted,
                      title: 'Project Materials',
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // Primary job actions (dynamic by status)
                JobActionButtons(
                  job: job,
                  onAgreementView: () => _showAgreementModal(context, job.agreement!),
                ),

                AppSpacing.spaceMD,

                // Secondary action: open direct chat with job owner / client
                OutlinedAppButton(
                  text: 'Message',
                  onPressed: () {
                    final conv = domain.Conversation(
                      id: 'job_${job.id}',
                      name: 'Client',
                      jobTitle: job.title,
                      lastMessage: '',
                      lastTimestamp: DateTime.now(),
                      unreadCount: 0,
                      online: false,
                    );
                    ChatManager().goToChatScreen(
                      context: context,
                      conversation: conv,
                      job: job,
                    );
                  },
                ),

                AppSpacing.spaceXXL,

                // Reviews section (preserved)
                Container(
                  key: _reviewsKey,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.subtleBorder),
                  ),
                  padding: AppSpacing.verticalSM,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8),
                          child: Text('Reviews',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const Divider(height: 1),
                        const JobReviewItem(
                          name: 'Kate Henshaw',
                          date: 'May 02, 2025',
                          body: 'Lorem ipsum dolor sit amet consectetur. Nunc fermentum praesent a sapien. Tristique turpis aliquet non mattis neque scelerisque semper.',
                        ),
                        const Divider(height: 1),
                        const JobReviewItem(
                          name: 'John Doe',
                          date: 'Apr 25, 2025',
                          body: 'Excellent work, timely delivery and great communication.',
                        ),
                        AppSpacing.spaceSM,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: OutlinedAppButton(
                            text: 'See More (29)',
                            onPressed: () {},
                          ),
                        ),
                        AppSpacing.spaceMD,
                      ]),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UNUSED: Primary action buttons - replaced by JobActionButtons widget
  // COMMENTED OUT: 2025-12-18 - Modularization
  // Can be safely deleted after testing
  /*
  /// Dynamic primary actions for the details page based on job status
  Widget _buildPrimaryActionButtons(BuildContext context, Job job) {
    // Method moved to JobActionButtons widget
  }
  */

  /// Builds the application status section
  Widget _buildApplicationStatusSection(Job job) {
    return ExpansionTile(
      title: Text(
        'Application Status',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      backgroundColor: AppColors.cardBackground,
      collapsedBackgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: const BorderSide(color: AppColors.softBorder),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: const BorderSide(color: AppColors.softBorder),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.applicationStatus)
                          .withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusSM,
                      border: Border.all(
                        color: _getStatusColor(job.applicationStatus)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      job.applicationStatus,
                      style: TextStyle(
                        color: _getStatusColor(job.applicationStatus),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (job.proposal != null) ...[
                AppSpacing.spaceMD,
                Text(
                  'Your Proposal:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                AppSpacing.spaceXS,
                Text(
                  job.proposal!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the agreement section
  Widget _buildAgreementSection(Agreement agreement) {
    return ExpansionTile(
      title: Text(
        'Project Agreement',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      backgroundColor: AppColors.cardBackground,
      collapsedBackgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: const BorderSide(color: AppColors.softBorder),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: const BorderSide(color: AppColors.softBorder),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                  'Payment', '₦${agreement.agreedPayment.toStringAsFixed(0)}'),
              AppSpacing.spaceSM,
              _buildInfoRow(
                  'Delivery Date', _formatDate(agreement.deliveryDate)),
              if (agreement.startDate != null) ...[
                AppSpacing.spaceSM,
                _buildInfoRow('Start Date', _formatDate(agreement.startDate!)),
              ],
              AppSpacing.spaceMD,
              Text(
                'Comments:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.spaceXS,
              Text(
                agreement.comment,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
              ),
              AppSpacing.spaceLG,
              PrimaryButton(
                text: 'Review Agreement',
                onPressed: () {
                  // Open full agreement modal
                  _showAgreementModal(context, agreement);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the change request section
  Widget _buildChangeRequestSection(ChangeRequest changeRequest) {
    return ExpansionTile(
      title: Text(
        'Change Request',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      backgroundColor: AppColors.cardBackground,
      collapsedBackgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: const BorderSide(color: AppColors.softBorder),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: const BorderSide(color: AppColors.softBorder),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingLG,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proposed Changes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.spaceXS,
              Text(
                changeRequest.proposedChange,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
              ),
              AppSpacing.spaceMD,
              Text(
                'Reason:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              AppSpacing.spaceXS,
              Text(
                changeRequest.reason,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper to build info rows
  Widget _buildInvitationStatusBadge(BuildContext context, Job job) {
    String status;
    Color statusColor;

    switch (job.status) {
      case JobStatus.pending:
        status = 'Pending Invitation';
        statusColor = Theme.of(context).colorScheme.primary;
        break;
      case JobStatus.rejected:
        status = 'Invitation Declined';
        statusColor = Theme.of(context).colorScheme.error;
        break;
      case JobStatus.inProgress:
        status = 'Invitation Accepted';
        statusColor = Theme.of(context).colorScheme.tertiary;
        break;
      default:
        status = 'Invitation';
        statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                ),
          ),
        ),
      ],
    );
  }

/// Helper to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Review Agreement':
        return Colors.orange;
      case 'Change request sent':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Helper to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Shows the agreement modal
  void _showAgreementModal(BuildContext context, Agreement agreement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) => AgreementModal(
          job: widget.job,
          agreement: agreement,
        ),
      ),
    );
  }

// UNUSED: Review item builder - replaced by JobReviewItem widget
  // COMMENTED OUT: 2025-12-19 - Modularization
  // Can be safely deleted after testing
  /*
  Widget _reviewItem(
      BuildContext context, String name, String date, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: AppColors.brownHeader),
        ),
        AppSpacing.spaceMD,
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            AppSpacing.spaceXS,
            Text(date,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45))),
            AppSpacing.spaceSM,
            Text(body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54))),
          ]),
        )
      ]),
    );
  }
  */
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXL,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
