import 'package:dio/dio.dart';
import '../api/endpoints.dart';

enum SubscriptionPlan { free, bronze, silver, gold, unknown }

class SubscriptionService {
  final Dio dio;
  SubscriptionService(this.dio);

  Future<SubscriptionPlan> getCurrentPlan() async {
    try {
      final resp = await dio.get(ApiEndpoints.subscriptionCurrent);
      if (resp.statusCode == 200 && resp.data != null) {
        final data = resp.data;
        String? plan;
        if (data is Map) {
          if (data['plan'] != null) {
            plan = data['plan'].toString();
          } else if (data['data'] is Map && (data['data']['plan'] != null)) {
            plan = data['data']['plan'].toString();
          } else if (data['name'] != null) {
            plan = data['name'].toString();
          }
        }
        if (plan != null) {
          final p = plan.toLowerCase();
          if (p.contains('free')) return SubscriptionPlan.free;
          if (p.contains('bronze')) return SubscriptionPlan.bronze;
          if (p.contains('silver')) return SubscriptionPlan.silver;
          if (p.contains('gold')) return SubscriptionPlan.gold;
        }
      }
    } catch (_) {}
    return SubscriptionPlan.unknown;
  }
}
