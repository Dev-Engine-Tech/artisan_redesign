import '../entities/catalog_request.dart';

abstract class CatalogRequestsRepository {
  Future<(List<CatalogRequest>, String?)> getRequests({String? next});
  Future<CatalogRequest> getRequestDetails(String id);
  Future<bool> approve(String id);
  Future<bool> decline(String id, {String? reason, String? message});
}
