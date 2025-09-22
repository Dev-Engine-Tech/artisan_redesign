import 'package:artisans_circle/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  /// Get all notifications for the current user
  Future<List<Notification>> getNotifications();

  /// Get stream of notifications for real-time updates
  Stream<List<Notification>> watchNotifications();

  /// Get count of unread notifications
  Future<int> getUnreadCount();

  /// Get stream of unread count for real-time updates
  Stream<int> watchUnreadCount();

  /// Mark a specific notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Get a specific notification by ID
  Future<Notification?> getNotificationById(String notificationId);
}