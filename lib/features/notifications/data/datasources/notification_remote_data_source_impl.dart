import 'package:dio/dio.dart';
import 'package:artisans_circle/core/api/endpoints.dart';
import 'package:artisans_circle/features/notifications/data/models/notification_model.dart';
import 'notification_remote_data_source.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await dio.get(ApiEndpoints.notifications);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'] ?? response.data;
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dio.get('${ApiEndpoints.notifications}unread-count/');
      
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
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await dio.post(
        ApiEndpoints.markNotificationAsRead,
        data: {'notification_id': notificationId},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await dio.post(ApiEndpoints.markAllNotificationsAsRead);
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  @override
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final response = await dio.get(ApiEndpoints.notificationById(int.tryParse(notificationId) ?? 0));
      
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
}