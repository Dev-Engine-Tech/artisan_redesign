import '../../domain/entities/catalog_request.dart';
import '../../domain/repositories/catalog_requests_repository.dart';
import '../datasources/catalog_requests_remote_data_source.dart';

class CatalogRequestsRepositoryImpl implements CatalogRequestsRepository {
  final CatalogRequestsRemoteDataSource remote;
  CatalogRequestsRepositoryImpl(this.remote);

  @override
  Future<(List<CatalogRequest>, String?)> getRequests({String? next}) async {
    final (models, nxt) = await remote.fetchRequests(next: next);
    return (models.map((e) => e.toEntity()).toList(), nxt);
  }

  @override
  Future<CatalogRequest> getRequestDetails(String id) async {
    final model = await remote.fetchRequestDetails(id);
    return model.toEntity();
  }

  @override
  Future<bool> approve(String id) => remote.respond(id, approve: true);

  @override
  Future<bool> decline(String id, {String? reason, String? message}) =>
      remote.respond(id, approve: false, reason: reason, message: message);
}
