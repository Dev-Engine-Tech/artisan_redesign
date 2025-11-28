import 'package:equatable/equatable.dart';
import '../../domain/entities/collaboration.dart';
import '../../domain/repositories/collaboration_repository.dart';

abstract class CollaborationEvent extends Equatable {
  const CollaborationEvent();

  @override
  List<Object?> get props => [];
}

/// Load all collaborations for the user
class LoadCollaborationsEvent extends CollaborationEvent {
  final CollaborationStatus? status;
  final CollaborationRole? role;
  final int page;
  final int pageSize;

  const LoadCollaborationsEvent({
    this.status,
    this.role,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [status, role, page, pageSize];
}

/// Refresh collaborations (force reload)
class RefreshCollaborationsEvent extends CollaborationEvent {
  final CollaborationStatus? status;
  final CollaborationRole? role;

  const RefreshCollaborationsEvent({
    this.status,
    this.role,
  });

  @override
  List<Object?> get props => [status, role];
}

/// Invite a collaborator to a job
class InviteCollaboratorEvent extends CollaborationEvent {
  final int jobApplicationId;
  final int collaboratorId;
  final PaymentMethod paymentMethod;
  final double paymentAmount;
  final String? message;

  const InviteCollaboratorEvent({
    required this.jobApplicationId,
    required this.collaboratorId,
    required this.paymentMethod,
    required this.paymentAmount,
    this.message,
  });

  @override
  List<Object?> get props => [
        jobApplicationId,
        collaboratorId,
        paymentMethod,
        paymentAmount,
        message,
      ];
}

/// Invite an external collaborator (not yet on platform) to a job
class InviteExternalCollaboratorEvent extends CollaborationEvent {
  final int jobApplicationId;
  final String name;
  final String contact;
  final PaymentMethod paymentMethod;
  final double paymentAmount;
  final String? message;

  const InviteExternalCollaboratorEvent({
    required this.jobApplicationId,
    required this.name,
    required this.contact,
    required this.paymentMethod,
    required this.paymentAmount,
    this.message,
  });

  @override
  List<Object?> get props => [
        jobApplicationId,
        name,
        contact,
        paymentMethod,
        paymentAmount,
        message,
      ];
}

/// Respond to a collaboration invitation
class RespondToCollaborationEvent extends CollaborationEvent {
  final int collaborationId;
  final CollaborationAction action;
  final String? message;

  const RespondToCollaborationEvent({
    required this.collaborationId,
    required this.action,
    this.message,
  });

  @override
  List<Object?> get props => [collaborationId, action, message];
}

/// Load collaborators for a specific job
class LoadJobCollaboratorsEvent extends CollaborationEvent {
  final int jobApplicationId;

  const LoadJobCollaboratorsEvent({required this.jobApplicationId});

  @override
  List<Object?> get props => [jobApplicationId];
}
