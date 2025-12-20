import '../../domain/entities/client_profile.dart';

abstract class ClientProfileState {
  const ClientProfileState();
}

class ClientProfileInitial extends ClientProfileState {}

class ClientProfileLoading extends ClientProfileState {}

class ClientProfileLoaded extends ClientProfileState {
  final ClientProfile profile;

  const ClientProfileLoaded({required this.profile});
}

class ClientProfileError extends ClientProfileState {
  final String message;

  const ClientProfileError({required this.message});
}
