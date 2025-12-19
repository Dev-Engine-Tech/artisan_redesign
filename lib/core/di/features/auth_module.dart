import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source_fake.dart';
import 'package:artisans_circle/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:artisans_circle/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:artisans_circle/features/auth/domain/repositories/auth_repository.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_in.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_up.dart';
import 'package:artisans_circle/features/auth/domain/usecases/is_signed_in.dart';
import 'package:artisans_circle/features/auth/domain/usecases/get_current_user.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_out.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:artisans_circle/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:artisans_circle/features/auth/presentation/bloc/signup_cubit.dart';
import 'package:artisans_circle/core/storage/secure_storage.dart';
import 'package:artisans_circle/core/services/login_state_service.dart';

/// Auth feature module
///
/// Registers authentication-related dependencies.
/// This module is loaded early during app startup since auth is needed
/// to determine initial navigation (splash -> login or home).
class AuthModule {
  static bool _initialized = false;

  /// Initialize auth dependencies
  static Future<void> init(GetIt getIt, {bool useFake = false}) async {
    if (_initialized) return;

    // Data sources
    if (useFake) {
      getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceFake(),
      );
    } else {
      getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
          getIt<Dio>(),
          getIt<SharedPreferences>(),
          getIt<SecureStorage>(),
        ),
      );
    }

    // Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remote: getIt<AuthRemoteDataSource>()),
    );

    // Use cases
    getIt.registerLazySingleton<SignIn>(
      () => SignIn(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignUp>(
      () => SignUp(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<IsSignedIn>(
      () => IsSignedIn(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<GetCurrentUser>(
      () => GetCurrentUser(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignOut>(
      () => SignOut(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignInWithGoogle>(
      () => SignInWithGoogle(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton<SignInWithApple>(
      () => SignInWithApple(getIt<AuthRepository>()),
    );

    // Services
    getIt.registerLazySingleton<LoginStateService>(
      () => LoginStateService.instance,
    );

    // BLoCs - registered as factories (new instance each time)
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        signIn: getIt<SignIn>(),
        signUp: getIt<SignUp>(),
        isSignedIn: getIt<IsSignedIn>(),
        getCurrentUser: getIt<GetCurrentUser>(),
        signOut: getIt<SignOut>(),
        signInWithGoogle: getIt<SignInWithGoogle>(),
        signInWithApple: getIt<SignInWithApple>(),
      ),
    );

    // SignUp Cubit (stepper wizard)
    if (useFake) {
      // For widget tests and development we register the cubit as a singleton
      getIt.registerLazySingleton<SignUpCubit>(
        () => SignUpCubit(signUpUsecase: getIt<SignUp>()),
      );
    } else {
      getIt.registerFactory<SignUpCubit>(
        () => SignUpCubit(signUpUsecase: getIt<SignUp>()),
      );
    }

    _initialized = true;
  }

  /// Reset initialization state (for testing)
  static void reset() {
    _initialized = false;
  }
}
