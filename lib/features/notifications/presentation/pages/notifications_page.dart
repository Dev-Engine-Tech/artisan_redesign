import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/components/components.dart';
import 'package:artisans_circle/features/notifications/domain/entities/notification.dart'
    as entities;
import 'package:artisans_circle/features/notifications/presentation/widgets/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  // Mock data for now - will be replaced with actual repository calls
  List<entities.Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    // Mock data - replace with actual repository call
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    setState(() {
      _notifications = [
        entities.Notification(
          id: '1',
          title: 'New Job Application',
          type: entities.NotificationType.jobApplication,
          read: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          data: const entities.NotificationData(jobId: 123),
        ),
        entities.Notification(
          id: '2',
          title: 'Payment Released',
          type: entities.NotificationType.paymentRelease,
          read: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        entities.Notification(
          id: '3',
          title: 'Agreement Quote',
          type: entities.NotificationType.agreementQuote,
          read: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          data: const entities.NotificationData(jobApplicationId: 456),
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _markAllAsRead() async {
    // Mark all notifications as read
    setState(() {
      _notifications =
          _notifications.map((n) => n.copyWith(read: true)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.brownHeader,
        foregroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.any((n) => !n.read))
            TextAppButton(
              text: 'Mark all read',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.orange,
              ),
            )
          : _notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey,
                      ),
                      AppSpacing.spaceLG,
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.spaceSM,
                      Text(
                        'You\'ll see updates about your jobs here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : Scrollbar(
                  controller: _scrollController,
                  thickness: 4,
                  radius: const Radius.circular(AppRadius.md),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: AppSpacing.verticalSM,
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return NotificationItem(
                        notification: notification,
                        onTap: () => _onNotificationTap(notification),
                      );
                    },
                  ),
                ),
    );
  }

  void _onNotificationTap(entities.Notification notification) {
    // Mark as read if not already read
    if (!notification.read) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(read: true);
        }
      });
    }

    // Navigate based on notification type
    switch (notification.type) {
      case entities.NotificationType.jobApplication:
      case entities.NotificationType.acceptProjectAgreement:
        // Navigate to jobs/projects page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to job details')),
        );
        break;
      case entities.NotificationType.paymentRelease:
        // Navigate to earnings/wallet page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigate to earnings')),
        );
        break;
      default:
        // General notification tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification: ${notification.title}')),
        );
    }
  }
}
