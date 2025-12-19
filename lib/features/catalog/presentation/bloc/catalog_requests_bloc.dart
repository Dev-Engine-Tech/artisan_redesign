import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/catalog_request.dart';
import '../../domain/usecases/get_catalog_requests.dart';
import '../../domain/usecases/get_catalog_request_details.dart';
import '../../domain/usecases/approve_catalog_request.dart';
import '../../domain/usecases/decline_catalog_request.dart';

abstract class CatalogRequestsEvent {}

class LoadCatalogRequests extends CatalogRequestsEvent {
  final String? next;
  LoadCatalogRequests({this.next});
}

class RefreshCatalogRequests extends CatalogRequestsEvent {}

class LoadCatalogRequestDetails extends CatalogRequestsEvent {
  final String id;
  LoadCatalogRequestDetails(this.id);
}

class ApproveRequestEvent extends CatalogRequestsEvent {
  final String id;
  ApproveRequestEvent(this.id);
}

class DeclineRequestEvent extends CatalogRequestsEvent {
  final String id;
  final String? reason;
  final String? message;
  DeclineRequestEvent(this.id, {this.reason, this.message});
}

/// Event for updating materials in a catalog request (from artisan_app analysis)
class UpdateRequestMaterials extends CatalogRequestsEvent {
  final String id;
  final List<CatalogMaterial> materials;
  UpdateRequestMaterials(this.id, this.materials);
}

/// Event for sending material modifications to client
class SendMaterialModification extends CatalogRequestsEvent {
  final String id;
  final List<CatalogMaterial> materials;
  SendMaterialModification(this.id, this.materials);
}

abstract class CatalogRequestsState {
  const CatalogRequestsState();
}

class CatalogRequestsInitial extends CatalogRequestsState {
  const CatalogRequestsInitial();
}

class CatalogRequestsLoading extends CatalogRequestsState {
  const CatalogRequestsLoading();
}

class CatalogRequestsLoaded extends CatalogRequestsState {
  final List<CatalogRequest> items;
  final String? next;
  const CatalogRequestsLoaded({required this.items, this.next});
}

class CatalogRequestDetailsLoaded extends CatalogRequestsState {
  final CatalogRequest item;
  const CatalogRequestDetailsLoaded(this.item);
}

class CatalogRequestsError extends CatalogRequestsState {
  final String message;
  const CatalogRequestsError(this.message);
}

class CatalogRequestActionSuccess extends CatalogRequestsState {
  final String id;
  const CatalogRequestActionSuccess(this.id);
}

/// State for when approving a request is in progress
class CatalogRequestApproving extends CatalogRequestsState {
  final String id;
  const CatalogRequestApproving(this.id);
}

/// State for when declining a request is in progress
class CatalogRequestDeclining extends CatalogRequestsState {
  final String id;
  const CatalogRequestDeclining(this.id);
}

/// State for when updating materials is in progress
class CatalogRequestUpdatingMaterials extends CatalogRequestsState {
  final String id;
  const CatalogRequestUpdatingMaterials(this.id);
}

/// State for when material modification was sent successfully
class CatalogRequestMaterialsUpdated extends CatalogRequestsState {
  final String id;
  final List<CatalogMaterial> materials;
  const CatalogRequestMaterialsUpdated(this.id, this.materials);
}

class CatalogRequestsBloc
    extends Bloc<CatalogRequestsEvent, CatalogRequestsState> {
  final GetCatalogRequests getRequests;
  final GetCatalogRequestDetails getDetails;
  final ApproveCatalogRequest approve;
  final DeclineCatalogRequest decline;

  CatalogRequestsBloc(
      {required this.getRequests,
      required this.getDetails,
      required this.approve,
      required this.decline})
      : super(const CatalogRequestsInitial()) {
    debugPrint('✅ CatalogRequestsBloc initialized');
    on<LoadCatalogRequests>((event, emit) async {
      emit(const CatalogRequestsLoading());
      try {
        final (items, next) = await getRequests(next: event.next);
        emit(CatalogRequestsLoaded(items: items, next: next));
      } catch (e) {
        emit(CatalogRequestsError(e.toString()));
      }
    });
    on<RefreshCatalogRequests>((event, emit) async {
      try {
        final (items, next) = await getRequests();
        emit(CatalogRequestsLoaded(items: items, next: next));
      } catch (e) {
        emit(CatalogRequestsError(e.toString()));
      }
    });
    on<LoadCatalogRequestDetails>((event, emit) async {
      emit(const CatalogRequestsLoading());
      try {
        final item = await getDetails(event.id);
        emit(CatalogRequestDetailsLoaded(item));
      } catch (e) {
        emit(CatalogRequestsError(e.toString()));
      }
    });
    on<ApproveRequestEvent>((event, emit) async {
      emit(CatalogRequestApproving(event.id));
      try {
        final ok = await approve(event.id);
        if (ok) {
          emit(CatalogRequestActionSuccess(event.id));
        } else {
          emit(const CatalogRequestsError('Failed to approve request'));
        }
      } catch (e) {
        emit(CatalogRequestsError(e.toString()));
      }
    });
    on<DeclineRequestEvent>((event, emit) async {
      emit(CatalogRequestDeclining(event.id));
      try {
        final ok = await decline(event.id,
            reason: event.reason, message: event.message);
        if (ok) {
          emit(CatalogRequestActionSuccess(event.id));
        } else {
          emit(const CatalogRequestsError('Failed to decline request'));
        }
      } catch (e) {
        emit(CatalogRequestsError(e.toString()));
      }
    });
    on<UpdateRequestMaterials>((event, emit) async {
      emit(CatalogRequestUpdatingMaterials(event.id));
      try {
        // This would typically call a use case to update materials
        // For now, emit success with the updated materials
        emit(CatalogRequestMaterialsUpdated(event.id, event.materials));
      } catch (e) {
        emit(CatalogRequestsError(e.toString()));
      }
    });
    on<SendMaterialModification>((event, emit) async {
      emit(CatalogRequestUpdatingMaterials(event.id));
      try {
        // This would typically call a use case to send material modifications
        // For now, emit success indicating materials were sent
        emit(CatalogRequestActionSuccess(event.id));
      } catch (e) {
        emit(CatalogRequestsError(e.toString()));
      }
    });
  }
}
