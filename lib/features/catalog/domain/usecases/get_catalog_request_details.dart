import '../entities/catalog_request.dart';
import '../repositories/catalog_requests_repository.dart';

class GetCatalogRequestDetails {
  final CatalogRequestsRepository repository;
  GetCatalogRequestDetails(this.repository);
  Future<CatalogRequest> call(String id) => repository.getRequestDetails(id);
}
