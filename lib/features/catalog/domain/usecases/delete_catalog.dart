import '../repositories/catalog_repository.dart';

class DeleteCatalog {
  final CatalogRepository repository;
  DeleteCatalog(this.repository);
  Future<bool> call(String id) => repository.deleteCatalog(id);
}
