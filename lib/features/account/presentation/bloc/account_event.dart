import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();
  @override
  List<Object?> get props => [];
}

class AccountLoadProfile extends AccountEvent {}

class AccountUpdateProfile extends AccountEvent {
  final String? firstName;
  final String? lastName;
  final String? jobTitle;
  final String? bio;
  final String? location;
  final String? phone;
  final int? yearsOfExperience;
  const AccountUpdateProfile({
    this.firstName,
    this.lastName,
    this.jobTitle,
    this.bio,
    this.location,
    this.phone,
    this.yearsOfExperience,
  });
}

class AccountLoadEarnings extends AccountEvent {}

class AccountLoadTransactions extends AccountEvent {
  final int page;
  final int limit;
  const AccountLoadTransactions({this.page = 1, this.limit = 20});
}

class AccountRequestWithdrawal extends AccountEvent {
  final double amount;
  const AccountRequestWithdrawal(this.amount);
}

class AccountLoadBankAccounts extends AccountEvent {}

class AccountAddBankAccount extends AccountEvent {
  final String bankName;
  final String? bankCode;
  final String accountName;
  final String accountNumber;
  const AccountAddBankAccount({
    required this.bankName,
    this.bankCode,
    required this.accountName,
    required this.accountNumber,
  });
}

class AccountLoadBankList extends AccountEvent {
  final bool forceRefresh;
  const AccountLoadBankList({this.forceRefresh = false});
  @override
  List<Object?> get props => [forceRefresh];
}

class AccountVerifyBank extends AccountEvent {
  final String bankCode;
  final String accountNumber;
  const AccountVerifyBank({required this.bankCode, required this.accountNumber});
}

class AccountSetWithdrawalPin extends AccountEvent {
  final String pin;
  const AccountSetWithdrawalPin(this.pin);
}

class AccountVerifyWithdrawalPin extends AccountEvent {
  final String pin;
  const AccountVerifyWithdrawalPin(this.pin);
}

class AccountDeleteBankAccount extends AccountEvent {
  final String id;
  const AccountDeleteBankAccount(this.id);
}

class AccountChangePassword extends AccountEvent {
  final String oldPassword;
  final String newPassword;
  const AccountChangePassword({required this.oldPassword, required this.newPassword});
}

class AccountDeleteAccount extends AccountEvent {
  final String? otp;
  const AccountDeleteAccount({this.otp});
}

// Profile Details Management
class AccountAddSkill extends AccountEvent {
  final String skill;
  const AccountAddSkill(this.skill);
}

class AccountRemoveSkill extends AccountEvent {
  final String skill;
  const AccountRemoveSkill(this.skill);
}

class AccountAddWorkExperience extends AccountEvent {
  final String jobTitle;
  final String companyName;
  final String? location;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  const AccountAddWorkExperience({
    required this.jobTitle,
    required this.companyName,
    this.location,
    this.description,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
  });
}

class AccountUpdateWorkExperience extends AccountEvent {
  final String id;
  final String jobTitle;
  final String companyName;
  final String? location;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isCurrent;
  const AccountUpdateWorkExperience({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    this.location,
    this.description,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
  });
}

class AccountDeleteWorkExperience extends AccountEvent {
  final String id;
  const AccountDeleteWorkExperience(this.id);
}

class AccountAddEducation extends AccountEvent {
  final String schoolName;
  final String fieldOfStudy;
  final String? degree;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  const AccountAddEducation({
    required this.schoolName,
    required this.fieldOfStudy,
    this.degree,
    required this.startDate,
    this.endDate,
    this.description,
  });
}

class AccountUpdateEducation extends AccountEvent {
  final String id;
  final String schoolName;
  final String fieldOfStudy;
  final String? degree;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  const AccountUpdateEducation({
    required this.id,
    required this.schoolName,
    required this.fieldOfStudy,
    this.degree,
    required this.startDate,
    this.endDate,
    this.description,
  });
}

class AccountDeleteEducation extends AccountEvent {
  final String id;
  const AccountDeleteEducation(this.id);
}

class AccountUploadProfileImage extends AccountEvent {
  final String imagePath;
  const AccountUploadProfileImage(this.imagePath);
}
