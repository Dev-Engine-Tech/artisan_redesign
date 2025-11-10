import 'package:artisans_circle/features/notifications/domain/entities/notification.dart';

class NotificationDataModel extends NotificationData {
  const NotificationDataModel({
    super.jobApplicationId,
    super.jobId,
  });

  factory NotificationDataModel.fromJson(Map<String, dynamic> json) {
    return NotificationDataModel(
      jobApplicationId: json['job_application_id'] as int?,
      jobId: json['job_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_application_id': jobApplicationId,
      'job_id': jobId,
    };
  }
}

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.createdAt,
    required super.read,
    required super.title,
    required super.type,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      data: json['data'] != null
          ? NotificationDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      read: json['read'] as bool? ?? false,
      title: json['title']?.toString() ?? '',
      type: NotificationType.fromString(json['type']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'data': data != null ? (data as NotificationDataModel).toJson() : null,
      'read': read,
      'title': title,
      'type': type.value,
    };
  }

  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      id: notification.id,
      createdAt: notification.createdAt,
      data: notification.data != null
          ? NotificationDataModel(
              jobApplicationId: notification.data!.jobApplicationId,
              jobId: notification.data!.jobId,
            )
          : null,
      read: notification.read,
      title: notification.title,
      type: notification.type,
    );
  }

  Notification toEntity() {
    return Notification(
      id: id,
      createdAt: createdAt,
      data: data,
      read: read,
      title: title,
      type: type,
    );
  }
}
