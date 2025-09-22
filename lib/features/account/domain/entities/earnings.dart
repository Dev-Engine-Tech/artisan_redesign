import 'package:equatable/equatable.dart';

class Earnings extends Equatable {
  final double total;
  final double available;
  final double pending;

  const Earnings({
    required this.total,
    required this.available,
    required this.pending,
  });

  @override
  List<Object?> get props => [total, available, pending];
}

class TransactionItem extends Equatable {
  final String id;
  final double amount;
  final String currency;
  final String status; // e.g. completed, pending, failed
  final DateTime date;
  final String? description;

  const TransactionItem({
    required this.id,
    required this.amount,
    this.currency = 'NGN',
    required this.status,
    required this.date,
    this.description,
  });

  @override
  List<Object?> get props => [id, amount, currency, status, date, description];
}
