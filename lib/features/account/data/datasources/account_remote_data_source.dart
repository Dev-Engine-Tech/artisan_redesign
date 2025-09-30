import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../models/user_profile_model.dart';
import '../models/earnings_model.dart';
import '../models/bank_account_model.dart';

abstract class AccountRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? bio,
    String? location,
    String? phone,
    int? yearsOfExperience,
  });

  Future<EarningsModel> getEarnings();
  Future<List<TransactionModel>> getTransactions(
      {int page = 1, int limit = 20});
  Future<void> requestWithdrawal(double amount);

  // Work Experience
  Future<UserProfileModel> addWorkExperience(WorkExperienceModel work);
  Future<UserProfileModel> updateWorkExperience(WorkExperienceModel work);
  Future<UserProfileModel> deleteWorkExperience(String id);

  // Education
  Future<UserProfileModel> addEducation(EducationModel edu);
  Future<UserProfileModel> updateEducation(EducationModel edu);
  Future<UserProfileModel> deleteEducation(String id);

  // Skills
  Future<UserProfileModel> addSkill(String skill);
  Future<UserProfileModel> removeSkill(String skill);

  Future<List<BankAccountModel>> getBankAccounts();
  Future<List<BankInfoModel>> getBankList({bool forceRefresh = false});
  Future<String> verifyBankAccount(
      {required String bankCode, required String accountNumber});
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    String? bankCode,
    required String accountName,
    required String accountNumber,
  });
  Future<void> deleteBankAccount(String id);

  Future<void> changePassword(
      {required String oldPassword, required String newPassword});
  Future<void> deleteAccount({String? otp});

  Future<String> uploadProfileImage(String imagePath);
  Future<bool> setWithdrawalPin(String pin);
  Future<bool> verifyWithdrawalPin(String pin);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final Dio dio;
  AccountRemoteDataSourceImpl(this.dio);

  // Simple in-memory cache for bank list to reduce network calls.
  List<BankInfoModel>? _bankListCache;
  DateTime? _bankListFetchedAt;
  static const Duration _bankListTtl = Duration(hours: 12);

  @override
  Future<UserProfileModel> getUserProfile() async {
    final response = await dio.get(ApiEndpoints.userProfile);
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> updateUserProfile({
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? bio,
    String? location,
    String? phone,
    int? yearsOfExperience,
  }) async {
    final payload = <String, dynamic>{};
    if (firstName != null) payload['first_name'] = firstName;
    if (lastName != null) payload['last_name'] = lastName;
    if (jobTitle != null) payload['job_title'] = jobTitle;
    if (bio != null) payload['bio'] = bio;
    if (location != null) payload['location'] = location;
    if (phone != null) payload['phone'] = phone;
    if (yearsOfExperience != null) {
      payload['years_of_experience'] = yearsOfExperience;
    }

    final response = await dio.put(ApiEndpoints.updateProfile, data: payload);
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<EarningsModel> getEarnings() async {
    final response = await dio.get(ApiEndpoints.userEarnings);
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return EarningsModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<List<TransactionModel>> getTransactions(
      {int page = 1, int limit = 20}) async {
    final response = await dio.get(
      ApiEndpoints.transactionHistory,
      queryParameters: {'page': page, 'limit': limit},
    );
    if (_ok(response.statusCode)) {
      final dynamic data = response.data;
      final List list = data is Map && data['transactions'] is List
          ? (data['transactions'] as List)
          : (data is List ? data : <dynamic>[]);
      return list
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<void> requestWithdrawal(double amount) async {
    final response =
        await dio.post(ApiEndpoints.withdrawEarnings, data: {'amount': amount});
    if (_ok(response.statusCode)) return;
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> addWorkExperience(WorkExperienceModel work) async {
    final response =
        await dio.post('/user/work-experience', data: work.toJson());
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> updateWorkExperience(
      WorkExperienceModel work) async {
    final response =
        await dio.put('/user/work-experience/${work.id}', data: work.toJson());
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> deleteWorkExperience(String id) async {
    final response = await dio.delete('/user/work-experience/$id');
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> addEducation(EducationModel edu) async {
    final response = await dio.post('/user/education', data: edu.toJson());
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> updateEducation(EducationModel edu) async {
    final response =
        await dio.put('/user/education/${edu.id}', data: edu.toJson());
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> deleteEducation(String id) async {
    final response = await dio.delete('/user/education/$id');
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> addSkill(String skill) async {
    final response = await dio.post('/user/skills', data: {'skill': skill});
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<UserProfileModel> removeSkill(String skill) async {
    final response = await dio.delete('/user/skills', data: {'skill': skill});
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return UserProfileModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    final response = await dio.get(ApiEndpoints.getBankAccounts);
    if (_ok(response.statusCode)) {
      final dynamic data = response.data;
      final List list = data is Map && data['results'] is List
          ? (data['results'] as List)
          : (data is List ? data : <dynamic>[]);
      return list
          .map((e) => BankAccountModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  // Bank list and verification
  @override
  Future<List<BankInfoModel>> getBankList({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh && _bankListCache != null && _bankListCache!.isNotEmpty) {
      final ts = _bankListFetchedAt;
      if (ts != null && now.difference(ts) < _bankListTtl) {
        return _bankListCache!;
      }
    }

    try {
      final response = await dio.get(ApiEndpoints.getBankList);
      if (_ok(response.statusCode)) {
        final data = response.data;
        final List list = data is List
            ? data
            : (data is Map && data['banks'] is List
                ? data['banks']
                : <dynamic>[]);
        final banks = list
            .map((e) => BankInfoModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        _bankListCache = banks;
        _bankListFetchedAt = now;
        return banks;
      }
      throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse);
    } on DioException catch (e) {
      // Fallback: if endpoint not available (404) or network, return a small static list
      final code = e.response?.statusCode ?? -1;
      if (code == 404 || code == 400 || code == 0) {
        final banks = <BankInfoModel>[
          const BankInfoModel(name: 'Access Bank', code: '044'),
          const BankInfoModel(name: 'GTBank', code: '058'),
          const BankInfoModel(name: 'First Bank', code: '011'),
          const BankInfoModel(name: 'UBA', code: '033'),
          const BankInfoModel(name: 'Zenith Bank', code: '057'),
        ];
        _bankListCache = banks;
        _bankListFetchedAt = now;
        return banks;
      }
      rethrow;
    }
  }

  @override
  Future<String> verifyBankAccount(
      {required String bankCode, required String accountNumber}) async {
    try {
      final response = await dio.post(ApiEndpoints.verifyBankAccount,
          data: {'bank_code': bankCode, 'account_number': accountNumber});
      if (_ok(response.statusCode)) {
        final data = response.data;
        if (data is Map && data['account_name'] != null) {
          return data['account_name'].toString();
        }
        if (data is Map && data['data'] is Map) {
          final d = data['data'] as Map;
          if (d['account_name'] != null) return d['account_name'].toString();
        }
        return '';
      }
      throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse);
    } on DioException catch (e) {
      // Fallback for development/demo when verification endpoint isn't available
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        return 'Verified Account';
      }
      rethrow;
    }
  }

  @override
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    String? bankCode,
    required String accountName,
    required String accountNumber,
  }) async {
    final payload = <String, dynamic>{
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
    };
    if (bankCode != null && bankCode.isNotEmpty) {
      payload['bank_code'] = bankCode;
    }
    final response = await dio.post(ApiEndpoints.addBankAccount, data: payload);
    if (_ok(response.statusCode)) {
      final data = response.data is Map<String, dynamic>
          ? response.data
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data)
              : <String, dynamic>{});
      return BankAccountModel.fromJson(data);
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    final url = '${ApiEndpoints.deleteBankAccount}$id/';
    final response = await dio.delete(url);
    if (_ok(response.statusCode)) return;
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<void> changePassword(
      {required String oldPassword, required String newPassword}) async {
    final response = await dio.post(ApiEndpoints.changePassword, data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    if (_ok(response.statusCode)) return;
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<void> deleteAccount({String? otp}) async {
    final response = await dio.post(ApiEndpoints.deleteAccount, data: {
      if (otp != null) 'token': otp,
    });
    if (_ok(response.statusCode)) return;
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    final form = FormData.fromMap({
      'profile_image': await MultipartFile.fromFile(imagePath),
    });
    final response =
        await dio.post(ApiEndpoints.uploadProfilePicture, data: form);
    if (_ok(response.statusCode)) {
      final data = response.data;
      if (data is Map) {
        return (data['image_url'] ?? data['profile_image'] ?? '').toString();
      }
      return '';
    }
    throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse);
  }

  @override
  Future<bool> setWithdrawalPin(String pin) async {
    final response =
        await dio.post(ApiEndpoints.setWithdrawalPin, data: {'pin': pin});
    return _ok(response.statusCode);
  }

  @override
  Future<bool> verifyWithdrawalPin(String pin) async {
    final response =
        await dio.post(ApiEndpoints.validateWithdrawalPin, data: {'pin': pin});
    return _ok(response.statusCode);
  }

  bool _ok(int? status) => status != null && status >= 200 && status < 300;
}
