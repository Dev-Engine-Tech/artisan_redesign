import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_collaborations.dart';
import '../../domain/usecases/invite_collaborator.dart';
import '../../domain/usecases/invite_external_collaborator.dart';
import '../../domain/usecases/respond_to_collaboration.dart';
import '../../domain/usecases/get_job_collaborators.dart';
import 'collaboration_event.dart';
import 'collaboration_state.dart';

class CollaborationBloc extends Bloc<CollaborationEvent, CollaborationState> {
  final GetMyCollaborations getMyCollaborations;
  final InviteCollaborator inviteCollaborator;
  final InviteExternalCollaborator inviteExternalCollaborator;
  final RespondToCollaboration respondToCollaboration;
  final GetJobCollaborators getJobCollaborators;

  CollaborationBloc({
    required this.getMyCollaborations,
    required this.inviteCollaborator,
    required this.inviteExternalCollaborator,
    required this.respondToCollaboration,
    required this.getJobCollaborators,
  }) : super(const CollaborationInitial()) {
    on<LoadCollaborationsEvent>(_onLoadCollaborations);
    on<RefreshCollaborationsEvent>(_onRefreshCollaborations);
    on<InviteCollaboratorEvent>(_onInviteCollaborator);
    on<InviteExternalCollaboratorEvent>(_onInviteExternalCollaborator);
    on<RespondToCollaborationEvent>(_onRespondToCollaboration);
    on<LoadJobCollaboratorsEvent>(_onLoadJobCollaborators);
  }

  Future<void> _onLoadCollaborations(
    LoadCollaborationsEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    try {
      emit(const CollaborationLoading());

      final result = await getMyCollaborations(
        status: event.status,
        role: event.role,
        page: event.page,
        pageSize: event.pageSize,
      );

      emit(CollaborationsLoaded(
        collaborations: result.collaborations,
        pagination: result.pagination,
        stats: result.stats,
      ));
    } catch (e) {
      emit(CollaborationError(
        message: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshCollaborations(
    RefreshCollaborationsEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    try {
      // Don't show loading state for refresh
      final result = await getMyCollaborations(
        status: event.status,
        role: event.role,
        page: 1,
        pageSize: 10,
      );

      emit(CollaborationsLoaded(
        collaborations: result.collaborations,
        pagination: result.pagination,
        stats: result.stats,
      ));
    } catch (e) {
      emit(CollaborationError(
        message: e.toString(),
      ));
    }
  }

  Future<void> _onInviteCollaborator(
    InviteCollaboratorEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    try {
      emit(const CollaborationLoading());

      final collaboration = await inviteCollaborator(
        jobApplicationId: event.jobApplicationId,
        collaboratorId: event.collaboratorId,
        paymentMethod: event.paymentMethod,
        paymentAmount: event.paymentAmount,
        message: event.message,
      );

      emit(CollaborationInviteSent(collaboration: collaboration));
    } catch (e) {
      // Check if it's a subscription error
      final errorMessage = e.toString();
      final isSubscriptionError = errorMessage.contains('SUBSCRIPTION_ERROR') ||
          errorMessage.contains('subscription') ||
          errorMessage.contains('upgrade') ||
          errorMessage.contains('limit') ||
          errorMessage.contains('plan');

      emit(CollaborationError(
        message: isSubscriptionError
            ? 'You need to upgrade your subscription plan to invite collaborators.'
            : errorMessage,
        isSubscriptionError: isSubscriptionError,
      ));
    }
  }

  Future<void> _onInviteExternalCollaborator(
    InviteExternalCollaboratorEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    try {
      emit(const CollaborationLoading());

      final collaboration = await inviteExternalCollaborator(
        jobApplicationId: event.jobApplicationId,
        name: event.name,
        contact: event.contact,
        paymentMethod: event.paymentMethod,
        paymentAmount: event.paymentAmount,
        message: event.message,
      );

      emit(CollaborationInviteSent(collaboration: collaboration));
    } catch (e) {
      // Check if it's a subscription error
      final errorMessage = e.toString();
      final isSubscriptionError = errorMessage.contains('SUBSCRIPTION_ERROR') ||
          errorMessage.contains('subscription') ||
          errorMessage.contains('upgrade') ||
          errorMessage.contains('limit') ||
          errorMessage.contains('plan');

      emit(CollaborationError(
        message: isSubscriptionError
            ? 'You need to upgrade your subscription plan to invite collaborators.'
            : errorMessage,
        isSubscriptionError: isSubscriptionError,
      ));
    }
  }

  Future<void> _onRespondToCollaboration(
    RespondToCollaborationEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    try {
      emit(const CollaborationLoading());

      final collaboration = await respondToCollaboration(
        collaborationId: event.collaborationId,
        action: event.action,
        message: event.message,
      );

      emit(CollaborationResponseSuccess(
        collaboration: collaboration,
        action: event.action,
      ));
    } catch (e) {
      emit(CollaborationError(
        message: e.toString(),
      ));
    }
  }

  Future<void> _onLoadJobCollaborators(
    LoadJobCollaboratorsEvent event,
    Emitter<CollaborationState> emit,
  ) async {
    try {
      emit(const CollaborationLoading());

      final collaborators = await getJobCollaborators(
        jobApplicationId: event.jobApplicationId,
      );

      emit(JobCollaboratorsLoaded(
        collaborators: collaborators,
        jobApplicationId: event.jobApplicationId,
      ));
    } catch (e) {
      emit(CollaborationError(
        message: e.toString(),
      ));
    }
  }
}
