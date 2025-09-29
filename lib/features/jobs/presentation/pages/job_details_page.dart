import 'package:flutter/material.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job_status.dart';
import 'package:artisans_circle/features/jobs/domain/entities/agreement.dart';
import 'package:artisans_circle/features/jobs/domain/entities/change_request.dart';
import 'package:artisans_circle/features/jobs/domain/entities/material.dart' as job_entities;
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart' as domain;
import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/jobs/presentation/pages/apply_for_job_page.dart';
import 'package:artisans_circle/features/jobs/presentation/bloc/job_bloc.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/agreement_modal.dart';
import 'package:artisans_circle/features/jobs/presentation/widgets/job_material_management_widget.dart';
import 'package:artisans_circle/core/di.dart';

class JobDetailsPage extends StatefulWidget {
  final Job job;

  /// When true the page will auto-scroll to the reviews section after opening.
  final bool showReviews;

  const JobDetailsPage(
      {super.key, required this.job, this.showReviews = false});

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
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title:
            const Text('Job Details', style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Buyer info header (rounded card with avatar + view profile)
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    child:
                        const Icon(Icons.person, color: AppColors.brownHeader),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Uwak Daniel',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('@danuwk',
                            style: TextStyle(color: Colors.black45)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF213447),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('View Profile'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Large image banner
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: job.thumbnailUrl.isNotEmpty
                  ? Image.network(sanitizeImageUrl(job.thumbnailUrl),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          height: 200,
                          color: AppColors.softPink,
                          child: const Center(child: Icon(Icons.image))))
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: AppColors.softPink,
                      child: const Center(
                          child: Icon(Icons.home_repair_service_outlined,
                              size: 56, color: AppColors.orange)),
                    ),
            ),

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
                                ?.copyWith(color: Colors.black45)),
                      ]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                              ?.copyWith(color: Colors.black45)),
                      const SizedBox(height: 6),
                      Text('₦${job.minBudget}k - ₦${job.maxBudget}k',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87)),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),

            // Duration pill
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

            const SizedBox(height: 18),

            // Description card
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(
                      job.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                  ]),
            ),

            const SizedBox(height: 18),

            // Skills
            Text('Skills',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.subtleBorder),
                ),
                padding: const EdgeInsets.all(16),
                child: JobMaterialManagementWidget(
                  materials: job.materials,
                  readOnly: job.agreement != null || job.status == JobStatus.accepted,
                  title: 'Project Materials',
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Primary job actions
            ElevatedButton(
              onPressed: () {
                // Provide the current JobBloc to the apply sheet so ApplyForJobPage's
                // BlocListener and context.read<JobBloc>() calls succeed.
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (c) {
                    // Use the bloc we obtained above (falling back to DI if necessary)
                    JobBloc sheetBloc;
                    try {
                      sheetBloc = BlocProvider.of<JobBloc>(context);
                    } catch (_) {
                      sheetBloc = getIt<JobBloc>();
                    }

                    return DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.92,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      builder: (_, controller) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: BlocProvider.value(
                          value: sheetBloc,
                          child: ApplyForJobPage(job: job),
                        ),
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A4B20), // brown accent reused
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 12),

            // Secondary action: open direct chat with job owner / client
            ElevatedButton.icon(
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
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Message', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.softPink,
                foregroundColor: AppColors.brownHeader,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 24),

            // Reviews section (preserved)
            Container(
              key: _reviewsKey,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Text('Reviews',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const Divider(height: 1),
                    _reviewItem(context, 'Kate Henshaw', 'May 02, 2025',
                        'Lorem ipsum dolor sit amet consectetur. Nunc fermentum praesent a sapien. Tristique turpis aliquet non mattis neque scelerisque semper.'),
                    const Divider(height: 1),
                    _reviewItem(context, 'John Doe', 'Apr 25, 2025',
                        'Excellent work, timely delivery and great communication.'),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softPink,
                          foregroundColor: AppColors.brownHeader,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('See More'),
                            SizedBox(width: 8),
                            Text('29',
                                style: TextStyle(
                                    backgroundColor: Color(0xFFE9692D),
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ]),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.softBorder),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.softBorder),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.applicationStatus).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(job.applicationStatus).withValues(alpha: 0.3),
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
                const SizedBox(height: 12),
                Text(
                  'Your Proposal:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.proposal!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.softBorder),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.softBorder),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Payment', '₦${agreement.agreedPayment.toStringAsFixed(0)}'),
              const SizedBox(height: 8),
              _buildInfoRow('Delivery Date', _formatDate(agreement.deliveryDate)),
              if (agreement.startDate != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow('Start Date', _formatDate(agreement.startDate!)),
              ],
              const SizedBox(height: 12),
              Text(
                'Comments:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                agreement.comment,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Open full agreement modal
                    _showAgreementModal(context, agreement);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Review Agreement'),
                ),
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.softBorder),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.softBorder),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Proposed Changes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                changeRequest.proposedChange,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reason:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                changeRequest.reason,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  /// Helper to build info rows
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
              color: Colors.black54,
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
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(date,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black45)),
            const SizedBox(height: 8),
            Text(body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black54)),
          ]),
        )
      ]),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
