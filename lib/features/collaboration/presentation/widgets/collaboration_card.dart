import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/utils/responsive.dart';
import '../../domain/entities/collaboration.dart';

/// Card widget for displaying collaboration information
class CollaborationCard extends StatelessWidget {
  final Collaboration collaboration;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const CollaborationCard({
    super.key,
    required this.collaboration,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isInvitedByMe = collaboration.myRole == CollaborationRole.mainArtisan;
    final otherArtisan =
        isInvitedByMe ? collaboration.collaborator : collaboration.mainArtisan;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsiveSpacing(16),
        vertical: context.responsiveSpacing(8),
      ),
      elevation: Responsive.cardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(12),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(12),
        ),
        child: Padding(
          padding: context.responsivePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Job title and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collaboration.job.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: context.responsiveFontSize(16),
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (collaboration.job.client != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Client: ${collaboration.job.client}',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(12),
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppSpacing.spaceSM,
                  _buildStatusBadge(context),
                ],
              ),

              AppSpacing.spaceMD,

              // Collaborator/Main artisan info
              Row(
                children: [
                  CircleAvatar(
                    radius: context.responsiveIconSize(20),
                    backgroundImage: (otherArtisan.profilePic != null &&
                            otherArtisan.profilePic!.trim().startsWith('http'))
                        ? NetworkImage(otherArtisan.profilePic!.trim())
                        : null,
                    child: (otherArtisan.profilePic == null ||
                            !otherArtisan.profilePic!.trim().startsWith('http'))
                        ? Text(
                            otherArtisan.name[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  AppSpacing.spaceSM,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherArtisan.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: context.responsiveFontSize(14),
                          ),
                        ),
                        Text(
                          otherArtisan.occupation,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(12),
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (otherArtisan.rating > 0) ...[
                    Icon(
                      Icons.star,
                      size: context.responsiveIconSize(16),
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      otherArtisan.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                ],
              ),

              AppSpacing.spaceMD,

              // Payment info
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.softPeach,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: context.responsiveIconSize(16),
                      color: AppColors.brownHeader,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      collaboration.paymentDisplay,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownHeader,
                      ),
                    ),
                    if (collaboration.expectedEarnings != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(≈₦${collaboration.expectedEarnings!.toStringAsFixed(0).replaceAllMapped(
                              RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                              (match) => '${match[1]},',
                            )})',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(12),
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              AppSpacing.spaceSM,

              // Time and message
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: context.responsiveIconSize(14),
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatRelativeTime(collaboration.createdAt),
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(12),
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              // Action buttons for pending invitations
              if (collaboration.canRespond) ...[
                AppSpacing.spaceMD,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    AppSpacing.spaceSM,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    String label;

    switch (collaboration.status) {
      case CollaborationStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case CollaborationStatus.accepted:
        color = Colors.green;
        label = 'Active';
        break;
      case CollaborationStatus.rejected:
        color = Colors.red;
        label = 'Declined';
        break;
      case CollaborationStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        break;
      case CollaborationStatus.cancelled:
        color = Colors.grey;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: context.responsiveFontSize(12),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Format relative time without timeago package
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
