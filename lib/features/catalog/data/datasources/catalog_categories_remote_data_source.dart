import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';

class CategoryItem {
  final String id;
  final String name;
  const CategoryItem(this.id, this.name);
}

class CategoryGroup {
  final String id;
  final String name;
  final List<CategoryItem> subcategories;
  const CategoryGroup({required this.id, required this.name, required this.subcategories});
}

abstract class CatalogCategoriesRemoteDataSource {
  Future<List<CategoryGroup>> fetchCategories();
}

class CatalogCategoriesRemoteDataSourceImpl implements CatalogCategoriesRemoteDataSource {
  final Dio dio;
  CatalogCategoriesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CategoryGroup>> fetchCategories() async {
    final resp = await dio.get(ApiEndpoints.jobCategories);
    if (resp.statusCode != null && resp.statusCode! >= 200 && resp.statusCode! < 300) {
      final data = resp.data;
      final List<CategoryGroup> groups = [];
      List list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['results'] is List) {
        list = data['results'] as List;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else {
        list = const [];
      }
      for (final raw in list) {
        final m = Map<String, dynamic>.from(raw as Map);
        final id = (m['id'] ?? m['category_id'] ?? '').toString();
        final name = (m['name'] ?? m['title'] ?? m['category'] ?? '').toString();
        final subsRaw = (m['subcategories'] as List?) ??
            (m['children'] as List?) ??
            (m['subs'] as List?) ??
            const [];
        final subs = subsRaw.map((e) {
          final sm = Map<String, dynamic>.from(e as Map);
          final sid = (sm['id'] ?? sm['sub_category_id'] ?? '').toString();
          final sname = (sm['name'] ?? sm['title'] ?? sm['sub_category'] ?? '').toString();
          return CategoryItem(sid, sname);
        }).toList();
        groups.add(CategoryGroup(id: id, name: name, subcategories: subs));
      }
      return groups;
    }
    throw DioException(
        requestOptions: resp.requestOptions, response: resp, error: 'Failed to fetch categories');
  }
}
