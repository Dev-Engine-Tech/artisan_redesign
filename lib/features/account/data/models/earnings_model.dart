import '../../domain/entities/earnings.dart';

class EarningsModel extends Earnings {
  const EarningsModel(
      {required super.total, required super.available, required super.pending});

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      total: (json['total'] as num?)?.toDouble() ??
          (json['total_earnings'] as num?)?.toDouble() ??
          0.0,
      available: (json['available'] as num?)?.toDouble() ??
          (json['available_balance'] as num?)?.toDouble() ??
          0.0,
      pending: (json['pending'] as num?)?.toDouble() ??
          (json['pending_balance'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class TransactionModel extends TransactionItem {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.status,
    required super.date,
    super.currency,
    super.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'NGN',
      status: json['status']?.toString() ?? 'unknown',
      date: DateTime.tryParse(json['date']?.toString() ??
              json['created_at']?.toString() ??
              '') ??
          DateTime.now(),
      description: json['description']?.toString(),
    );
  }
}
