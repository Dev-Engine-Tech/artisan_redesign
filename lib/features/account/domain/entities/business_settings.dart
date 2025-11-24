import 'package:equatable/equatable.dart';

/// Invoice template styles
enum InvoiceStyle {
  classic,
  modern,
  minimal,
  professional,
  creative,
  elegant,
  bold,
  corporate,
  artistic,
  traditional,
}

/// Business settings for artisan profile customization
class BusinessSettings extends Equatable {
  final String id;
  final String? companyLogo;
  final String? primaryColor;
  final String? secondaryColor;
  final String? businessAddress;
  final InvoiceStyle invoiceStyle;
  final String? cacNumber;
  final String? taxId;
  final String? registrationNumber;
  final Map<String, String>? additionalDocuments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessSettings({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.companyLogo,
    this.primaryColor,
    this.secondaryColor,
    this.businessAddress,
    this.invoiceStyle = InvoiceStyle.classic,
    this.cacNumber,
    this.taxId,
    this.registrationNumber,
    this.additionalDocuments,
  });

  BusinessSettings copyWith({
    String? id,
    String? companyLogo,
    String? primaryColor,
    String? secondaryColor,
    String? businessAddress,
    InvoiceStyle? invoiceStyle,
    String? cacNumber,
    String? taxId,
    String? registrationNumber,
    Map<String, String>? additionalDocuments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessSettings(
      id: id ?? this.id,
      companyLogo: companyLogo ?? this.companyLogo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      businessAddress: businessAddress ?? this.businessAddress,
      invoiceStyle: invoiceStyle ?? this.invoiceStyle,
      cacNumber: cacNumber ?? this.cacNumber,
      taxId: taxId ?? this.taxId,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      additionalDocuments: additionalDocuments ?? this.additionalDocuments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyLogo,
        primaryColor,
        secondaryColor,
        businessAddress,
        invoiceStyle,
        cacNumber,
        taxId,
        registrationNumber,
        additionalDocuments,
        createdAt,
        updatedAt,
      ];
}
