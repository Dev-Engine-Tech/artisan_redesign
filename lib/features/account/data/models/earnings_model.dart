import '../../domain/entities/earnings.dart';

class EarningsModel extends Earnings {
  const EarningsModel({required double total, required double available, required double pending})
      : super(total: total, available: available, pending: pending);

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
    required String id,
    required double amount,
    String currency = 'NGN',
    required String status,
    required DateTime date,
    String? description,
  }) : super(
          id: id,
          amount: amount,
          currency: currency,
          status: status,
          date: date,
          description: description,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'NGN',
      status: json['status']?.toString() ?? 'unknown',
      date: DateTime.tryParse(json['date']?.toString() ?? json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      description: json['description']?.toString(),
    );
  }
}
