import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/client_repository.dart';
import 'client_profile_event.dart';
import 'client_profile_state.dart';

class ClientProfileBloc extends Bloc<ClientProfileEvent, ClientProfileState> {
  final ClientRepository repository;

  ClientProfileBloc({required this.repository})
      : super(ClientProfileInitial()) {
    on<LoadClientProfile>(_onLoadClientProfile);
  }

  Future<void> _onLoadClientProfile(
    LoadClientProfile event,
    Emitter<ClientProfileState> emit,
  ) async {
    emit(ClientProfileLoading());
    try {
      final profile = await repository.getClientProfile(event.clientId);
      emit(ClientProfileLoaded(profile: profile));
    } catch (e) {
      emit(ClientProfileError(message: e.toString()));
    }
  }
}
