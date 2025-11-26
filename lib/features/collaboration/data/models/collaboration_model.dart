import '../../domain/entities/collaboration.dart';
import '../../domain/repositories/collaboration_repository.dart';
import 'artisan_profile_model.dart';

/// Data model for collaboration job with JSON parsing
class CollaborationJobModel extends CollaborationJob {
  const CollaborationJobModel({
    required super.id,
    required super.title,
    super.client,
    super.budget,
    super.location,
    super.startDate,
    super.deadline,
  });

  factory CollaborationJobModel.fromJson(Map<String, dynamic> json) {
    return CollaborationJobModel(
      id: (json['id'] as num).toInt(),
      title: json['title']?.toString() ?? '',
      client: json['client']?.toString(),
      budget: (json['budget'] as num?)?.toDouble(),
      location: json['location']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'client': client,
      'budget': budget,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
    };
  }

  CollaborationJob toEntity() => CollaborationJob(
        id: id,
        title: title,
        client: client,
        budget: budget,
        location: location,
        startDate: startDate,
        deadline: deadline,
      );
}

/// Data model for collaboration with JSON parsing
class CollaborationModel extends Collaboration {
  const CollaborationModel({
    required super.id,
    required super.job,
    required super.mainArtisan,
    required super.collaborator,
    required super.myRole,
    required super.paymentMethod,
    required super.paymentAmount,
    super.expectedEarnings,
    super.status,
    super.message,
    required super.createdAt,
    super.expiresAt,
    super.acceptedAt,
    super.rejectedAt,
    super.isPaid,
  });

  factory CollaborationModel.fromJson(Map<String, dynamic> json) {
    // Parse job information
    final jobData = json['job'] as Map<String, dynamic>? ?? {};
    final job = CollaborationJobModel.fromJson(jobData);

    // Parse main artisan
    final mainArtisanData = json['main_artisan'] as Map<String, dynamic>? ?? {};
    final mainArtisan = ArtisanProfileModel.fromJson(mainArtisanData);

    // Parse collaborator
    final collaboratorData = json['collaborator'] as Map<String, dynamic>? ?? {};
    final collaborator = ArtisanProfileModel.fromJson(collaboratorData);

    // Parse my role
    final myRoleStr = json['my_role']?.toString() ?? 'collaborator';
    final myRole = CollaborationRole.fromString(myRoleStr);

    // Parse payment method
    final paymentMethodStr = json['payment_method']?.toString() ?? 'percentage';
    final paymentMethod = PaymentMethod.fromString(paymentMethodStr);

    // Parse status
    final statusStr = json['status']?.toString() ?? 'pending';
    final status = CollaborationStatus.fromString(statusStr);

    return CollaborationModel(
      id: (json['id'] as num).toInt(),
      job: job,
      mainArtisan: mainArtisan,
      collaborator: collaborator,
      myRole: myRole,
      paymentMethod: paymentMethod,
      paymentAmount: (json['payment_amount'] as num?)?.toDouble() ?? 0.0,
      expectedEarnings: (json['expected_earnings'] as num?)?.toDouble(),
      status: status,
      message: json['message']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'].toString())
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.tryParse(json['rejected_at'].toString())
          : null,
      isPaid: json['is_paid'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job': (job as CollaborationJobModel).toJson(),
      'main_artisan': (mainArtisan as ArtisanProfileModel).toJson(),
      'collaborator': (collaborator as ArtisanProfileModel).toJson(),
      'my_role': myRole.value,
      'payment_method': paymentMethod.name,
      'payment_amount': paymentAmount,
      'expected_earnings': expectedEarnings,
      'status': status.name,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'is_paid': isPaid,
    };
  }

  Collaboration toEntity() => Collaboration(
        id: id,
        job: job,
        mainArtisan: mainArtisan,
        collaborator: collaborator,
        myRole: myRole,
        paymentMethod: paymentMethod,
        paymentAmount: paymentAmount,
        expectedEarnings: expectedEarnings,
        status: status,
        message: message,
        createdAt: createdAt,
        expiresAt: expiresAt,
        acceptedAt: acceptedAt,
        rejectedAt: rejectedAt,
        isPaid: isPaid,
      );
}

/// Pagination info model
class PaginationInfoModel extends PaginationInfo {
  const PaginationInfoModel({
    required super.page,
    required super.pageSize,
    required super.totalPages,
    required super.totalCount,
    required super.hasNext,
    required super.hasPrevious,
  });

  factory PaginationInfoModel.fromJson(Map<String, dynamic> json) {
    return PaginationInfoModel(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 10,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      hasNext: json['has_next'] == true,
      hasPrevious: json['has_previous'] == true,
    );
  }
}

/// Collaboration stats model
class CollaborationStatsModel extends CollaborationStats {
  const CollaborationStatsModel({
    super.pendingInvitations,
    super.activeCollaborations,
    super.completedCollaborations,
    super.totalEarnings,
  });

  factory CollaborationStatsModel.fromJson(Map<String, dynamic> json) {
    return CollaborationStatsModel(
      pendingInvitations: (json['pending_invitations'] as num?)?.toInt() ?? 0,
      activeCollaborations: (json['active_collaborations'] as num?)?.toInt() ?? 0,
      completedCollaborations:
          (json['completed_collaborations'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Collaboration list result model
class CollaborationListResultModel extends CollaborationListResult {
  const CollaborationListResultModel({
    required super.collaborations,
    required super.pagination,
    required super.stats,
  });

  factory CollaborationListResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};

    // Parse collaborations list
    final collaborationsList = data['collaborations'] as List? ?? [];
    final collaborations = collaborationsList
        .cast<Map<String, dynamic>>()
        .map((c) => CollaborationModel.fromJson(c))
        .toList();

    // Parse pagination
    final paginationData = data['pagination'] as Map<String, dynamic>? ?? {};
    final pagination = PaginationInfoModel.fromJson(paginationData);

    // Parse stats
    final statsData = data['stats'] as Map<String, dynamic>? ?? {};
    final stats = CollaborationStatsModel.fromJson(statsData);

    return CollaborationListResultModel(
      collaborations: collaborations,
      pagination: pagination,
      stats: stats,
    );
  }
}
