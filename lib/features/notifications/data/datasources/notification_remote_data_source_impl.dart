import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/features/notifications/data/models/notification_model.dart';
import 'package:artisans_circle/core/data/base_remote_data_source.dart';
import 'notification_remote_data_source.dart';

class NotificationRemoteDataSourceImpl extends BaseRemoteDataSource
    implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl(super.dio);

  @override
  Future<List<NotificationModel>> getNotifications() => getList(
        ApiEndpoints.notifications,
        fromJson: NotificationModel.fromJson,
      );

  @override
  Future<int> getUnreadCount() async {
    try {
      final response =
          await dio.get('${ApiEndpoints.notifications}unread-count/');

      if (response.statusCode == 200) {
        return response.data['count'] ?? 0;
      } else {
        throw Exception('Failed to fetch unread count');
      }
    } catch (e) {
      throw Exception('Error fetching unread count: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) => postVoid(
        ApiEndpoints.markNotificationAsRead,
        data: {'notification_id': notificationId},
      );

  @override
  Future<void> markAllAsRead() => postVoid(
        ApiEndpoints.markAllNotificationsAsRead,
      );

  @override
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final response = await dio.get(
          ApiEndpoints.notificationById(int.tryParse(notificationId) ?? 0));

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch notification');
      }
    } catch (e) {
      throw Exception('Error fetching notification: $e');
    }
  }

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String deviceType,
    String? deviceId,
  }) =>
      postVoid(
        ApiEndpoints.deviceTokensRegister,
        data: {
          'token': token,
          'device_type': deviceType,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
        },
      );

  @override
  Future<void> sendTestPush({required String title, required String body}) =>
      postVoid(
        ApiEndpoints.testPushNotification,
        data: {
          'title': title,
          'body': body,
        },
      );
}
