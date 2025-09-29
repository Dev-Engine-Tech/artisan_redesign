enum NotificationType {
  agreementQuote('agreement-quote'),
  jobSubmission('job-submission'),
  paymentRelease('payment-release'),
  milestoneSubmission('milestone-submission'),
  jobApplication('job-application'),
  acceptProjectAgreement('accept-project-agreement'),
  requestChangeOfAgreement('request-change-of-agreement'),
  cancelContract('cancel-contract'),
  materialPayment('material-payment'),
  newAccount('new-account'),
  loginActivity('login-activity'),
  hireArtisan('hire-artisan');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.loginActivity,
    );
  }

  String get displayTitle {
    switch (this) {
      case NotificationType.agreementQuote:
        return 'Agreement Quote';
      case NotificationType.jobSubmission:
        return 'Job Submission';
      case NotificationType.paymentRelease:
        return 'Payment Release';
      case NotificationType.milestoneSubmission:
        return 'Milestone Submission';
      case NotificationType.jobApplication:
        return 'Job Application';
      case NotificationType.acceptProjectAgreement:
        return 'Accept Project Agreement';
      case NotificationType.requestChangeOfAgreement:
        return 'Request Change of Agreement';
      case NotificationType.cancelContract:
        return 'Cancel Contract';
      case NotificationType.materialPayment:
        return 'Material Payment';
      case NotificationType.newAccount:
        return 'New Account';
      case NotificationType.loginActivity:
        return 'Login Activity';
      case NotificationType.hireArtisan:
        return 'Hire Artisan';
    }
  }
}

class NotificationData {
  final int? jobApplicationId;
  final int? jobId;

  const NotificationData({
    this.jobApplicationId,
    this.jobId,
  });
}

class Notification {
  final String id;
  final DateTime createdAt;
  final NotificationData? data;
  final bool read;
  final String title;
  final NotificationType type;

  const Notification({
    required this.id,
    required this.createdAt,
    this.data,
    required this.read,
    required this.title,
    required this.type,
  });

  Notification copyWith({
    String? id,
    DateTime? createdAt,
    NotificationData? data,
    bool? read,
    String? title,
    NotificationType? type,
  }) {
    return Notification(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      read: read ?? this.read,
      title: title ?? this.title,
      type: type ?? this.type,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
