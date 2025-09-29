import 'package:equatable/equatable.dart';

/// Entity representing a job agreement between client and artisan
class Agreement extends Equatable {
  final int id;
  final DateTime? startDate;
  final DateTime deliveryDate;
  final double agreedPayment;
  final String comment;
  final String status;
  final double? amount;
  final String? description;
  final String? deadline;

  const Agreement({
    required this.id,
    this.startDate,
    required this.deliveryDate,
    required this.agreedPayment,
    required this.comment,
    required this.status,
    this.amount,
    this.description,
    this.deadline,
  });

  @override
  List<Object?> get props => [
    id,
    startDate,
    deliveryDate,
    agreedPayment,
    comment,
    status,
    amount,
    description,
    deadline,
  ];

  Agreement copyWith({
    int? id,
    DateTime? startDate,
    DateTime? deliveryDate,
    double? agreedPayment,
    String? comment,
    String? status,
    double? amount,
    String? description,
    String? deadline,
  }) {
    return Agreement(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      agreedPayment: agreedPayment ?? this.agreedPayment,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
    );
  }
}