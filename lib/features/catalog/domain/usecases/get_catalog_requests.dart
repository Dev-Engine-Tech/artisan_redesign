import '../entities/catalog_request.dart';
import '../repositories/catalog_requests_repository.dart';

class GetCatalogRequests {
  final CatalogRequestsRepository repository;
  GetCatalogRequests(this.repository);
  Future<(List<CatalogRequest>, String?)> call({String? next}) =>
      repository.getRequests(next: next);
}
