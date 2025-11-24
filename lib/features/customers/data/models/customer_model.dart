import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    super.phone,
    super.company,
    super.address,
    super.city,
    super.state,
    super.country,
    super.postalCode,
    super.notes,
    super.totalInvoices,
    super.totalAmount,
    super.lastInvoiceDate,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String)
        return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? 0;
      return 0;
    }

    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      company: json['company'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'] ?? json['postalCode'],
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : DateTime.now(),
      totalInvoices: _toInt(json['total_invoices'] ?? json['totalInvoices']),
      totalAmount: _toDouble(json['total_amount'] ?? json['totalAmount']),
      lastInvoiceDate: json['last_invoice_date'] != null
          ? DateTime.parse(json['last_invoice_date'])
          : json['lastInvoiceDate'] != null
              ? DateTime.parse(json['lastInvoiceDate'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'company': company,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_invoices': totalInvoices,
      'total_amount': totalAmount,
      'last_invoice_date': lastInvoiceDate?.toIso8601String(),
    };
  }

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      company: customer.company,
      address: customer.address,
      city: customer.city,
      state: customer.state,
      country: customer.country,
      postalCode: customer.postalCode,
      notes: customer.notes,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
      totalInvoices: customer.totalInvoices,
      totalAmount: customer.totalAmount,
      lastInvoiceDate: customer.lastInvoiceDate,
    );
  }

  Customer toEntity() => Customer(
        id: id,
        name: name,
        email: email,
        phone: phone,
        company: company,
        address: address,
        city: city,
        state: state,
        country: country,
        postalCode: postalCode,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
        totalInvoices: totalInvoices,
        totalAmount: totalAmount,
        lastInvoiceDate: lastInvoiceDate,
      );
}
