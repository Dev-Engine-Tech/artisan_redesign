import '../entities/catalog_item.dart';
import '../repositories/catalog_repository.dart';

class CreateCatalog {
  final CatalogRepository repository;
  CreateCatalog(this.repository);

  Future<CatalogItem> call({
    required String title,
    required String subCategoryId,
    required String description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> imagePaths = const [],
  }) =>
      repository.createCatalog(
        title: title,
        subCategoryId: subCategoryId,
        description: description,
        priceMin: priceMin,
        priceMax: priceMax,
        projectTimeline: projectTimeline,
        imagePaths: imagePaths,
      );
}
