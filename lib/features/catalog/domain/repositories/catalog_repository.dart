import '../entities/catalog_item.dart';

abstract class CatalogRepository {
  Future<List<CatalogItem>> getMyCatalogItems({int page});
  Future<List<CatalogItem>> getCatalogByUser(String userId, {int page});

  Future<CatalogItem> createCatalog({
    required String title,
    required String subCategoryId,
    required String description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> imagePaths,
    bool instantSelling,
    String? brand,
    String? condition,
    String? salesCategory,
    bool warranty,
    bool delivery,
  });

  Future<CatalogItem> updateCatalog({
    required String id,
    String? title,
    String? subCategoryId,
    String? description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> newImagePaths,
    bool? instantSelling,
    String? brand,
    String? condition,
    String? salesCategory,
    bool? warranty,
    bool? delivery,
  });

  Future<bool> deleteCatalog(String id);
}
