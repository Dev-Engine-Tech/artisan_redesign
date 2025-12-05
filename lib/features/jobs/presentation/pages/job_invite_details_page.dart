import 'package:flutter/material.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart'
    as domain;
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';
import 'package:artisans_circle/shared/widgets/compat_radio.dart';
import '../../../../core/utils/responsive.dart';

class JobInviteDetailsPage extends StatefulWidget {
  final Job job;

  const JobInviteDetailsPage({required this.job, super.key});

  @override
  State<JobInviteDetailsPage> createState() => _JobInviteDetailsPageState();
}

class _JobInviteDetailsPageState extends State<JobInviteDetailsPage> {
  String _deliveryOption = 'pickup';
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 6),
      decoration: BoxDecoration(
        color: context.softPeachColor,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.brownHeaderColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Container(
            decoration: BoxDecoration(
                color: context.softPinkColor,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title:
            Text('Job Invite', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: context.maxContentWidth),
            child: ListView(
              padding: context.responsivePadding,
              children: [
                // Title + category + description card (rounded)
                Container(
                  decoration: BoxDecoration(
                    color: context.cardBackgroundColor,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: context.softBorderColor),
                  ),
                  padding: context.responsivePadding,
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
                                ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        Text(job.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                        AppSpacing.spaceMD,
                        Wrap(
                          children: [
                            _badge('Applicants: 10 artisans'),
                            _badge('Budget: NGN 500,000'),
                            _badge('Work type: On site'),
                            _badge('Duration: ${job.duration}'),
                          ],
                        ),
                      ]),
                ),

                const SizedBox(height: 14),

                // Reviews header
                Container(
                  padding: AppSpacing.verticalMD,
                  decoration: BoxDecoration(
                    color: context.softPinkColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Reviews',
                            style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        AppSpacing.spaceSM,
                        CircleAvatar(
                            radius: 12,
                            backgroundColor: context.primaryColor,
                            child: Text('29',
                                style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colorScheme.onPrimary))),
                      ]),
                ),

                AppSpacing.spaceMD,

                // Primary actions (Accept / Message)
                PrimaryButton(
                  text: 'Accept Invite',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invite accepted')));
                  },
                ),

                AppSpacing.spaceMD,

                OutlinedAppButton(
                  text: 'Message',
                  onPressed: () {
                    // Open direct chat for this invite (passes job context)
                    final conv = domain.Conversation(
                      id: 'invite_${job.id}',
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

                AppSpacing.spaceXL,

                // Delivery Option
                Text('Delivery Option',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                AppSpacing.spaceSM,
                Card(
                  color: context.cardBackgroundColor,
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
                  child: Column(
                    children: [
                      CompatRadioListTile<String>(
                        value: 'pickup',
                        groupValue: _deliveryOption,
                        onChanged: (v) =>
                            setState(() => _deliveryOption = v ?? 'pickup'),
                        title: Text('Pickup items from artisans location',
                            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                      ),
                      CompatRadioListTile<String>(
                        value: 'deliver',
                        groupValue: _deliveryOption,
                        onChanged: (v) =>
                            setState(() => _deliveryOption = v ?? 'deliver'),
                        title: Text(
                            'Deliver items to a specific location',
                            style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                      ),
                      if (_deliveryOption == 'deliver')
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingMD,
                            decoration: BoxDecoration(
                              color: context.softPeachColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                                '15a, Oladipo diya street, Lekki phase 1 Ido LGA, Lagos state.',
                                style: context.textTheme.bodyMedium),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Add a comment
                Text('Add a Comment',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                AppSpacing.spaceSM,
                Container(
                  decoration: BoxDecoration(
                    color: context.cardBackgroundColor,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: context.softBorderColor),
                  ),
                  padding: AppSpacing.paddingMD,
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration.collapsed(
                        hintText: 'type in your preferences'),
                  ),
                ),

                AppSpacing.spaceMD,

                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: context.subtleBorderColor),
                    color: context.cardBackgroundColor,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add your preferences',
                            style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.brownHeaderColor)),
                        AppSpacing.spaceSM,
                        Text(
                            '• Perhaps you don\'t like the client\'s estimated budget',
                            style: context.textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Text(
                            '• The start time isn\'t convenient due to several bookings',
                            style: context.textTheme.bodyMedium),
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
}
