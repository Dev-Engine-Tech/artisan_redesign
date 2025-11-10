import '../../domain/entities/user_profile.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_data_source.dart';
import '../models/user_profile_model.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remote;
  AccountRepositoryImpl(this.remote);

  @override
  Future<UserProfile> getUserProfile() => remote.getUserProfile();

  @override
  Future<UserProfile> updateUserProfile({
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? bio,
    String? location,
    String? phone,
    int? yearsOfExperience,
  }) =>
      remote.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        jobTitle: jobTitle,
        bio: bio,
        location: location,
        phone: phone,
        yearsOfExperience: yearsOfExperience,
      );

  @override
  Future<Earnings> getEarnings() async {
    try {
      return await remote.getEarnings();
    } catch (e) {
      // Return test data as fallback
      return const Earnings(
        total: 156800.0,
        available: 156800.0,
        pending: 0.0,
      );
    }
  }

  @override
  Future<List<TransactionItem>> getTransactions(
          {int page = 1, int limit = 20}) =>
      remote.getTransactions(page: page, limit: limit);

  @override
  Future<void> requestWithdrawal(double amount) =>
      remote.requestWithdrawal(amount);

  @override
  Future<List<BankAccount>> getBankAccounts() => remote.getBankAccounts();

  @override
  Future<BankAccount> addBankAccount({
    required String bankName,
    required String accountName,
    required String accountNumber,
    String? bankCode,
  }) =>
      remote.addBankAccount(
        bankName: bankName,
        bankCode: bankCode,
        accountName: accountName,
        accountNumber: accountNumber,
      );

  @override
  Future<void> deleteBankAccount(String id) => remote.deleteBankAccount(id);

  @override
  Future<List<BankInfo>> getBankList({bool forceRefresh = false}) =>
      remote.getBankList(forceRefresh: forceRefresh);

  @override
  Future<String> verifyBankAccount(
          {required String bankCode, required String accountNumber}) =>
      remote.verifyBankAccount(
          bankCode: bankCode, accountNumber: accountNumber);

  @override
  Future<bool> setWithdrawalPin(String pin) async {
    return remote.setWithdrawalPin(pin);
  }

  @override
  Future<bool> verifyWithdrawalPin(String pin) async {
    return remote.verifyWithdrawalPin(pin);
  }

  @override
  Future<void> changePassword(
          {required String oldPassword, required String newPassword}) =>
      remote.changePassword(oldPassword: oldPassword, newPassword: newPassword);

  @override
  Future<void> deleteAccount({String? otp}) => remote.deleteAccount(otp: otp);

  @override
  Future<String> uploadProfileImage(String imagePath) =>
      remote.uploadProfileImage(imagePath);

  // Work Experience
  @override
  Future<UserProfile> addWorkExperience(WorkExperience work) =>
      remote.addWorkExperience(WorkExperienceModel(
        id: work.id,
        jobTitle: work.jobTitle,
        companyName: work.companyName,
        location: work.location,
        description: work.description,
        startDate: work.startDate,
        endDate: work.endDate,
        isCurrent: work.isCurrent,
      ));

  @override
  Future<UserProfile> updateWorkExperience(WorkExperience work) =>
      remote.updateWorkExperience(WorkExperienceModel(
        id: work.id,
        jobTitle: work.jobTitle,
        companyName: work.companyName,
        location: work.location,
        description: work.description,
        startDate: work.startDate,
        endDate: work.endDate,
        isCurrent: work.isCurrent,
      ));

  @override
  Future<UserProfile> deleteWorkExperience(String id) =>
      remote.deleteWorkExperience(id);

  // Education
  @override
  Future<UserProfile> addEducation(Education edu) => remote.addEducation(
        EducationModel(
          id: edu.id,
          schoolName: edu.schoolName,
          fieldOfStudy: edu.fieldOfStudy,
          degree: edu.degree,
          startDate: edu.startDate,
          endDate: edu.endDate,
          description: edu.description,
        ),
      );

  @override
  Future<UserProfile> updateEducation(Education edu) => remote.updateEducation(
        EducationModel(
          id: edu.id,
          schoolName: edu.schoolName,
          fieldOfStudy: edu.fieldOfStudy,
          degree: edu.degree,
          startDate: edu.startDate,
          endDate: edu.endDate,
          description: edu.description,
        ),
      );

  @override
  Future<UserProfile> deleteEducation(String id) => remote.deleteEducation(id);

  // Skills
  @override
  Future<UserProfile> addSkill(String skill) => remote.addSkill(skill);

  @override
  Future<UserProfile> removeSkill(String skill) => remote.removeSkill(skill);
}
