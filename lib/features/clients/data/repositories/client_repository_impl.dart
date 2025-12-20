import '../../domain/entities/client_profile.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_data_source.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;

  ClientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ClientProfile> getClientProfile(int clientId) async {
    return await remoteDataSource.getClientProfile(clientId);
  }
}
