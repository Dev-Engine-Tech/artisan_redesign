import '../../domain/entities/artisan_invitation.dart';

class ArtisanInvitationModel extends ArtisanInvitation {
  const ArtisanInvitationModel({
    required super.id,
    required super.jobId,
    required super.jobTitle,
    required super.invitationStatus,
    required super.createdAt,
    super.jobDescription,
    super.jobCategory,
    super.minBudget,
    super.maxBudget,
    super.duration,
    super.workMode,
    super.address,
    super.clientName,
    super.clientId,
    super.rejectionReason,
    super.respondedAt,
    super.message,
  });

  factory ArtisanInvitationModel.fromJson(Map<String, dynamic> json) {
    // Parse job details from nested 'job' object or root level
    final jobData = json['job'] is Map ? json['job'] as Map<String, dynamic> : json;

    // Parse client details from nested 'client' object
    final clientData = jobData['client'] is Map ? jobData['client'] as Map<String, dynamic> : null;

    // Parse category - it can be a string or an object with 'name' field
    String? categoryName;
    final categoryField = jobData['category'];
    if (categoryField is String) {
      categoryName = categoryField;
    } else if (categoryField is Map) {
      categoryName = categoryField['name'] as String?;
    }

    // Build client name from first_name and last_name if available
    String? clientName;
    if (clientData != null) {
      final firstName = clientData['first_name'] as String?;
      final lastName = clientData['last_name'] as String?;
      if (firstName != null && lastName != null) {
        clientName = '$firstName $lastName'.trim();
      } else if (firstName != null) {
        clientName = firstName;
      } else if (lastName != null) {
        clientName = lastName;
      }
    }

    return ArtisanInvitationModel(
      id: json['id'] as int,
      jobId: (jobData['id'] ?? jobData['job_id']) as int,
      jobTitle: (jobData['title'] ?? jobData['job_title'] ?? 'Untitled Job') as String,
      jobDescription: jobData['description'] as String?,
      jobCategory: categoryName,
      minBudget: _parseIntOrNull(jobData['min_budget'] ?? jobData['budget_min']),
      maxBudget: _parseIntOrNull(jobData['max_budget'] ?? jobData['budget_max']),
      duration: jobData['duration'] as String?,
      workMode: jobData['work_mode'] as String?,
      address: jobData['address'] ?? jobData['location'] as String?,
      clientName: clientName ?? json['client_name'] as String?,
      clientId: _parseIntOrNull(clientData?['id'] ?? json['client_id']),
      invitationStatus: (json['invitation_status'] ?? 'Pending') as String,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      message: json['message'] as String?,
    );
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'job_title': jobTitle,
      'job_description': jobDescription,
      'job_category': jobCategory,
      'min_budget': minBudget,
      'max_budget': maxBudget,
      'duration': duration,
      'work_mode': workMode,
      'address': address,
      'client_name': clientName,
      'client_id': clientId,
      'invitation_status': invitationStatus,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'message': message,
    };
  }

  ArtisanInvitation toEntity() => this;
}
