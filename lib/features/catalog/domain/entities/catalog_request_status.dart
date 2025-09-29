/// Enumeration for catalog request status
enum CatalogRequestStatus {
  pending,
  accepted,
  rejected,
}

/// Extension to convert CatalogRequestStatus to string
extension CatalogRequestStatusExtension on CatalogRequestStatus {
  String get name {
    switch (this) {
      case CatalogRequestStatus.pending:
        return 'pending';
      case CatalogRequestStatus.accepted:
        return 'accepted';
      case CatalogRequestStatus.rejected:
        return 'rejected';
    }
  }

  static CatalogRequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return CatalogRequestStatus.accepted;
      case 'rejected':
        return CatalogRequestStatus.rejected;
      case 'pending':
      default:
        return CatalogRequestStatus.pending;
    }
  }
}