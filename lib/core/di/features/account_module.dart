import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:artisans_circle/features/account/data/datasources/account_remote_data_source.dart';
import 'package:artisans_circle/features/account/data/datasources/business_settings_remote_data_source.dart';
import 'package:artisans_circle/features/account/data/repositories/account_repository_impl.dart';
import 'package:artisans_circle/features/account/data/repositories/business_settings_repository_impl.dart';
import 'package:artisans_circle/features/account/domain/repositories/account_repository.dart';
import 'package:artisans_circle/features/account/domain/repositories/business_settings_repository.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_user_profile.dart';
import 'package:artisans_circle/features/account/domain/usecases/update_user_profile.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_earnings.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_transactions.dart';
import 'package:artisans_circle/features/account/domain/usecases/request_withdrawal.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_bank_accounts.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_bank_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_bank_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/change_password.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/upload_profile_image.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_skill.dart';
import 'package:artisans_circle/features/account/domain/usecases/remove_skill.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_work_experience.dart';
import 'package:artisans_circle/features/account/domain/usecases/update_work_experience.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_work_experience.dart';
import 'package:artisans_circle/features/account/domain/usecases/add_education.dart';
import 'package:artisans_circle/features/account/domain/usecases/update_education.dart';
import 'package:artisans_circle/features/account/domain/usecases/delete_education.dart';
import 'package:artisans_circle/features/account/domain/usecases/get_bank_list.dart';
import 'package:artisans_circle/features/account/domain/usecases/verify_bank_account.dart';
import 'package:artisans_circle/features/account/domain/usecases/set_withdrawal_pin.dart';
import 'package:artisans_circle/features/account/domain/usecases/verify_withdrawal_pin.dart';
import 'package:artisans_circle/features/account/presentation/bloc/account_bloc.dart';

/// Account feature module
///
/// Registers account and business settings related dependencies including
/// data sources, repositories, use cases, and the AccountBloc.
class AccountModule {
  static bool _initialized = false;

  /// Initialize account dependencies
  static Future<void> init(GetIt getIt, {bool useFake = false}) async {
    if (_initialized) return;

    // Data sources
    getIt.registerLazySingleton<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(getIt<Dio>()),
    );

    getIt.registerLazySingleton<BusinessSettingsRemoteDataSource>(
      () => BusinessSettingsRemoteDataSourceImpl(getIt<Dio>()),
    );

    // Repositories
    getIt.registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(getIt<AccountRemoteDataSource>()),
    );

    getIt.registerLazySingleton<BusinessSettingsRepository>(
      () => BusinessSettingsRepositoryImpl(
          getIt<BusinessSettingsRemoteDataSource>()),
    );

    // Use cases - Profile
    getIt.registerLazySingleton<GetUserProfile>(
      () => GetUserProfile(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<UpdateUserProfile>(
      () => UpdateUserProfile(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<UploadProfileImage>(
      () => UploadProfileImage(getIt<AccountRepository>()),
    );

    // Use cases - Earnings & Transactions
    getIt.registerLazySingleton<GetEarnings>(
      () => GetEarnings(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<GetTransactions>(
      () => GetTransactions(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<RequestWithdrawal>(
      () => RequestWithdrawal(getIt<AccountRepository>()),
    );

    // Use cases - Bank Accounts
    getIt.registerLazySingleton<GetBankAccounts>(
      () => GetBankAccounts(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<AddBankAccount>(
      () => AddBankAccount(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<DeleteBankAccount>(
      () => DeleteBankAccount(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<GetBankList>(
      () => GetBankList(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<VerifyBankAccount>(
      () => VerifyBankAccount(getIt<AccountRepository>()),
    );

    // Use cases - Withdrawal PIN
    getIt.registerLazySingleton<SetWithdrawalPin>(
      () => SetWithdrawalPin(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<VerifyWithdrawalPin>(
      () => VerifyWithdrawalPin(getIt<AccountRepository>()),
    );

    // Use cases - Security
    getIt.registerLazySingleton<ChangePassword>(
      () => ChangePassword(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<DeleteAccount>(
      () => DeleteAccount(getIt<AccountRepository>()),
    );

    // Use cases - Skills
    getIt.registerLazySingleton<AddSkill>(
      () => AddSkill(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<RemoveSkill>(
      () => RemoveSkill(getIt<AccountRepository>()),
    );

    // Use cases - Work Experience
    getIt.registerLazySingleton<AddWorkExperience>(
      () => AddWorkExperience(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<UpdateWorkExperience>(
      () => UpdateWorkExperience(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<DeleteWorkExperience>(
      () => DeleteWorkExperience(getIt<AccountRepository>()),
    );

    // Use cases - Education
    getIt.registerLazySingleton<AddEducation>(
      () => AddEducation(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<UpdateEducation>(
      () => UpdateEducation(getIt<AccountRepository>()),
    );

    getIt.registerLazySingleton<DeleteEducation>(
      () => DeleteEducation(getIt<AccountRepository>()),
    );

    // BLoC - registered as factory (new instance each time)
    getIt.registerFactory<AccountBloc>(
      () => AccountBloc(
        getUserProfile: getIt<GetUserProfile>(),
        updateUserProfile: getIt<UpdateUserProfile>(),
        getEarnings: getIt<GetEarnings>(),
        getTransactions: getIt<GetTransactions>(),
        requestWithdrawal: getIt<RequestWithdrawal>(),
        getBankAccounts: getIt<GetBankAccounts>(),
        addBankAccount: getIt<AddBankAccount>(),
        deleteBankAccount: getIt<DeleteBankAccount>(),
        getBankList: getIt<GetBankList>(),
        verifyBankAccount: getIt<VerifyBankAccount>(),
        setWithdrawalPin: getIt<SetWithdrawalPin>(),
        verifyWithdrawalPin: getIt<VerifyWithdrawalPin>(),
        changePassword: getIt<ChangePassword>(),
        deleteAccount: getIt<DeleteAccount>(),
        addSkill: getIt<AddSkill>(),
        removeSkill: getIt<RemoveSkill>(),
        addWork: getIt<AddWorkExperience>(),
        updateWork: getIt<UpdateWorkExperience>(),
        deleteWork: getIt<DeleteWorkExperience>(),
        addEducation: getIt<AddEducation>(),
        updateEducation: getIt<UpdateEducation>(),
        deleteEducation: getIt<DeleteEducation>(),
        uploadProfileImage: getIt<UploadProfileImage>(),
      ),
    );

    _initialized = true;
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _initialized = false;
  }
}
