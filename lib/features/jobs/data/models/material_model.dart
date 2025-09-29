import '../../domain/entities/material.dart';

class MaterialModel extends Material {
  const MaterialModel({
    required super.id,
    required super.name,
    required super.description,
    required super.quantity,
    required super.price,
    required super.unit,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'unit': unit,
    };
  }

  Material toEntity() {
    return Material(
      id: id,
      name: name,
      description: description,
      quantity: quantity,
      price: price,
      unit: unit,
    );
  }
}
