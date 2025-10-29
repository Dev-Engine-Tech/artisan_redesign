import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
import '../models/catalog_request_model.dart';

abstract class CatalogRequestsRemoteDataSource {
  Future<(List<CatalogRequestModel>, String?)> fetchRequests({String? next});
  Future<CatalogRequestModel> fetchRequestDetails(String id);
  Future<bool> respond(String id,
      {required bool approve, String? reason, String? message});
}

class CatalogRequestsRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CatalogRequestsRemoteDataSource {
  CatalogRequestsRemoteDataSourceImpl(super.dio);

  @override
  Future<(List<CatalogRequestModel>, String?)> fetchRequests(
      {String? next}) async {
    final url = next ?? ApiEndpoints.catalogRequests;

    final resp = await dio.get(url);
    if (resp.statusCode != null &&
        resp.statusCode! >= 200 &&
        resp.statusCode! < 300) {
      final data = resp.data;
      // ignore: avoid_print

      // ${data.runtimeType} keys=${data is Map ? data.keys.toList() : []}');
      List list;
      String? nextUrl;
      if (data is Map) {
        list = (data['results'] as List?) ??
            (data['data'] as List?) ??
            (data['items'] as List?) ??
            const [];
        // Some variants: { catalog_requests: { results: [...] } }
        final cr = data['catalog_requests'];
        if (list.isEmpty && cr is Map && cr['results'] is List) {
          list = cr['results'] as List;
        }
        if (list.isEmpty && data['catalog_requests'] is List) {
          list = data['catalog_requests'] as List;
        }
        nextUrl = data['next'] as String?;
        if (nextUrl == null && cr is Map) {
          nextUrl = cr['next'] as String?;
        }
      } else if (data is List) {
        list = data;
      } else {
        list = const [];
      }
      final models = list
          .map((e) =>
              CatalogRequestModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return (models, nextUrl);
    }
    throw DioException(
        requestOptions: resp.requestOptions,
        response: resp,
        error: 'Failed to fetch catalog requests');
  }

  @override
  Future<CatalogRequestModel> fetchRequestDetails(String id) => get(
        '${ApiEndpoints.catalogRequestDetails}$id/',
        fromJson: CatalogRequestModel.fromJson,
      );

  @override
  Future<bool> respond(String id,
      {required bool approve, String? reason, String? message}) async {
    try {
      await postVoid(
        ApiEndpoints.respondToCatalogRequest,
        data: {
          'request_id': id,
          'action': approve ? 'approve' : 'decline',
          if (!approve && reason != null) 'decline_reason': reason,
          if (!approve && message != null) 'decline_message': message,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
