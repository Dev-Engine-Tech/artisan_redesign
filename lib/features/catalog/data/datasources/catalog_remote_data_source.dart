import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
import '../models/catalog_item_model.dart';

abstract class CatalogRemoteDataSource {
  Future<List<CatalogItemModel>> getMyCatalogItems({int page = 1});
  Future<List<CatalogItemModel>> getCatalogByUser(String userId,
      {int page = 1});
  Future<CatalogItemModel> getCatalogDetails(String id);

  Future<CatalogItemModel> createCatalog({
    required String title,
    required String subCategoryId,
    required String description,
    int? priceMin,
    int? priceMax,
    String? projectTimeline,
    List<String> imagePaths = const [],
    bool instantSelling = false,
    bool? hotSale,
    String? discountPercent,
    String? badge,
    num? priceNumeric,
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
    bool? hotSale,
    String? discountPercent,
    String? badge,
    num? priceNumeric,
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
  Future<List<CatalogItemModel>> getMyCatalogItems({int page = 1}) async {
    // Prefer new endpoint where GET /catalog/api/catalog/products/ returns own catalogs
    final candidates = <String>[
      ApiEndpoints.catalogProducts,
      ApiEndpoints.myCatalogItems,
    ];
    DioException? last;
    for (final path in candidates) {
      try {
        return await getList(
          path,
          fromJson: CatalogItemModel.fromJson,
          queryParams: {'page': page},
        );
      } catch (e) {
        last = e is DioException
            ? e
            : DioException(
                requestOptions: RequestOptions(path: path), error: e);
        // try next
      }
    }
    throw last ??
        DioException(
          requestOptions: RequestOptions(path: candidates.first),
          error: 'Failed to load my catalogs',
        );
  }

  @override
  Future<CatalogItemModel> getCatalogDetails(String id) async {
    final intId = int.tryParse(id);
    final path = intId != null
        ? ApiEndpoints.catalogProductDetails(intId)
        : '/catalog/api/catalog/product/details/$id/';
    return get(
      path,
      fromJson: CatalogItemModel.fromJson,
    );
  }

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
    bool? hotSale,
    String? discountPercent,
    String? badge,
    num? priceNumeric,
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
      if (hotSale != null) MapEntry('hot_sale', hotSale.toString()),
      if (discountPercent != null && discountPercent.isNotEmpty)
        MapEntry('discount_percent', discountPercent),
      if (badge != null) MapEntry('badge', badge),
      if (priceNumeric != null)
        MapEntry('price_numeric', priceNumeric.toString()),
      if (brand != null && brand.isNotEmpty) MapEntry('brand', brand),
      if (condition != null && condition.isNotEmpty)
        MapEntry('condition', _mapCondition(condition)),
      if (salesCategory != null && salesCategory.isNotEmpty)
        MapEntry('sales_category', salesCategory),
      MapEntry('has_warranty', warranty.toString()),
      MapEntry('delivery_available', delivery.toString()),
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
    bool? hotSale,
    String? discountPercent,
    String? badge,
    num? priceNumeric,
    String? brand,
    String? condition,
    String? salesCategory,
    bool? warranty,
    bool? delivery,
  }) async {
    final url = '${ApiEndpoints.updateCatalog}$id/';

    // If no new images provided, use PATCH with JSON body as per API guidance.
    if (newImagePaths.isEmpty) {
      final payload = <String, dynamic>{};
      if (title != null) payload['title'] = title;
      if (subCategoryId != null) payload['sub_category'] = subCategoryId;
      if (description != null) payload['description'] = description;
      if (priceMin != null) payload['price_min'] = priceMin.toString();
      if (priceMax != null) payload['price_max'] = priceMax.toString();
      if (projectTimeline != null) {
        payload['project_timeline'] = projectTimeline;
      }
      // Map optional flags to API field names if provided
      if (warranty != null) payload['has_warranty'] = warranty;
      if (delivery != null) payload['delivery_available'] = delivery;
      if (hotSale != null) payload['hot_sale'] = hotSale;
      if (discountPercent != null && discountPercent.isNotEmpty) {
        payload['discount_percent'] = discountPercent;
      }
      if (badge != null) payload['badge'] = badge;
      if (priceNumeric != null) payload['price_numeric'] = priceNumeric;
      if (instantSelling != null) payload['instant_selling'] = instantSelling;
      if (condition != null && condition.isNotEmpty) {
        payload['condition'] = _mapCondition(condition);
      }
      final resp = await dio.patch(url, data: payload);
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

    // Otherwise, PUT multipart including pictures (replaces existing)
    final form = FormData();
    if (title != null) form.fields.add(MapEntry('title', title));
    if (subCategoryId != null)
      form.fields.add(MapEntry('sub_category', subCategoryId));
    if (description != null)
      form.fields.add(MapEntry('description', description));
    if (priceMin != null)
      form.fields.add(MapEntry('price_min', priceMin.toString()));
    if (priceMax != null)
      form.fields.add(MapEntry('price_max', priceMax.toString()));
    if (projectTimeline != null)
      form.fields.add(MapEntry('project_timeline', projectTimeline));
    if (warranty != null)
      form.fields.add(MapEntry('has_warranty', warranty.toString()));
    if (delivery != null)
      form.fields.add(MapEntry('delivery_available', delivery.toString()));
    if (hotSale != null)
      form.fields.add(MapEntry('hot_sale', hotSale.toString()));
    if (discountPercent != null && discountPercent.isNotEmpty) {
      form.fields.add(MapEntry('discount_percent', discountPercent));
    }
    if (badge != null) form.fields.add(MapEntry('badge', badge));
    if (priceNumeric != null)
      form.fields.add(MapEntry('price_numeric', priceNumeric.toString()));
    if (instantSelling != null)
      form.fields.add(MapEntry('instant_selling', instantSelling.toString()));
    if (condition != null && condition.isNotEmpty) {
      form.fields.add(MapEntry('condition', _mapCondition(condition)));
    }
    // Include pictures (max 4)
    final maxPics = newImagePaths.length > 4 ? 4 : newImagePaths.length;
    for (var i = 0; i < maxPics; i++) {
      // Use pictures field as repeated entries
      form.files.add(
          MapEntry('pictures', await MultipartFile.fromFile(newImagePaths[i])));
    }
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

  String _mapCondition(String value) {
    final v = value.trim().toLowerCase();
    if (v.contains('brand')) return 'new';
    if (v.contains('foreign')) return 'foreign_used';
    if (v.contains('local')) return 'local_used';
    // If already normalized, pass through
    if (v == 'new' || v == 'foreign_used' || v == 'local_used') return v;
    return v; // fallback
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
