import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
import '../models/catalog_item_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CatalogItemModel>> getMyCatalogItems({int page = 1});
  Future<List<CatalogItemModel>> getCatalogByUser(String userId,
      {int page = 1});

  Future<CatalogItemModel> createCatalog({
    required String title,
    required String subCategoryId,
    required String description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> imagePaths = const [],
    bool instantSelling = false,
    String? brand,
    String? condition,
    String? salesCategory,
    bool warranty = false,
    bool delivery = false,
  });

  Future<CatalogItemModel> updateCatalog({
    required String id,
    String? title,
    String? subCategoryId,
    String? description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> newImagePaths = const [],
    bool? instantSelling,
    String? brand,
    String? condition,
    String? salesCategory,
    bool? warranty,
    bool? delivery,
  });

  Future<bool> deleteCatalog(String id);
}

class CatalogRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(super.dio);

  @override
  Future<List<CatalogItemModel>> getMyCatalogItems({int page = 1}) => getList(
        ApiEndpoints.myCatalogItems,
        fromJson: CatalogItemModel.fromJson,
        queryParams: {'page': page},
      );

  @override
  Future<List<CatalogItemModel>> getCatalogByUser(String userId,
          {int page = 1}) =>
      getList(
        ApiEndpoints.catalogByUser,
        fromJson: CatalogItemModel.fromJson,
        queryParams: {'user_id': userId, 'page': page},
      );

  @override
  Future<CatalogItemModel> createCatalog({
    required String title,
    required String subCategoryId,
    required String description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> imagePaths = const [],
    bool instantSelling = false,
    String? brand,
    String? condition,
    String? salesCategory,
    bool warranty = false,
    bool delivery = false,
  }) async {
    final form = FormData();
    form.fields.addAll([
      MapEntry('title', title),
      MapEntry('sub_category', subCategoryId),
      MapEntry('description', description),
      if (priceMin != null) MapEntry('price_min', priceMin.toString()),
      if (priceMax != null) MapEntry('price_max', priceMax.toString()),
      if (projectTimeline != null)
        MapEntry('project_timeline', projectTimeline),
      MapEntry('instant_selling', instantSelling.toString()),
      if (brand != null && brand.isNotEmpty) MapEntry('brand', brand),
      if (condition != null && condition.isNotEmpty)
        MapEntry('condition', condition),
      if (salesCategory != null && salesCategory.isNotEmpty)
        MapEntry('sales_category', salesCategory),
      MapEntry('warranty', warranty.toString()),
      MapEntry('delivery', delivery.toString()),
    ]);
    for (var i = 0; i < imagePaths.length; i++) {
      form.files.add(MapEntry(
          'pictures[$i]', await MultipartFile.fromFile(imagePaths[i])));
    }
    final resp = await dio.post(ApiEndpoints.createCatalog,
        data: form, options: Options(contentType: 'multipart/form-data'));
    if (resp.statusCode != null &&
        resp.statusCode! >= 200 &&
        resp.statusCode! < 300) {
      final data = resp.data is Map
          ? Map<String, dynamic>.from(resp.data)
          : <String, dynamic>{};
      return CatalogItemModel.fromJson(data);
    }
    throw DioException(
        requestOptions: resp.requestOptions,
        response: resp,
        error: 'Failed to create catalog');
  }

  @override
  Future<CatalogItemModel> updateCatalog({
    required String id,
    String? title,
    String? subCategoryId,
    String? description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> newImagePaths = const [],
    bool? instantSelling,
    String? brand,
    String? condition,
    String? salesCategory,
    bool? warranty,
    bool? delivery,
  }) async {
    final form = FormData();
    if (title != null) {
      form.fields.add(MapEntry('title', title));
    }
    if (subCategoryId != null) {
      form.fields.add(MapEntry('sub_category', subCategoryId));
    }
    if (description != null) {
      form.fields.add(MapEntry('description', description));
    }
    if (priceMin != null) {
      form.fields.add(MapEntry('price_min', priceMin.toString()));
    }
    if (priceMax != null) {
      form.fields.add(MapEntry('price_max', priceMax.toString()));
    }
    if (projectTimeline != null) {
      form.fields.add(MapEntry('project_timeline', projectTimeline));
    }
    if (instantSelling != null) {
      form.fields.add(MapEntry('instant_selling', instantSelling.toString()));
    }
    if (brand != null && brand.isNotEmpty) {
      form.fields.add(MapEntry('brand', brand));
    }
    if (condition != null && condition.isNotEmpty) {
      form.fields.add(MapEntry('condition', condition));
    }
    if (salesCategory != null && salesCategory.isNotEmpty) {
      form.fields.add(MapEntry('sales_category', salesCategory));
    }
    if (warranty != null) {
      form.fields.add(MapEntry('warranty', warranty.toString()));
    }
    if (delivery != null) {
      form.fields.add(MapEntry('delivery', delivery.toString()));
    }
    for (var i = 0; i < newImagePaths.length; i++) {
      form.files.add(MapEntry(
          'pictures[$i]', await MultipartFile.fromFile(newImagePaths[i])));
    }
    final url = '${ApiEndpoints.updateCatalog}$id/';
    final resp = await dio.put(url,
        data: form, options: Options(contentType: 'multipart/form-data'));
    if (resp.statusCode != null &&
        resp.statusCode! >= 200 &&
        resp.statusCode! < 300) {
      final data = resp.data is Map
          ? Map<String, dynamic>.from(resp.data)
          : <String, dynamic>{};
      return CatalogItemModel.fromJson(data);
    }
    throw DioException(
        requestOptions: resp.requestOptions,
        response: resp,
        error: 'Failed to update catalog');
  }

  @override
  Future<bool> deleteCatalog(String id) async {
    final url = '${ApiEndpoints.deleteCatalog}$id/';
    final resp = await dio.delete(url);
    return resp.statusCode != null &&
        resp.statusCode! >= 200 &&
        resp.statusCode! < 300;
  }
}
