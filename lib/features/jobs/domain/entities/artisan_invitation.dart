import 'package:equatable/equatable.dart';

/// Represents an invitation for an artisan to apply to a job
/// Corresponds to the /invitation/api/artisan-invitations/ endpoints
class ArtisanInvitation extends Equatable {
  final int id;
  final int jobId;
  final String jobTitle;
  final String? jobDescription;
  final String? jobCategory;
  final int? minBudget;
  final int? maxBudget;
  final String? duration;
  final String? workMode;
  final String? address;

  final String? clientName;
  final int? clientId;

  final String invitationStatus; // "Pending", "Accepted", "Rejected"
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? respondedAt;

  final String? message; // Optional message from client

  const ArtisanInvitation({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.invitationStatus,
    required this.createdAt,
    this.jobDescription,
    this.jobCategory,
    this.minBudget,
    this.maxBudget,
    this.duration,
    this.workMode,
    this.address,
    this.clientName,
    this.clientId,
    this.rejectionReason,
    this.respondedAt,
    this.message,
  });

  @override
  List<Object?> get props => [
        id,
        jobId,
        jobTitle,
        jobDescription,
        jobCategory,
        minBudget,
        maxBudget,
        duration,
        workMode,
        address,
        clientName,
        clientId,
        invitationStatus,
        rejectionReason,
        createdAt,
        respondedAt,
        message,
      ];

  /// Check if the invitation is pending
  bool get isPending => invitationStatus.toLowerCase() == 'pending';

  /// Check if the invitation is accepted
  bool get isAccepted => invitationStatus.toLowerCase() == 'accepted';

  /// Check if the invitation is rejected
  bool get isRejected => invitationStatus.toLowerCase() == 'rejected';

  ArtisanInvitation copyWith({
    int? id,
    int? jobId,
    String? jobTitle,
    String? jobDescription,
    String? jobCategory,
    int? minBudget,
    int? maxBudget,
    String? duration,
    String? workMode,
    String? address,
    String? clientName,
    int? clientId,
    String? invitationStatus,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? message,
  }) {
    return ArtisanInvitation(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      jobDescription: jobDescription ?? this.jobDescription,
      jobCategory: jobCategory ?? this.jobCategory,
      minBudget: minBudget ?? this.minBudget,
      maxBudget: maxBudget ?? this.maxBudget,
      duration: duration ?? this.duration,
      workMode: workMode ?? this.workMode,
      address: address ?? this.address,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      invitationStatus: invitationStatus ?? this.invitationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message ?? this.message,
    );
  }
}
