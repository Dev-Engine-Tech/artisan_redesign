import '../entities/user_profile.dart';
import '../entities/earnings.dart';
import '../entities/bank_account.dart';

abstract class AccountRepository {
  Future<UserProfile> getUserProfile();
  Future<UserProfile> updateUserProfile({
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? bio,
    String? location,
    String? phone,
    int? yearsOfExperience,
  });

  Future<Earnings> getEarnings();
  Future<List<TransactionItem>> getTransactions({int page = 1, int limit = 20});
  Future<void> requestWithdrawal(double amount);

  // Work Experience
  Future<UserProfile> addWorkExperience(WorkExperience work);
  Future<UserProfile> updateWorkExperience(WorkExperience work);
  Future<UserProfile> deleteWorkExperience(String id);

  // Education
  Future<UserProfile> addEducation(Education edu);
  Future<UserProfile> updateEducation(Education edu);
  Future<UserProfile> deleteEducation(String id);

  // Skills
  Future<UserProfile> addSkill(String skill);
  Future<UserProfile> removeSkill(String skill);

  Future<List<BankAccount>> getBankAccounts();
  Future<BankAccount> addBankAccount({
    required String bankName,
    String? bankCode,
    required String accountName,
    required String accountNumber,
  });
  Future<void> deleteBankAccount(String id);

  // Bank list + verification
  Future<List<BankInfo>> getBankList({bool forceRefresh = false});
  Future<String> verifyBankAccount({required String bankCode, required String accountNumber});

  // Withdrawal PIN
  Future<bool> setWithdrawalPin(String pin);
  Future<bool> verifyWithdrawalPin(String pin);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<void> deleteAccount({String? otp});

  Future<String> uploadProfileImage(String imagePath);
}
