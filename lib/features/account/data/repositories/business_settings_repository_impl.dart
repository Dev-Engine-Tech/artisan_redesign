import '../../domain/entities/business_settings.dart';
import '../../domain/repositories/business_settings_repository.dart';
import '../datasources/business_settings_remote_data_source.dart';
import '../models/business_settings_model.dart';

class BusinessSettingsRepositoryImpl implements BusinessSettingsRepository {
  final BusinessSettingsRemoteDataSource remoteDataSource;

  BusinessSettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<BusinessSettings> getBusinessSettings() async {
    final model = await remoteDataSource.getBusinessSettings();
    return model.toEntity();
  }

  @override
  Future<BusinessSettings> updateBusinessSettings(
      BusinessSettings settings) async {
    final data = BusinessSettingsModel.fromEntity(settings).toJson();
    final updated = await remoteDataSource.updateBusinessSettings(data);
    return updated.toEntity();
  }

  @override
  Future<String> uploadCompanyLogo(String filePath) async {
    return await remoteDataSource.uploadCompanyLogo(filePath);
  }
}
