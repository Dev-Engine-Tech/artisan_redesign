import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

class UpdateCatalog {
  final CatalogRepository repository;
  UpdateCatalog(this.repository);

  Future<CatalogItem> call({
    required String id,
    String? title,
    String? subCategoryId,
    String? description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> newImagePaths = const [],
  }) =>
      repository.updateCatalog(
        id: id,
        title: title,
        subCategoryId: subCategoryId,
        description: description,
        priceMin: priceMin,
        priceMax: priceMax,
        projectTimeline: projectTimeline,
        newImagePaths: newImagePaths,
      );
}
