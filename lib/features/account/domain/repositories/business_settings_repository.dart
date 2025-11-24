import '../entities/business_settings.dart';

abstract class BusinessSettingsRepository {
  Future<BusinessSettings> getBusinessSettings();
  Future<BusinessSettings> updateBusinessSettings(BusinessSettings settings);
  Future<String> uploadCompanyLogo(String filePath);
}
