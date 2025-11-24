import '../../domain/entities/business_settings.dart';

class BusinessSettingsModel extends BusinessSettings {
  const BusinessSettingsModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.companyLogo,
    super.primaryColor,
    super.secondaryColor,
    super.businessAddress,
    super.invoiceStyle,
    super.cacNumber,
    super.taxId,
    super.registrationNumber,
    super.additionalDocuments,
  });

  factory BusinessSettingsModel.fromJson(Map<String, dynamic> json) {
    return BusinessSettingsModel(
      id: json['id']?.toString() ?? '',
      companyLogo: json['company_logo'],
      primaryColor: json['primary_color'],
      secondaryColor: json['secondary_color'],
      businessAddress: json['business_address'],
      invoiceStyle: _invoiceStyleFromString(json['invoice_style']),
      cacNumber: json['cac_number'],
      taxId: json['tax_id'],
      registrationNumber: json['registration_number'],
      additionalDocuments: json['additional_documents'] != null
          ? Map<String, String>.from(json['additional_documents'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_logo': companyLogo,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'business_address': businessAddress,
      'invoice_style': _invoiceStyleToString(invoiceStyle),
      'cac_number': cacNumber,
      'tax_id': taxId,
      'registration_number': registrationNumber,
      'additional_documents': additionalDocuments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BusinessSettingsModel.fromEntity(BusinessSettings entity) {
    return BusinessSettingsModel(
      id: entity.id,
      companyLogo: entity.companyLogo,
      primaryColor: entity.primaryColor,
      secondaryColor: entity.secondaryColor,
      businessAddress: entity.businessAddress,
      invoiceStyle: entity.invoiceStyle,
      cacNumber: entity.cacNumber,
      taxId: entity.taxId,
      registrationNumber: entity.registrationNumber,
      additionalDocuments: entity.additionalDocuments,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  BusinessSettings toEntity() => BusinessSettings(
        id: id,
        companyLogo: companyLogo,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        businessAddress: businessAddress,
        invoiceStyle: invoiceStyle,
        cacNumber: cacNumber,
        taxId: taxId,
        registrationNumber: registrationNumber,
        additionalDocuments: additionalDocuments,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static InvoiceStyle _invoiceStyleFromString(String? value) {
    if (value == null) return InvoiceStyle.classic;
    return InvoiceStyle.values.firstWhere(
      (style) => style.name == value,
      orElse: () => InvoiceStyle.classic,
    );
  }

  static String _invoiceStyleToString(InvoiceStyle style) {
    return style.name;
  }
}
