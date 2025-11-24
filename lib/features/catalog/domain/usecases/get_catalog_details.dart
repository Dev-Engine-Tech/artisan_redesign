import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

class GetCatalogDetails {
  final CatalogRepository repository;
  GetCatalogDetails(this.repository);

  Future<CatalogItem> call(String id) => repository.getCatalogDetails(id);
}
