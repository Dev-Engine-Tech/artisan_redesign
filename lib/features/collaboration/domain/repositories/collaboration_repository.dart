import '../entities/collaboration.dart';
import '../entities/artisan_search_result.dart';

/// Repository interface for collaboration operations
abstract class CollaborationRepository {
  /// Search for artisans to invite as collaborators
  ///
  /// [query] - Search query (name or phone number)
  Future<List<ArtisanSearchResult>> searchArtisans(String query);

  /// Invite another artisan to collaborate on a job
  ///
  /// Requires active paid subscription (Bronze/Silver/Gold)
  /// [jobApplicationId] - The job application to collaborate on
  /// [collaboratorId] - ID of the artisan to invite
  /// [paymentMethod] - 'percentage' or 'fixed'
  /// [paymentAmount] - Percentage (0-100) or fixed amount
  /// [message] - Optional message to the collaborator
  Future<Collaboration> inviteCollaborator({
    required int jobApplicationId,
    required int collaboratorId,
    required PaymentMethod paymentMethod,
    required double paymentAmount,
    String? message,
  });

  /// Get all collaborations (as main artisan or collaborator)
  ///
  /// [status] - Filter by status: pending, accepted, rejected, completed
  /// [role] - Filter by role: main_artisan, collaborator
  /// [page] - Page number (default: 1)
  /// [pageSize] - Results per page (default: 10, max: 50)
  Future<CollaborationListResult> getMyCollaborations({
    CollaborationStatus? status,
    CollaborationRole? role,
    int page = 1,
    int pageSize = 10,
  });

  /// Respond to a collaboration invitation (accept/reject)
  ///
  /// [collaborationId] - The collaboration ID
  /// [action] - 'accept', 'reject', or 'cancel'
  /// [message] - Optional message when responding
  Future<Collaboration> respondToCollaboration({
    required int collaborationId,
    required CollaborationAction action,
    String? message,
  });

  /// Get all collaborators for a specific job application
  ///
  /// [jobApplicationId] - The job application ID
  Future<List<Collaboration>> getJobCollaborators({
    required int jobApplicationId,
  });
}

/// Action when responding to collaboration
enum CollaborationAction {
  accept,
  reject,
  cancel;

  String get value => name;
}

/// Result from getMyCollaborations with pagination info
class CollaborationListResult {
  final List<Collaboration> collaborations;
  final PaginationInfo pagination;
  final CollaborationStats stats;

  const CollaborationListResult({
    required this.collaborations,
    required this.pagination,
    required this.stats,
  });
}

/// Pagination information
class PaginationInfo {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalCount;
  final bool hasNext;
  final bool hasPrevious;

  const PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Collaboration statistics
class CollaborationStats {
  final int pendingInvitations;
  final int activeCollaborations;
  final int completedCollaborations;
  final double totalEarnings;

  const CollaborationStats({
    this.pendingInvitations = 0,
    this.activeCollaborations = 0,
    this.completedCollaborations = 0,
    this.totalEarnings = 0.0,
  });
}
