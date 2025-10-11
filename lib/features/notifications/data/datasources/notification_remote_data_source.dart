import 'package:artisans_circle/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<NotificationModel?> getNotificationById(String notificationId);

  /// Register an FCM/APNS device token with the backend
  Future<void> registerDeviceToken({
    required String token,
    required String deviceType,
    String? deviceId,
  });

  /// Request a test push to the current user (backend must support it)
  Future<void> sendTestPush({required String title, required String body});
}
