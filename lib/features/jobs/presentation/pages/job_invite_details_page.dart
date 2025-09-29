import 'package:flutter/material.dart';
import 'package:artisans_circle/features/jobs/domain/entities/job.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/features/messages/presentation/pages/messages_flow.dart';
import 'package:artisans_circle/features/messages/domain/entities/conversation.dart' as domain;
import 'package:artisans_circle/features/messages/presentation/manager/chat_manager.dart';
import 'package:artisans_circle/shared/widgets/compat_radio.dart';

class JobInviteDetailsPage extends StatefulWidget {
  final Job job;

  const JobInviteDetailsPage({super.key, required this.job});

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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.brownHeader)),
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
            decoration:
                BoxDecoration(color: AppColors.softPink, borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text('Job Invite', style: TextStyle(color: Colors.black87)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Title + category + description card (rounded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(job.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(job.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black45)),
                const SizedBox(height: 10),
                Text(job.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                const SizedBox(height: 12),
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
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Text('Reviews', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                CircleAvatar(
                    radius: 12,
                    backgroundColor: Color(0xFFE9692D),
                    child: Text('29', style: TextStyle(color: Colors.white, fontSize: 12))),
              ]),
            ),

            const SizedBox(height: 12),

            // Primary actions (Accept / Message)
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Invite accepted')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A4B20),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Accept Invite', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF213447),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Message', style: TextStyle(fontSize: 16)),
            ),

            const SizedBox(height: 20),

            // Delivery Option
            Text('Delivery Option',
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Card(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  CompatRadioListTile<String>(
                    value: 'pickup',
                    groupValue: _deliveryOption,
                    onChanged: (v) => setState(() => _deliveryOption = v ?? 'pickup'),
                    title: const Text('Pickup items from artisans location',
                        style: TextStyle(color: Colors.black45)),
                  ),
                  CompatRadioListTile<String>(
                    value: 'deliver',
                    groupValue: _deliveryOption,
                    onChanged: (v) => setState(() => _deliveryOption = v ?? 'deliver'),
                    title: const Text('Deliver items to a specific location',
                        style: TextStyle(color: Colors.black45)),
                  ),
                  if (_deliveryOption == 'deliver')
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
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
                style:
                    Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.softBorder),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration.collapsed(hintText: 'type in your preferences'),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.subtleBorder),
                color: AppColors.cardBackground,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Add your preferences',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.brownHeader)),
                SizedBox(height: 8),
                Text('• Perhaps you don\'t like the client\'s estimated budget'),
                SizedBox(height: 6),
                Text('• The start time isn\'t convenient due to several bookings'),
              ]),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
