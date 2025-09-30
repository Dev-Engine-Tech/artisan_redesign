import 'dart:convert';
import 'package:artisans_circle/core/network/api_client.dart';
import 'package:artisans_circle/core/network/api_endpoints.dart';
import 'package:artisans_circle/features/account/data/models/earnings_model.dart';
import 'package:artisans_circle/features/account/data/models/user_profile_model.dart';
import 'package:artisans_circle/features/account/data/models/bank_account_model.dart';
import 'package:artisans_circle/features/account/domain/entities/bank_list.dart';

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
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
  });
  Future<bool> requestWithdrawal(double amount);
  Future<List<BankAccountModel>> getBankAccounts();
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    required String bankCode,
    required String accountName,
    required String accountNumber,
  });
  Future<bool> deleteBankAccount(String id);
  Future<List<BankListItem>> getBankList();
  Future<String> verifyBankAccount({
    required String bankCode,
    required String accountNumber,
  });
  Future<bool> setWithdrawalPin(String pin);
  Future<bool> verifyWithdrawalPin(String pin);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient apiClient;

  AccountRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserProfileModel> getUserProfile() async {
    final response = await apiClient.get(ApiEndpoints.profile);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfileModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
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
    final requestBody = <String, dynamic>{};

    if (firstName != null) requestBody['first_name'] = firstName;
    if (lastName != null) requestBody['last_name'] = lastName;
    if (jobTitle != null) requestBody['job_title'] = jobTitle;
    if (bio != null) requestBody['bio'] = bio;
    if (location != null) requestBody['location'] = location;
    if (phone != null) requestBody['phone'] = phone;
    if (yearsOfExperience != null)
      requestBody['years_of_experience'] = yearsOfExperience;

    final response = await apiClient.put(
      ApiEndpoints.profile,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfileModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  @override
  Future<EarningsModel> getEarnings() async {
    final response = await apiClient.get(ApiEndpoints.earnings);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return EarningsModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load earnings: ${response.statusCode}');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    final response = await apiClient.get(
      ApiEndpoints.transactionHistory,
      queryParams: queryParams,
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> transactionsJson =
          jsonData['results'] ?? jsonData['data'] ?? [];

      return transactionsJson
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }

  @override
  Future<bool> requestWithdrawal(double amount) async {
    final requestBody = {
      'amount': amount,
    };

    final response = await apiClient.post(
      ApiEndpoints.withdrawal,
      body: requestBody,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<List<BankAccountModel>> getBankAccounts() async {
    final response = await apiClient.get(ApiEndpoints.addBank);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> accountsJson =
          jsonData['results'] ?? jsonData['data'] ?? [];

      return accountsJson
          .map((json) => BankAccountModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load bank accounts: ${response.statusCode}');
    }
  }

  @override
  Future<BankAccountModel> addBankAccount({
    required String bankName,
    required String bankCode,
    required String accountName,
    required String accountNumber,
  }) async {
    final requestBody = {
      'bank_name': bankName,
      'bank_code': bankCode,
      'account_name': accountName,
      'account_number': accountNumber,
    };

    final response = await apiClient.post(
      ApiEndpoints.addBank,
      body: requestBody,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return BankAccountModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to add bank account: ${response.statusCode}');
    }
  }

  @override
  Future<bool> deleteBankAccount(String id) async {
    final response = await apiClient.delete('${ApiEndpoints.addBank}$id/');

    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<List<BankListItem>> getBankList() async {
    // This would typically be a separate endpoint for Nigerian banks
    // For now, returning a mock list
    return [
      const BankListItem(name: 'Access Bank', code: '044'),
      const BankListItem(name: 'GTBank', code: '058'),
      const BankListItem(name: 'First Bank', code: '011'),
      const BankListItem(name: 'UBA', code: '033'),
      const BankListItem(name: 'Zenith Bank', code: '057'),
    ];
  }

  @override
  Future<String> verifyBankAccount({
    required String bankCode,
    required String accountNumber,
  }) async {
    // This would typically call a bank verification service
    // For now, returning a mock account name
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return 'John Doe'; // Mock account name
  }

  @override
  Future<bool> setWithdrawalPin(String pin) async {
    final requestBody = {
      'pin': pin,
    };

    final response = await apiClient.post(
      ApiEndpoints.withdrawalPin,
      body: requestBody,
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> verifyWithdrawalPin(String pin) async {
    final requestBody = {
      'pin': pin,
    };

    final response = await apiClient.post(
      ApiEndpoints.verifyWithdrawalPin,
      body: requestBody,
    );

    return response.statusCode == 200;
  }
}
