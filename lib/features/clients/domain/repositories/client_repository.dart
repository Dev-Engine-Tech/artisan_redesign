import '../entities/client_profile.dart';

abstract class ClientRepository {
  Future<ClientProfile> getClientProfile(int clientId);
}
