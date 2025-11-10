import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';

enum ApplicationActionType {
  accepted,
  rejected,
  changeRequested,
  inProgress,
  completed,
}

class ApplicationStatusModal extends StatelessWidget {
  final Job job;
  final ApplicationActionType actionType;
  final String? additionalMessage;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const ApplicationStatusModal({
    required this.job,
    required this.actionType,
    super.key,
    this.additionalMessage,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingXXL,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Status icon
          _buildStatusIcon(),

          AppSpacing.spaceXL,

          // Title and message
          _buildContent(context),

          AppSpacing.spaceXXL,

          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    Widget icon;
    Color backgroundColor;

    switch (actionType) {
      case ApplicationActionType.accepted:
        icon = const Icon(Icons.check_circle, size: 60, color: Colors.white);
        backgroundColor = Colors.green.shade500;
        break;
      case ApplicationActionType.rejected:
        icon = const Icon(Icons.cancel, size: 60, color: Colors.white);
        backgroundColor = Colors.red.shade500;
        break;
      case ApplicationActionType.changeRequested:
        icon = const Icon(Icons.edit_note, size: 60, color: Colors.white);
        backgroundColor = Colors.orange.shade500;
        break;
      case ApplicationActionType.inProgress:
        icon = const Icon(Icons.work, size: 60, color: Colors.white);
        backgroundColor = Colors.blue.shade500;
        break;
      case ApplicationActionType.completed:
        icon = const Icon(Icons.task_alt, size: 60, color: Colors.white);
        backgroundColor = Colors.green.shade600;
        break;
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: icon,
    );
  }

  Widget _buildContent(BuildContext context) {
    String title;
    String message;

    switch (actionType) {
      case ApplicationActionType.accepted:
        title = 'Application Accepted!';
        message = additionalMessage ??
            'Congratulations! Your application has been accepted. You can now proceed with the project agreement.';
        break;
      case ApplicationActionType.rejected:
        title = 'Application Declined';
        message = additionalMessage ??
            'Unfortunately, your application was not selected for this project. Don\'t give up - there are many other opportunities!';
        break;
      case ApplicationActionType.changeRequested:
        title = 'Changes Requested';
        message = additionalMessage ??
            'The client has requested some changes to your proposal. Please review and update your application accordingly.';
        break;
      case ApplicationActionType.inProgress:
        title = 'Project In Progress';
        message = additionalMessage ??
            'Great! Your project is now in progress. Keep the client updated on your progress and deliverables.';
        break;
      case ApplicationActionType.completed:
        title = 'Project Completed!';
        message = additionalMessage ??
            'Congratulations! You have successfully completed this project. Payment will be processed according to the agreement.';
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brownHeader,
              ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.spaceMD,
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ),

        // Job info
        AppSpacing.spaceXL,
        Container(
          padding: AppSpacing.paddingLG,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.radiusLG,
            border: Border.all(color: AppColors.softBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownHeader,
                    ),
              ),
              AppSpacing.spaceXS,
              Text(
                job.category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
              ),
              AppSpacing.spaceSM,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  Text(
                    'NGN ${job.minBudget.toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                          (match) => '${match[1]},',
                        )}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brownHeader,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    List<Widget> buttons = [];

    switch (actionType) {
      case ApplicationActionType.accepted:
        buttons = [
          if (onSecondaryAction != null)
            Expanded(
              child: OutlinedAppButton(
                text: 'View Details',
                onPressed: onSecondaryAction,
              ),
            ),
          if (onSecondaryAction != null) AppSpacing.spaceMD,
          Expanded(
            child: PrimaryButton(
              text: 'Start Project',
              onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(),
            ),
          ),
        ];
        break;

      case ApplicationActionType.rejected:
        buttons = [
          PrimaryButton(
            text: 'Find Other Jobs',
            onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(),
          ),
        ];
        break;

      case ApplicationActionType.changeRequested:
        buttons = [
          Expanded(
            child: OutlinedAppButton(
              text: 'Later',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          AppSpacing.spaceMD,
          Expanded(
            child: PrimaryButton(
              text: 'View Changes',
              onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(),
            ),
          ),
        ];
        break;

      case ApplicationActionType.inProgress:
      case ApplicationActionType.completed:
        buttons = [
          if (onSecondaryAction != null)
            Expanded(
              child: OutlinedAppButton(
                text: actionType == ApplicationActionType.completed
                    ? 'View Receipt'
                    : 'Message Client',
                onPressed: onSecondaryAction,
              ),
            ),
          if (onSecondaryAction != null) AppSpacing.spaceMD,
          Expanded(
            child: PrimaryButton(
              text: actionType == ApplicationActionType.completed
                  ? 'OK'
                  : 'View Project',
              onPressed: onPrimaryAction ?? () => Navigator.of(context).pop(),
            ),
          ),
        ];
        break;
    }

    if (buttons.isEmpty) {
      buttons = [
        PrimaryButton(
          text: 'OK',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ];
    }

    return Row(
      children: buttons,
    );
  }
}

/// Helper functions to show different types of status modals

Future<void> showApplicationAcceptedModal(
  BuildContext context,
  Job job, {
  String? message,
  VoidCallback? onStartProject,
  VoidCallback? onViewDetails,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ApplicationStatusModal(
      job: job,
      actionType: ApplicationActionType.accepted,
      additionalMessage: message,
      onPrimaryAction: onStartProject,
      onSecondaryAction: onViewDetails,
    ),
  );
}

Future<void> showApplicationRejectedModal(
  BuildContext context,
  Job job, {
  String? message,
  VoidCallback? onFindOtherJobs,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ApplicationStatusModal(
      job: job,
      actionType: ApplicationActionType.rejected,
      additionalMessage: message,
      onPrimaryAction: onFindOtherJobs,
    ),
  );
}

Future<void> showChangeRequestedModal(
  BuildContext context,
  Job job, {
  String? message,
  VoidCallback? onViewChanges,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ApplicationStatusModal(
      job: job,
      actionType: ApplicationActionType.changeRequested,
      additionalMessage: message,
      onPrimaryAction: onViewChanges,
    ),
  );
}

Future<void> showProjectInProgressModal(
  BuildContext context,
  Job job, {
  String? message,
  VoidCallback? onViewProject,
  VoidCallback? onMessageClient,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ApplicationStatusModal(
      job: job,
      actionType: ApplicationActionType.inProgress,
      additionalMessage: message,
      onPrimaryAction: onViewProject,
      onSecondaryAction: onMessageClient,
    ),
  );
}

Future<void> showProjectCompletedModal(
  BuildContext context,
  Job job, {
  String? message,
  VoidCallback? onViewReceipt,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ApplicationStatusModal(
      job: job,
      actionType: ApplicationActionType.completed,
      additionalMessage: message,
      onSecondaryAction: onViewReceipt,
    ),
  );
}
