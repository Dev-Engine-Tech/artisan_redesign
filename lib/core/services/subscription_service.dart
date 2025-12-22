import 'package:dio/dio.dart';
import '../api/endpoints.dart';

enum SubscriptionPlan { free, bronze, silver, gold, unknown }

/// Pricing info for a subscription plan
/// Uses monthly/yearly amounts in base currency (NGN)
class SubscriptionPlanPricing {
  final double monthly;
  final double yearly;
  const SubscriptionPlanPricing({required this.monthly, required this.yearly});
}

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

  double _parseAmount(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final cleaned = v.replaceAll(',', '').trim();
      return double.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  /// Fetch available plans and their pricing from the API.
  ///
  /// Returns a map keyed by normalized plan name: bronze|silver|gold
  Future<Map<String, SubscriptionPlanPricing>> getPlanPricing() async {
    final result = <String, SubscriptionPlanPricing>{};
    try {
      final resp = await dio.get(ApiEndpoints.subscriptionPlans);
      final data = resp.data;

      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map) {
        // Allow nested formats: { data: [...] } or { plans: [...] }
        final maybe = data['data'] ?? data['plans'];
        if (maybe is List) items = maybe;
      }

      for (final raw in items) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final name = (map['plan'] ?? map['name'] ?? map['code'] ?? '')
            .toString()
            .toLowerCase();
        if (name.isEmpty) continue;

        double monthly = 0;
        double yearly = 0;

        // Try flat fields
        monthly = _parseAmount(
          map['monthly_price'] ??
              map['price_monthly'] ??
              map['amount_monthly'] ??
              map['monthly'],
        );
        yearly = _parseAmount(
          map['yearly_price'] ??
              map['price_yearly'] ??
              map['amount_yearly'] ??
              map['yearly'],
        );

        // Try nested { price: { monthly, yearly } } or { prices: {...} }
        final nestedPrice = map['price'] ?? map['prices'];
        if ((monthly == 0 || yearly == 0) && nestedPrice is Map) {
          monthly = monthly == 0
              ? _parseAmount(nestedPrice['monthly'] ?? nestedPrice['month'])
              : monthly;
          yearly = yearly == 0
              ? _parseAmount(nestedPrice['yearly'] ??
                  nestedPrice['annual'] ??
                  nestedPrice['year'])
              : yearly;
        }

        // Some APIs present only one cycle; use fallbacks if missing
        if (yearly == 0 && monthly > 0) {
          // Assume 12x monthly if yearly missing
          yearly = monthly * 12;
        } else if (monthly == 0 && yearly > 0) {
          // Assume monthly as yearly/12 if missing
          monthly = yearly / 12;
        }

        if (monthly > 0 || yearly > 0) {
          result[name] =
              SubscriptionPlanPricing(monthly: monthly, yearly: yearly);
        }
      }
    } catch (_) {
      // Return empty map on failure; callers can fallback to defaults
    }
    return result;
  }
}
