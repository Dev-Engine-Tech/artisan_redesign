import 'package:equatable/equatable.dart';
import 'artisan_profile.dart';

/// Payment method for collaboration
enum PaymentMethod {
  percentage,
  fixed;

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => PaymentMethod.percentage,
    );
  }
}

/// Status of collaboration invitation/agreement
enum CollaborationStatus {
  pending,
  accepted,
  rejected,
  completed,
  cancelled;

  static CollaborationStatus fromString(String value) {
    return CollaborationStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => CollaborationStatus.pending,
    );
  }
}

/// Role in collaboration
enum CollaborationRole {
  mainArtisan('main_artisan'),
  collaborator('collaborator');

  final String value;
  const CollaborationRole(this.value);

  static CollaborationRole fromString(String value) {
    return CollaborationRole.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => CollaborationRole.collaborator,
    );
  }
}

/// Job information within collaboration
class CollaborationJob extends Equatable {
  final int id;
  final String title;
  final String? client;
  final double? budget;
  final String? location;
  final DateTime? startDate;
  final DateTime? deadline;

  const CollaborationJob({
    required this.id,
    required this.title,
    this.client,
    this.budget,
    this.location,
    this.startDate,
    this.deadline,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        client,
        budget,
        location,
        startDate,
        deadline,
      ];
}

/// Main collaboration entity
class Collaboration extends Equatable {
  final int id;
  final CollaborationJob job;
  final ArtisanProfile mainArtisan;
  final ArtisanProfile collaborator;
  final CollaborationRole myRole;
  final PaymentMethod paymentMethod;
  final double paymentAmount;
  final double? expectedEarnings;
  final CollaborationStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final bool isPaid;

  const Collaboration({
    required this.id,
    required this.job,
    required this.mainArtisan,
    required this.collaborator,
    required this.myRole,
    required this.paymentMethod,
    required this.paymentAmount,
    this.expectedEarnings,
    this.status = CollaborationStatus.pending,
    this.message,
    required this.createdAt,
    this.expiresAt,
    this.acceptedAt,
    this.rejectedAt,
    this.isPaid = false,
  });

  /// Check if collaboration is pending response
  bool get isPending => status == CollaborationStatus.pending;

  /// Check if collaboration is active
  bool get isActive => status == CollaborationStatus.accepted;

  /// Check if collaboration is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if current user can respond to this collaboration
  bool get canRespond {
    return isPending &&
        !isExpired &&
        myRole == CollaborationRole.collaborator;
  }

  /// Format payment display string
  String get paymentDisplay {
    if (paymentMethod == PaymentMethod.percentage) {
      return '${paymentAmount.toStringAsFixed(0)}% of earnings';
    } else {
      return '₦${paymentAmount.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]},',
          )}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        job,
        mainArtisan,
        collaborator,
        myRole,
        paymentMethod,
        paymentAmount,
        expectedEarnings,
        status,
        message,
        createdAt,
        expiresAt,
        acceptedAt,
        rejectedAt,
        isPaid,
      ];
}
