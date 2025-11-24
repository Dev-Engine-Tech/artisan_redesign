import 'package:dio/dio.dart';
import 'package:artisans_circle/core/api/endpoints.dart' as endpoints_v1;
// Note: not all endpoint constant sets include location routes; stick to v1 and raw paths.

class LocationState {
  final int id;
  final String name;
  const LocationState({required this.id, required this.name});
}

class LocationLga {
  final int id;
  final String name;
  final int? stateId;
  const LocationLga({required this.id, required this.name, this.stateId});
}

abstract class LocationRemoteDataSource {
  Future<List<LocationState>> getStates();
  Future<List<LocationLga>> getLgasByState(int stateId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio dio;
  LocationRemoteDataSourceImpl(this.dio);

  @override
  Future<List<LocationState>> getStates() async {
    // Try both endpoint constant sets for compatibility
    final candidates = <String>[
      endpoints_v1.ApiEndpoints.states, // '/locations/states/'
      '/locations/states/',
      '/location/states/',
    ];
    for (final path in candidates) {
      try {
        final resp = await dio.get(path);
        if (resp.statusCode != null &&
            resp.statusCode! >= 200 &&
            resp.statusCode! < 300) {
          final data = resp.data;
          final list = _extractList(data);
          return list
              .map((e) {
                final m = Map<String, dynamic>.from(e as Map);
                final id = _toInt(m['id'] ?? m['state_id']);
                final name = (m['name'] ?? m['state'] ?? m['state_name'] ?? '')
                    .toString();
                return LocationState(id: id, name: name);
              })
              .where((s) => s.name.isNotEmpty)
              .toList();
        }
      } catch (_) {
        // try next
      }
    }
    throw DioException(
        requestOptions: RequestOptions(path: candidates.first),
        error: 'Failed to load states');
  }

  @override
  Future<List<LocationLga>> getLgasByState(int stateId) async {
    final candidates = <(String, Map<String, dynamic>?)>[
      (endpoints_v1.ApiEndpoints.lgasByState(stateId), null),
      (endpoints_v1.ApiEndpoints.lgas, {'state': stateId}), // '/locations/lga/'
      ('/locations/lga/$stateId/', null),
      ('/locations/lga/', {'state': stateId}),
      ('/location/lgas/$stateId/', null),
      ('/location/lgas/', {'state': stateId}),
    ];
    for (final cand in candidates) {
      try {
        final resp = await dio.get(cand.$1, queryParameters: cand.$2);
        if (resp.statusCode != null &&
            resp.statusCode! >= 200 &&
            resp.statusCode! < 300) {
          final data = resp.data;
          final list = _extractList(data);
          return list
              .map((e) {
                final m = Map<String, dynamic>.from(e as Map);
                final id = _toInt(m['id'] ?? m['lga_id']);
                final name =
                    (m['name'] ?? m['lga'] ?? m['lga_name'] ?? '').toString();
                return LocationLga(id: id, name: name, stateId: stateId);
              })
              .where((l) => l.name.isNotEmpty)
              .toList();
        }
      } catch (_) {
        // try next
      }
    }
    throw DioException(
        requestOptions: RequestOptions(path: candidates.first.$1),
        error: 'Failed to load LGAs');
  }

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'] as List;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
