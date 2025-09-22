import '../repositories/catalog_requests_repository.dart';

class ApproveCatalogRequest {
  final CatalogRequestsRepository repository;
  ApproveCatalogRequest(this.repository);
  Future<bool> call(String id) => repository.approve(id);
}
