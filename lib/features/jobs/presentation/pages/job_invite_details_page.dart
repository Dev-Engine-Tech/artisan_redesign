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
        color: AppColors.softPeach,
        borderRadius: AppRadius.radiusLG,
      ),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.brownHeader)),
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
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title:
            const Text('Job Invite', style: TextStyle(color: Colors.black87)),
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
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.softBorder),
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
                                ?.copyWith(color: Colors.black45)),
                        const SizedBox(height: 10),
                        Text(job.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.black54)),
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
                    color: AppColors.softPink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Reviews',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        AppSpacing.spaceSM,
                        CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFFE9692D),
                            child: Text('29',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12))),
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
                  color: AppColors.cardBackground,
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.radiusLG),
                  child: Column(
                    children: [
                      CompatRadioListTile<String>(
                        value: 'pickup',
                        groupValue: _deliveryOption,
                        onChanged: (v) =>
                            setState(() => _deliveryOption = v ?? 'pickup'),
                        title: const Text('Pickup items from artisans location',
                            style: TextStyle(color: Colors.black45)),
                      ),
                      CompatRadioListTile<String>(
                        value: 'deliver',
                        groupValue: _deliveryOption,
                        onChanged: (v) =>
                            setState(() => _deliveryOption = v ?? 'deliver'),
                        title: const Text(
                            'Deliver items to a specific location',
                            style: TextStyle(color: Colors.black45)),
                      ),
                      if (_deliveryOption == 'deliver')
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingMD,
                            decoration: BoxDecoration(
                              color: AppColors.softPeach,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                                '15a, Oladipo diya street, Lekki phase 1 Ido LGA, Lagos state.'),
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
                    color: AppColors.cardBackground,
                    borderRadius: AppRadius.radiusLG,
                    border: Border.all(color: AppColors.softBorder),
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
                    border: Border.all(color: AppColors.subtleBorder),
                    color: AppColors.cardBackground,
                  ),
                  child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add your preferences',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.brownHeader)),
                        AppSpacing.spaceSM,
                        Text(
                            '• Perhaps you don\'t like the client\'s estimated budget'),
                        SizedBox(height: 6),
                        Text(
                            '• The start time isn\'t convenient due to several bookings'),
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
