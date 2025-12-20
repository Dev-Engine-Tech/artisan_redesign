abstract class ClientProfileEvent {
  const ClientProfileEvent();
}

class LoadClientProfile extends ClientProfileEvent {
  final int clientId;

  const LoadClientProfile({required this.clientId});
}
