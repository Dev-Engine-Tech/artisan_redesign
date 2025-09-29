import 'package:equatable/equatable.dart';

/// Entity representing a material used in a job application
class Material extends Equatable {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String unit;

  const Material({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.unit,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    quantity,
    price,
    unit,
  ];

  /// Calculate total price for this material
  double get totalPrice => quantity * price;

  Material copyWith({
    int? id,
    String? name,
    String? description,
    int? quantity,
    double? price,
    String? unit,
  }) {
    return Material(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      unit: unit ?? this.unit,
    );
  }
}