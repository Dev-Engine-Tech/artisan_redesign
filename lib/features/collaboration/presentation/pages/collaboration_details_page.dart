import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/image_url.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/core/utils/responsive.dart';
import '../../domain/entities/collaboration.dart';
import '../../domain/entities/artisan_profile.dart';
import '../../domain/repositories/collaboration_repository.dart';
import '../bloc/collaboration_bloc.dart';
import '../bloc/collaboration_event.dart';
import '../bloc/collaboration_state.dart';
import '../widgets/collaboration_status_badge.dart';

/// Detailed view of a collaboration with full job and artisan information
class CollaborationDetailsPage extends StatelessWidget {
  final Collaboration collaboration;

  const CollaborationDetailsPage({
    super.key,
    required this.collaboration,
  });

  @override
  Widget build(BuildContext context) {
    final isInvitedByMe = collaboration.myRole == CollaborationRole.mainArtisan;
    final otherArtisan =
        isInvitedByMe ? collaboration.collaborator : collaboration.mainArtisan;
    final canRespond = collaboration.canRespond;

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
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Collaboration Details',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: BlocListener<CollaborationBloc, CollaborationState>(
        listener: (context, state) {
          if (state is CollaborationResponseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.action == CollaborationAction.accept
                      ? 'Collaboration accepted successfully!'
                      : 'Collaboration declined',
                ),
              ),
            );
            // Navigate back after successful response
            Navigator.of(context).pop(true);
          } else if (state is CollaborationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: context.maxContentWidth),
              child: ListView(
                padding: context.responsivePadding,
                children: [
                  // Status Badge
                  CollaborationStatusBadge(status: collaboration.status),

                  AppSpacing.spaceLG,

                  // Job Information Card
                  _buildJobInfoCard(context),

                  AppSpacing.spaceLG,

                  // Artisan Information Card
                  _buildArtisanInfoCard(context, otherArtisan, isInvitedByMe),

                  AppSpacing.spaceLG,

                  // Payment Information Card
                  _buildPaymentInfoCard(context),

                  AppSpacing.spaceLG,

                  // Timeline Information
                  _buildTimelineCard(context),

                  if (collaboration.message != null &&
                      collaboration.message!.isNotEmpty) ...[
                    AppSpacing.spaceLG,
                    _buildMessageCard(context),
                  ],

                  // Action Buttons (only for pending invitations)
                  if (canRespond) ...[
                    AppSpacing.spaceXL,
                    _buildActionButtons(context),
                  ],

                  AppSpacing.spaceXL,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

// UNUSED: Status badge builder - replaced by CollaborationStatusBadge widget
  // COMMENTED OUT: 2025-12-19 - Modularization
  /*
  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (collaboration.status) {
      case CollaborationStatus.pending:
        color = Colors.orange;
        label = 'Pending Response';
        icon = Icons.pending_outlined;
        break;
      case CollaborationStatus.accepted:
        color = Colors.green;
        label = 'Active Collaboration';
        icon = Icons.check_circle_outline;
        break;
      case CollaborationStatus.rejected:
        color = Colors.red;
        label = 'Declined';
        icon = Icons.cancel_outlined;
        break;
      case CollaborationStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        icon = Icons.task_alt;
        break;
      case CollaborationStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
  */

  Widget _buildJobInfoCard(BuildContext context) {
    final job = collaboration.job;

    return Container(
      padding: context.responsivePadding,
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
              Icon(
                Icons.work_outline,
                color: AppColors.orange,
                size: context.responsiveIconSize(24),
              ),
              const SizedBox(width: 8),
              const Text(
                'Job Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownHeader,
                ),
              ),
            ],
          ),
          AppSpacing.spaceMD,
          _buildInfoRow(
            context,
            'Job Title',
            job.title,
            Icons.title,
          ),
          if (job.client != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Client',
              job.client!,
              Icons.person_outline,
            ),
          ],
          if (job.budget != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Job Budget',
              'NGN ${_formatPrice(job.budget!)}',
              Icons.attach_money,
            ),
          ],
          if (job.location != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Location',
              job.location!,
              Icons.location_on_outlined,
            ),
          ],
          if (job.startDate != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Start Date',
              _formatDate(job.startDate!),
              Icons.calendar_today_outlined,
            ),
          ],
          if (job.deadline != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Deadline',
              _formatDate(job.deadline!),
              Icons.event_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArtisanInfoCard(
    BuildContext context,
    ArtisanProfile artisan,
    bool isInvitedByMe,
  ) {
    return Container(
      padding: context.responsivePadding,
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
              Icon(
                Icons.person_outline,
                color: AppColors.orange,
                size: context.responsiveIconSize(24),
              ),
              const SizedBox(width: 8),
              Text(
                isInvitedByMe ? 'Collaborator' : 'Main Artisan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownHeader,
                ),
              ),
            ],
          ),
          AppSpacing.spaceMD,
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: (() {
                  final fixed = sanitizeImageUrl(artisan.profilePic);
                  return fixed.startsWith('http') ? NetworkImage(fixed) : null;
                })(),
                child: (artisan.profilePic == null ||
                        !sanitizeImageUrl(artisan.profilePic)
                            .startsWith('http'))
                    ? Text(
                        artisan.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artisan.occupation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    if (artisan.rating > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            artisan.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (artisan.location != null) ...[
            AppSpacing.spaceMD,
            _buildInfoRow(
              context,
              'Location',
              artisan.location!,
              Icons.location_on_outlined,
            ),
          ],
          if (artisan.phone != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Phone',
              artisan.phone!,
              Icons.phone_outlined,
            ),
          ],
          if (artisan.email != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Email',
              artisan.email!,
              Icons.email_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
      decoration: BoxDecoration(
        color: AppColors.softPeach,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                color: AppColors.brownHeader,
                size: context.responsiveIconSize(24),
              ),
              const SizedBox(width: 8),
              const Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownHeader,
                ),
              ),
            ],
          ),
          AppSpacing.spaceMD,
          _buildInfoRow(
            context,
            'Payment Method',
            collaboration.paymentMethod == PaymentMethod.percentage
                ? 'Percentage of earnings'
                : 'Fixed amount',
            Icons.account_balance_wallet_outlined,
            valueColor: AppColors.brownHeader,
          ),
          AppSpacing.spaceSM,
          _buildInfoRow(
            context,
            'Payment Amount',
            collaboration.paymentDisplay,
            Icons.attach_money,
            valueColor: AppColors.brownHeader,
          ),
          if (collaboration.expectedEarnings != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Expected Earnings',
              'NGN ${_formatPrice(collaboration.expectedEarnings!)}',
              Icons.account_balance_outlined,
              valueColor: Colors.green.shade700,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
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
              Icon(
                Icons.timeline,
                color: AppColors.orange,
                size: context.responsiveIconSize(24),
              ),
              const SizedBox(width: 8),
              const Text(
                'Timeline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownHeader,
                ),
              ),
            ],
          ),
          AppSpacing.spaceMD,
          _buildInfoRow(
            context,
            'Invited',
            _formatRelativeTime(collaboration.createdAt),
            Icons.schedule,
          ),
          if (collaboration.expiresAt != null) ...[
            AppSpacing.spaceSM,
            _buildInfoRow(
              context,
              'Expires',
              _formatRelativeTime(collaboration.expiresAt!),
              Icons.alarm,
              valueColor: collaboration.isExpired ? Colors.red : Colors.black87,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context) {
    return Container(
      padding: context.responsivePadding,
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
              Icon(
                Icons.message_outlined,
                color: AppColors.orange,
                size: context.responsiveIconSize(24),
              ),
              const SizedBox(width: 8),
              const Text(
                'Message',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownHeader,
                ),
              ),
            ],
          ),
          AppSpacing.spaceMD,
          Text(
            collaboration.message!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.black54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Accept Collaboration',
          onPressed: () {
            context.read<CollaborationBloc>().add(
                  RespondToCollaborationEvent(
                    collaborationId: collaboration.id,
                    action: CollaborationAction.accept,
                  ),
                );
          },
        ),
        AppSpacing.spaceMD,
        OutlinedAppButton(
          text: 'Decline',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Decline Collaboration'),
                content: const Text(
                  'Are you sure you want to decline this collaboration invite? This action cannot be undone.',
                ),
                actions: [
                  TextAppButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  TextAppButton(
                    text: 'Decline',
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.read<CollaborationBloc>().add(
                            RespondToCollaborationEvent(
                              collaborationId: collaboration.id,
                              action: CollaborationAction.reject,
                            ),
                          );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
