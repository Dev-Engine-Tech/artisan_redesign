import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

class GetCatalogByUser {
  final CatalogRepository repository;
  GetCatalogByUser(this.repository);

  Future<List<CatalogItem>> call(String userId, {int page = 1}) =>
      repository.getCatalogByUser(userId, page: page);
}
