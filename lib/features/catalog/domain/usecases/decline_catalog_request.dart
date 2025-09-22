import '../repositories/catalog_requests_repository.dart';

class DeclineCatalogRequest {
  final CatalogRequestsRepository repository;
  DeclineCatalogRequest(this.repository);
  Future<bool> call(String id, {String? reason, String? message}) =>
      repository.decline(id, reason: reason, message: message);
}
