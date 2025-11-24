import 'package:dio/dio.dart';
import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
import '../models/business_settings_model.dart';

abstract class BusinessSettingsRemoteDataSource {
  Future<BusinessSettingsModel> getBusinessSettings();
  Future<BusinessSettingsModel> updateBusinessSettings(
      Map<String, dynamic> data);
  Future<String> uploadCompanyLogo(String filePath);
}

class BusinessSettingsRemoteDataSourceImpl extends BaseRemoteDataSource
    implements BusinessSettingsRemoteDataSource {
  BusinessSettingsRemoteDataSourceImpl(super.dio);

  @override
  Future<BusinessSettingsModel> getBusinessSettings() => get(
        ApiEndpoints.businessSettings,
        fromJson: BusinessSettingsModel.fromJson,
      );

  @override
  Future<BusinessSettingsModel> updateBusinessSettings(
    Map<String, dynamic> data,
  ) =>
      put(
        ApiEndpoints.businessSettings,
        data: data,
        fromJson: BusinessSettingsModel.fromJson,
      );

  @override
  Future<String> uploadCompanyLogo(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'logo': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await dio.post(
      ApiEndpoints.uploadCompanyLogo,
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['logo_url'] != null) {
        return data['logo_url'] as String;
      }
      if (data is Map && data['company_logo'] != null) {
        return data['company_logo'] as String;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Logo URL not found in response',
      );
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      message: 'Failed to upload logo: ${response.statusCode}',
    );
  }
}
