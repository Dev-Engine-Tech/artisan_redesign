import '../../domain/entities/agreement.dart';

class AgreementModel extends Agreement {
  const AgreementModel({
    required super.id,
    super.startDate,
    required super.deliveryDate,
    required super.agreedPayment,
    required super.comment,
    required super.status,
  });

  factory AgreementModel.fromJson(Map<String, dynamic> json) {
    return AgreementModel(
      id: json['id'] ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      deliveryDate: DateTime.parse(json['delivery_date']),
      agreedPayment: (json['agreed_payment'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate?.toIso8601String(),
      'delivery_date': deliveryDate.toIso8601String(),
      'agreed_payment': agreedPayment,
      'comment': comment,
      'status': status,
    };
  }

  Agreement toEntity() {
    return Agreement(
      id: id,
      startDate: startDate,
      deliveryDate: deliveryDate,
      agreedPayment: agreedPayment,
      comment: comment,
      status: status,
    );
  }
}
