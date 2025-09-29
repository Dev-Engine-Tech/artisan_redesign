import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remote;
  CatalogRepositoryImpl(this.remote);

  @override
  Future<List<CatalogItem>> getMyCatalogItems({int page = 1}) async {
    final models = await remote.getMyCatalogItems(page: page);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<CatalogItem>> getCatalogByUser(String userId, {int page = 1}) async {
    final models = await remote.getCatalogByUser(userId, page: page);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<CatalogItem> createCatalog({
    required String title,
    required String subCategoryId,
    required String description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> imagePaths = const [],
  }) async {
    final model = await (remote as dynamic).createCatalog(
      title: title,
      subCategoryId: subCategoryId,
      description: description,
      priceMin: priceMin,
      priceMax: priceMax,
      projectTimeline: projectTimeline,
      imagePaths: imagePaths,
    ) as dynamic;
    return (model as dynamic).toEntity() as CatalogItem;
  }

  @override
  Future<CatalogItem> updateCatalog({
    required String id,
    String? title,
    String? subCategoryId,
    String? description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> newImagePaths = const [],
  }) async {
    final model = await (remote as dynamic).updateCatalog(
      id: id,
      title: title,
      subCategoryId: subCategoryId,
      description: description,
      priceMin: priceMin,
      priceMax: priceMax,
      projectTimeline: projectTimeline,
      newImagePaths: newImagePaths,
    ) as dynamic;
    return (model as dynamic).toEntity() as CatalogItem;
  }

  @override
  Future<bool> deleteCatalog(String id) async {
    return await (remote as dynamic).deleteCatalog(id) as bool;
  }
}
