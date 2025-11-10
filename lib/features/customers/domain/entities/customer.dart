import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? company;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalInvoices;
  final double totalAmount;
  final DateTime? lastInvoiceDate;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.company,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.notes,
    this.totalInvoices = 0,
    this.totalAmount = 0.0,
    this.lastInvoiceDate,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? company,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalInvoices,
    double? totalAmount,
    DateTime? lastInvoiceDate,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalInvoices: totalInvoices ?? this.totalInvoices,
      totalAmount: totalAmount ?? this.totalAmount,
      lastInvoiceDate: lastInvoiceDate ?? this.lastInvoiceDate,
    );
  }

  String get initials {
    final names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }

  String get displayLocation {
    final parts = <String>[];
    if (city?.isNotEmpty == true) parts.add(city!);
    if (state?.isNotEmpty == true) parts.add(state!);
    if (country?.isNotEmpty == true) parts.add(country!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        company,
        address,
        city,
        state,
        country,
        postalCode,
        notes,
        createdAt,
        updatedAt,
        totalInvoices,
        totalAmount,
        lastInvoiceDate,
      ];
}
