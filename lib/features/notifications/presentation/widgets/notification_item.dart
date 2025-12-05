import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/notifications/domain/entities/notification.dart'
    as entities;

class NotificationItem extends StatelessWidget {
  final entities.Notification notification;
  final VoidCallback? onTap;

  const NotificationItem({
    required this.notification,
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.read ? colorScheme.surface : colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: notification.read ? colorScheme.outline.withValues(alpha: 0.2) : colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusLG,
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: _getIconColor(context),
                    size: 20,
                  ),
                ),
                AppSpacing.spaceMD,

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        notification.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: notification.read
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      AppSpacing.spaceXS,

                      // Type/Category
                      Text(
                        notification.type.displayTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getIconColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      AppSpacing.spaceSM,

                      // Time ago
                      Text(
                        notification.timeAgo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread indicator
                if (!notification.read)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case entities.NotificationType.paymentRelease:
        return Icons.payments;
      case entities.NotificationType.jobApplication:
        return Icons.work;
      case entities.NotificationType.acceptProjectAgreement:
        return Icons.handshake;
      case entities.NotificationType.requestChangeOfAgreement:
        return Icons.edit_document;
      case entities.NotificationType.cancelContract:
        return Icons.cancel;
      case entities.NotificationType.materialPayment:
        return Icons.payment;
      case entities.NotificationType.jobSubmission:
        return Icons.assignment_turned_in;
      case entities.NotificationType.loginActivity:
        return Icons.login;
      case entities.NotificationType.agreementQuote:
        return Icons.request_quote;
      case entities.NotificationType.milestoneSubmission:
        return Icons.flag;
      case entities.NotificationType.hireArtisan:
        return Icons.person_add;
      case entities.NotificationType.newAccount:
        return Icons.account_circle;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (notification.type) {
      case entities.NotificationType.paymentRelease:
        return Colors.green.shade600;
      case entities.NotificationType.jobApplication:
        return context.primaryColor;
      case entities.NotificationType.acceptProjectAgreement:
        return Colors.blue.shade600;
      case entities.NotificationType.requestChangeOfAgreement:
        return Colors.orange.shade600;
      case entities.NotificationType.cancelContract:
        return Colors.red.shade600;
      case entities.NotificationType.materialPayment:
        return Colors.purple.shade600;
      case entities.NotificationType.jobSubmission:
        return Colors.teal.shade600;
      case entities.NotificationType.loginActivity:
        return Colors.grey.shade600;
      case entities.NotificationType.agreementQuote:
        return Colors.indigo.shade600;
      case entities.NotificationType.milestoneSubmission:
        return Colors.amber.shade700;
      case entities.NotificationType.hireArtisan:
        return context.brownHeaderColor;
      case entities.NotificationType.newAccount:
        return Colors.cyan.shade600;
    }
  }

  Color _getIconBackgroundColor(BuildContext context) {
    return _getIconColor(context).withValues(alpha: 0.1);
  }
}
