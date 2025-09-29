import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

class GetMyCatalogItems {
  final CatalogRepository repository;
  GetMyCatalogItems(this.repository);

  Future<List<CatalogItem>> call({int page = 1}) => repository.getMyCatalogItems(page: page);
}
