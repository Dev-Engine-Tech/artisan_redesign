import 'dart:async';
import 'package:artisans_circle/features/notifications/domain/entities/notification.dart';
import 'package:artisans_circle/features/notifications/domain/repositories/notification_repository.dart';
import 'package:artisans_circle/features/notifications/data/datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  
  // Stream controllers for real-time updates
  final StreamController<List<Notification>> _notificationsController = 
      StreamController<List<Notification>>.broadcast();
  final StreamController<int> _unreadCountController = 
      StreamController<int>.broadcast();
  
  // Cache for notifications
  List<Notification> _cachedNotifications = [];
  int _cachedUnreadCount = 0;
  
  // Timer for periodic updates
  Timer? _updateTimer;

  NotificationRepositoryImpl({required this.remoteDataSource}) {
    // Start periodic updates every 30 seconds
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshData();
    });
  }

  @override
  Future<List<Notification>> getNotifications() async {
    try {
      final models = await remoteDataSource.getNotifications();
      _cachedNotifications = models.map((model) => model.toEntity()).toList();
      _notificationsController.add(_cachedNotifications);
      return _cachedNotifications;
    } catch (e) {
      // Return cached data if available
      if (_cachedNotifications.isNotEmpty) {
        return _cachedNotifications;
      }
      rethrow;
    }
  }

  @override
  Stream<List<Notification>> watchNotifications() {
    // Initialize with cached data if available
    if (_cachedNotifications.isNotEmpty) {
      _notificationsController.add(_cachedNotifications);
    } else {
      // Fetch initial data
      getNotifications();
    }
    return _notificationsController.stream;
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      _cachedUnreadCount = await remoteDataSource.getUnreadCount();
      _unreadCountController.add(_cachedUnreadCount);
      return _cachedUnreadCount;
    } catch (e) {
      // Return cached count if available
      return _cachedUnreadCount;
    }
  }

  @override
  Stream<int> watchUnreadCount() {
    // Initialize with cached data
    _unreadCountController.add(_cachedUnreadCount);
    // Fetch initial data
    getUnreadCount();
    return _unreadCountController.stream;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      
      // Update cached data optimistically
      _cachedNotifications = _cachedNotifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(read: true);
        }
        return notification;
      }).toList();
      
      // Update unread count
      _cachedUnreadCount = _cachedNotifications.where((n) => !n.read).length;
      
      // Notify listeners
      _notificationsController.add(_cachedNotifications);
      _unreadCountController.add(_cachedUnreadCount);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      
      // Update cached data optimistically
      _cachedNotifications = _cachedNotifications.map((notification) {
        return notification.copyWith(read: true);
      }).toList();
      
      _cachedUnreadCount = 0;
      
      // Notify listeners
      _notificationsController.add(_cachedNotifications);
      _unreadCountController.add(_cachedUnreadCount);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Notification?> getNotificationById(String notificationId) async {
    try {
      final model = await remoteDataSource.getNotificationById(notificationId);
      return model?.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _refreshData() async {
    try {
      await Future.wait([
        getNotifications(),
        getUnreadCount(),
      ]);
    } catch (e) {
      // Silently fail periodic updates
    }
  }

  void dispose() {
    _updateTimer?.cancel();
    _notificationsController.close();
    _unreadCountController.close();
  }
}