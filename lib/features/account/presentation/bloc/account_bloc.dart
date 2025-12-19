import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:artisans_circle/core/bloc/cached_bloc_mixin.dart';
import 'account_event.dart';
import 'account_state.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../data/models/user_profile_model.dart' show UserProfileModel;
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/get_earnings.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/request_withdrawal.dart';
import '../../domain/usecases/get_bank_accounts.dart';
import '../../domain/usecases/add_bank_account.dart';
import '../../domain/usecases/delete_bank_account.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/add_skill.dart';
import '../../domain/usecases/remove_skill.dart';
import '../../domain/usecases/add_work_experience.dart';
import '../../domain/usecases/update_work_experience.dart';
import '../../domain/usecases/delete_work_experience.dart';
import '../../domain/usecases/add_education.dart';
import '../../domain/usecases/update_education.dart';
import '../../domain/usecases/delete_education.dart';
import '../../domain/usecases/upload_profile_image.dart';
import '../../domain/entities/user_profile.dart' as ent;
import '../../domain/usecases/get_bank_list.dart';
import '../../domain/usecases/verify_bank_account.dart';
import '../../domain/usecases/set_withdrawal_pin.dart';
import '../../domain/usecases/verify_withdrawal_pin.dart';

// ✅ WEEK 4: Added CachedBlocMixin for automatic caching
class AccountBloc extends Bloc<AccountEvent, AccountState>
    with CachedBlocMixin {
  final GetUserProfile getUserProfile;
  final UpdateUserProfile updateUserProfile;
  final GetEarnings getEarnings;
  final GetTransactions getTransactions;
  final RequestWithdrawal requestWithdrawal;
  final GetBankAccounts getBankAccounts;
  final AddBankAccount addBankAccount;
  final DeleteBankAccount deleteBankAccount;
  final GetBankList getBankList;
  final VerifyBankAccount verifyBankAccount;
  final SetWithdrawalPin setWithdrawalPin;
  final VerifyWithdrawalPin verifyWithdrawalPin;
  final ChangePassword changePassword;
  final DeleteAccount deleteAccount;
  final AddSkill addSkill;
  final RemoveSkill removeSkill;
  final AddWorkExperience addWork;
  final UpdateWorkExperience updateWork;
  final DeleteWorkExperience deleteWork;
  final AddEducation addEducation;
  final UpdateEducation updateEducation;
  final DeleteEducation deleteEducation;
  final UploadProfileImage uploadProfileImage;

  AccountBloc({
    required this.getUserProfile,
    required this.updateUserProfile,
    required this.getEarnings,
    required this.getTransactions,
    required this.requestWithdrawal,
    required this.getBankAccounts,
    required this.addBankAccount,
    required this.deleteBankAccount,
    required this.getBankList,
    required this.verifyBankAccount,
    required this.setWithdrawalPin,
    required this.verifyWithdrawalPin,
    required this.changePassword,
    required this.deleteAccount,
    required this.addSkill,
    required this.removeSkill,
    required this.addWork,
    required this.updateWork,
    required this.deleteWork,
    required this.addEducation,
    required this.updateEducation,
    required this.deleteEducation,
    required this.uploadProfileImage,
  }) : super(AccountInitial()) {
    debugPrint('✅ AccountBloc initialized');
    on<AccountLoadProfile>(_onLoadProfile);
    on<AccountUpdateProfile>(_onUpdateProfile);
    on<AccountLoadEarnings>(_onLoadEarnings);
    on<AccountLoadTransactions>(_onLoadTransactions);
    on<AccountRequestWithdrawal>(_onRequestWithdrawal);
    on<AccountLoadBankAccounts>(_onLoadBankAccounts);
    on<AccountAddBankAccount>(_onAddBankAccount);
    on<AccountDeleteBankAccount>(_onDeleteBankAccount);
    on<AccountChangePassword>(_onChangePassword);
    on<AccountDeleteAccount>(_onDeleteAccount);
    // profile details
    on<AccountAddSkill>(_onAddSkill);
    on<AccountRemoveSkill>(_onRemoveSkill);
    on<AccountAddWorkExperience>(_onAddWork);
    on<AccountUpdateWorkExperience>(_onUpdateWork);
    on<AccountDeleteWorkExperience>(_onDeleteWork);
    on<AccountAddEducation>(_onAddEducation);
    on<AccountUpdateEducation>(_onUpdateEducation);
    on<AccountDeleteEducation>(_onDeleteEducation);
    on<AccountUploadProfileImage>(_onUploadProfileImage);
    on<AccountLoadBankList>(_onLoadBankList);
    on<AccountVerifyBank>(_onVerifyBank);
    on<AccountSetWithdrawalPin>(_onSetWithdrawalPin);
    on<AccountVerifyWithdrawalPin>(_onVerifyWithdrawalPin);
  }

  Future<void> _onLoadProfile(
      AccountLoadProfile event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      // ✅ WEEK 4: Added caching with 10 minute TTL for profile data
      final profile = await executeWithCache(
        cacheKey: 'user_profile',
        fetch: () => getUserProfile.call(),
        fromJson: (json) =>
            UserProfileModel.fromJson(json as Map<String, dynamic>),
        toJson: (profile) => (profile as UserProfileModel).toJson(),
        ttl: const Duration(minutes: 10),
        persistent: true, // Keep profile in persistent storage
      );
      emit(AccountProfileLoaded(profile));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLoadBankList(
      AccountLoadBankList event, Emitter<AccountState> emit) async {
    emit(const AccountBankListLoading());
    try {
      final banks = await getBankList.call(forceRefresh: event.forceRefresh);
      emit(AccountBankListLoaded(banks));
    } catch (e) {
      emit(AccountBankListError(e.toString()));
    }
  }

  Future<void> _onVerifyBank(
      AccountVerifyBank event, Emitter<AccountState> emit) async {
    emit(const AccountBankVerifyLoading());
    try {
      final name = await verifyBankAccount.call(
          bankCode: event.bankCode, accountNumber: event.accountNumber);
      emit(AccountBankVerified(name));
    } catch (e) {
      emit(AccountBankVerifyError(e.toString()));
    }
  }

  Future<void> _onSetWithdrawalPin(
      AccountSetWithdrawalPin event, Emitter<AccountState> emit) async {
    try {
      final ok = await setWithdrawalPin.call(event.pin);
      if (ok) {
        emit(const AccountWithdrawalPinSet());
      } else {
        emit(const AccountError('Failed to set PIN'));
      }
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onVerifyWithdrawalPin(
      AccountVerifyWithdrawalPin event, Emitter<AccountState> emit) async {
    try {
      final ok = await verifyWithdrawalPin.call(event.pin);
      if (ok) {
        emit(const AccountWithdrawalPinVerified());
      } else {
        emit(const AccountError('Invalid PIN'));
      }
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onUploadProfileImage(
      AccountUploadProfileImage event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      await uploadProfileImage.call(event.imagePath);
      final profile = await getUserProfile.call();
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Profile photo updated'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddSkill(
      AccountAddSkill event, Emitter<AccountState> emit) async {
    try {
      final profile = await addSkill.call(event.skill);
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Skill added'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onRemoveSkill(
      AccountRemoveSkill event, Emitter<AccountState> emit) async {
    try {
      final profile = await removeSkill.call(event.skill);
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Skill removed'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddWork(
      AccountAddWorkExperience event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final profile = await addWork.call(ent.WorkExperience(
        id: '',
        jobTitle: event.jobTitle,
        companyName: event.companyName,
        location: event.location,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        isCurrent: event.isCurrent,
      ));
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Work experience added'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onUpdateWork(
      AccountUpdateWorkExperience event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final profile = await updateWork.call(ent.WorkExperience(
        id: event.id,
        jobTitle: event.jobTitle,
        companyName: event.companyName,
        location: event.location,
        description: event.description,
        startDate: event.startDate,
        endDate: event.endDate,
        isCurrent: event.isCurrent,
      ));
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Work experience updated'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onDeleteWork(
      AccountDeleteWorkExperience event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final profile = await deleteWork.call(event.id);
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Work experience deleted'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddEducation(
      AccountAddEducation event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final profile = await addEducation.call(ent.Education(
        id: '',
        schoolName: event.schoolName,
        fieldOfStudy: event.fieldOfStudy,
        degree: event.degree,
        startDate: event.startDate,
        endDate: event.endDate,
        description: event.description,
      ));
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Education added'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onUpdateEducation(
      AccountUpdateEducation event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final profile = await updateEducation.call(ent.Education(
        id: event.id,
        schoolName: event.schoolName,
        fieldOfStudy: event.fieldOfStudy,
        degree: event.degree,
        startDate: event.startDate,
        endDate: event.endDate,
        description: event.description,
      ));
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Education updated'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onDeleteEducation(
      AccountDeleteEducation event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final profile = await deleteEducation.call(event.id);
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Education deleted'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
      AccountUpdateProfile event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final profile = await updateUserProfile.call(
        firstName: event.firstName,
        lastName: event.lastName,
        jobTitle: event.jobTitle,
        bio: event.bio,
        location: event.location,
        phone: event.phone,
        yearsOfExperience: event.yearsOfExperience,
      );
      emit(AccountProfileLoaded(profile));
      emit(const AccountActionSuccess('Profile updated'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLoadEarnings(
      AccountLoadEarnings event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final earnings = await getEarnings.call();
      emit(AccountEarningsLoaded(earnings));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLoadTransactions(
      AccountLoadTransactions event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final list =
          await getTransactions.call(page: event.page, limit: event.limit);
      final hasMore = list.length >= event.limit;
      emit(AccountTransactionsLoaded(list, hasMore: hasMore));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onRequestWithdrawal(
      AccountRequestWithdrawal event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      await requestWithdrawal.call(event.amount);
      emit(const AccountActionSuccess('Withdrawal requested'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLoadBankAccounts(
      AccountLoadBankAccounts event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      final accounts = await getBankAccounts.call();
      emit(AccountBankAccountsLoaded(accounts));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddBankAccount(
      AccountAddBankAccount event, Emitter<AccountState> emit) async {
    emit(const AccountBankMutationLoading());
    try {
      await addBankAccount.call(
        bankName: event.bankName,
        bankCode: event.bankCode,
        accountName: event.accountName,
        accountNumber: event.accountNumber,
      );
      final accounts = await getBankAccounts.call();
      emit(AccountBankAccountsLoaded(accounts));
      emit(const AccountActionSuccess('Bank account added'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onDeleteBankAccount(
      AccountDeleteBankAccount event, Emitter<AccountState> emit) async {
    emit(const AccountBankMutationLoading());
    try {
      await deleteBankAccount.call(event.id);
      final accounts = await getBankAccounts.call();
      emit(AccountBankAccountsLoaded(accounts));
      emit(const AccountActionSuccess('Bank account deleted'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
      AccountChangePassword event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      await changePassword.call(
          oldPassword: event.oldPassword, newPassword: event.newPassword);
      emit(const AccountActionSuccess('Password changed'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
      AccountDeleteAccount event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      await deleteAccount.call(otp: event.otp);
      emit(const AccountActionSuccess('Account deleted'));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }
}
