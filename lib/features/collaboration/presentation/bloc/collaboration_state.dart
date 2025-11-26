import 'package:equatable/equatable.dart';
import '../../domain/entities/collaboration.dart';
import '../../domain/repositories/collaboration_repository.dart';

abstract class CollaborationState extends Equatable {
  const CollaborationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CollaborationInitial extends CollaborationState {
  const CollaborationInitial();
}

/// Loading collaborations
class CollaborationLoading extends CollaborationState {
  const CollaborationLoading();
}

/// Collaborations loaded successfully
class CollaborationsLoaded extends CollaborationState {
  final List<Collaboration> collaborations;
  final PaginationInfo pagination;
  final CollaborationStats stats;

  const CollaborationsLoaded({
    required this.collaborations,
    required this.pagination,
    required this.stats,
  });

  @override
  List<Object?> get props => [collaborations, pagination, stats];
}

/// Invitation sent successfully
class CollaborationInviteSent extends CollaborationState {
  final Collaboration collaboration;

  const CollaborationInviteSent({required this.collaboration});

  @override
  List<Object?> get props => [collaboration];
}

/// Response to collaboration sent successfully
class CollaborationResponseSuccess extends CollaborationState {
  final Collaboration collaboration;
  final CollaborationAction action;

  const CollaborationResponseSuccess({
    required this.collaboration,
    required this.action,
  });

  @override
  List<Object?> get props => [collaboration, action];
}

/// Job collaborators loaded
class JobCollaboratorsLoaded extends CollaborationState {
  final List<Collaboration> collaborators;
  final int jobApplicationId;

  const JobCollaboratorsLoaded({
    required this.collaborators,
    required this.jobApplicationId,
  });

  @override
  List<Object?> get props => [collaborators, jobApplicationId];
}

/// Error state
class CollaborationError extends CollaborationState {
  final String message;
  final bool isSubscriptionError;

  const CollaborationError({
    required this.message,
    this.isSubscriptionError = false,
  });

  @override
  List<Object?> get props => [message, isSubscriptionError];
}
