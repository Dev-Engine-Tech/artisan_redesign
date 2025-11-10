import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/data/base_remote_data_source.dart';
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
    required String accountName,
    required String accountNumber,
    String? bankCode,
  });
  Future<void> deleteBankAccount(String id);

  Future<void> changePassword(
      {required String oldPassword, required String newPassword});
  Future<void> deleteAccount({String? otp});

  Future<String> uploadProfileImage(String imagePath);
  Future<bool> setWithdrawalPin(String pin);
  Future<bool> verifyWithdrawalPin(String pin);
}

class AccountRemoteDataSourceImpl extends BaseRemoteDataSource
    implements AccountRemoteDataSource {
  AccountRemoteDataSourceImpl(super.dio);

  // Simple in-memory cache for bank list to reduce network calls.
  List<BankInfoModel>? _bankListCache;
  DateTime? _bankListFetchedAt;
  static const Duration _bankListTtl = Duration(hours: 12);

  @override
  Future<UserProfileModel> getUserProfile() => get(
        ApiEndpoints.userProfile,
        fromJson: UserProfileModel.fromJson,
      );

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

    return put(
      ApiEndpoints.updateProfile,
      fromJson: UserProfileModel.fromJson,
      data: payload,
    );
  }

  @override
  Future<EarningsModel> getEarnings() => get(
        ApiEndpoints.userEarnings,
        fromJson: EarningsModel.fromJson,
      );

  @override
  Future<List<TransactionModel>> getTransactions(
          {int page = 1, int limit = 20}) =>
      getList(
        ApiEndpoints.transactionHistory,
        fromJson: TransactionModel.fromJson,
        queryParams: {'page': page, 'limit': limit},
      );

  @override
  Future<void> requestWithdrawal(double amount) => postVoid(
        ApiEndpoints.withdrawEarnings,
        data: {'amount': amount},
      );

  @override
  Future<UserProfileModel> addWorkExperience(WorkExperienceModel work) => post(
        '/user/work-experience',
        fromJson: UserProfileModel.fromJson,
        data: work.toJson(),
      );

  @override
  Future<UserProfileModel> updateWorkExperience(WorkExperienceModel work) =>
      put(
        '/user/work-experience/${work.id}',
        fromJson: UserProfileModel.fromJson,
        data: work.toJson(),
      );

  @override
  Future<UserProfileModel> deleteWorkExperience(String id) => delete(
        '/user/work-experience/$id',
        fromJson: UserProfileModel.fromJson,
      );

  @override
  Future<UserProfileModel> addEducation(EducationModel edu) => post(
        '/user/education',
        fromJson: UserProfileModel.fromJson,
        data: edu.toJson(),
      );

  @override
  Future<UserProfileModel> updateEducation(EducationModel edu) => put(
        '/user/education/${edu.id}',
        fromJson: UserProfileModel.fromJson,
        data: edu.toJson(),
      );

  @override
  Future<UserProfileModel> deleteEducation(String id) => delete(
        '/user/education/$id',
        fromJson: UserProfileModel.fromJson,
      );

  @override
  Future<UserProfileModel> addSkill(String skill) => post(
        '/user/skills',
        fromJson: UserProfileModel.fromJson,
        data: {'skill': skill},
      );

  @override
  Future<UserProfileModel> removeSkill(String skill) => delete(
        '/user/skills',
        fromJson: UserProfileModel.fromJson,
        data: {'skill': skill},
      );

  @override
  Future<List<BankAccountModel>> getBankAccounts() => getList(
        ApiEndpoints.getBankAccounts,
        fromJson: BankAccountModel.fromJson,
      );

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
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
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
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
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
    required String accountName,
    required String accountNumber,
    String? bankCode,
  }) async {
    final payload = <String, dynamic>{
      'bank_name': bankName,
      'account_name': accountName,
      'account_number': accountNumber,
    };
    if (bankCode != null && bankCode.isNotEmpty) {
      payload['bank_code'] = bankCode;
    }
    return post(
      ApiEndpoints.addBankAccount,
      fromJson: BankAccountModel.fromJson,
      data: payload,
    );
  }

  @override
  Future<void> deleteBankAccount(String id) => deleteVoid(
        '${ApiEndpoints.deleteBankAccount}$id/',
      );

  @override
  Future<void> changePassword(
          {required String oldPassword, required String newPassword}) =>
      postVoid(
        ApiEndpoints.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

  @override
  Future<void> deleteAccount({String? otp}) => postVoid(
        ApiEndpoints.deleteAccount,
        data: {
          if (otp != null) 'token': otp,
        },
      );

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    final form = FormData.fromMap({
      'profile_image': await MultipartFile.fromFile(imagePath),
    });
    final response =
        await dio.post(ApiEndpoints.uploadProfilePicture, data: form);
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
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
    try {
      await postVoid(ApiEndpoints.setWithdrawalPin, data: {'pin': pin});
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> verifyWithdrawalPin(String pin) async {
    try {
      await postVoid(ApiEndpoints.validateWithdrawalPin, data: {'pin': pin});
      return true;
    } catch (_) {
      return false;
    }
  }
}
