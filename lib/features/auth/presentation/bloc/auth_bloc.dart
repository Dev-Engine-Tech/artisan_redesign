import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/is_signed_in.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_apple.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/core/services/login_state_service.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final IsSignedIn isSignedIn;
  final GetCurrentUser getCurrentUser;
  final SignOut signOut;
  final SignInWithGoogle signInWithGoogle;
  final SignInWithApple signInWithApple;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.isSignedIn,
    required this.getCurrentUser,
    required this.signOut,
    required this.signInWithGoogle,
    required this.signInWithApple,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignInWithAppleRequested>(_onSignInWithAppleRequested);
    on<AuthSignedOut>(_onSignedOut);
    on<AuthMarkVerified>(_onMarkVerified);
    on<AuthOtpVerificationRequested>(_onOtpVerificationRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final signedIn = await isSignedIn.call();

      if (!signedIn) {
        emit(const AuthUnauthenticated());
        return;
      }

      final user = await getCurrentUser.call();

      if (user != null) {
        // This is an automatic login from saved credentials
        debugPrint('🔄 AuthBloc: Recording automatic login from saved credentials');
        final loginStateService = getIt<LoginStateService>();
        await loginStateService.recordAutomaticLogin();
        debugPrint('✅ AuthBloc: Emitting AuthAuthenticated with isFreshLogin: false');
        emit(AuthAuthenticated(user: user, isFreshLogin: false));
      } else {
        // If remote says signed in but no local user, mark unauthenticated
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignInRequested(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await signIn.call(
          identifier: event.identifier, password: event.password);

      if (user != null) {
        // This is a fresh manual login
        debugPrint('🔑 AuthBloc: Recording manual login');
        final loginStateService = getIt<LoginStateService>();
        await loginStateService.recordManualLogin();
        debugPrint('✅ AuthBloc: Emitting AuthAuthenticated with isFreshLogin: true');
        emit(AuthAuthenticated(user: user, isFreshLogin: true));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await signUp.call(
          identifier: event.identifier,
          password: event.password,
          name: event.name);
      if (user != null) {
        // If user is returned but not phone verified, show OTP verification
        if (!user.isPhoneVerified) {
          emit(AuthAwaitingOtpVerification(tempUser: user));
        } else {
          emit(AuthAuthenticated(user: user));
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignInWithGoogleRequested(
      AuthSignInWithGoogleRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithGoogle.call();
      if (user != null) {
        // This is a fresh Google login
        final loginStateService = getIt<LoginStateService>();
        await loginStateService.recordGoogleLogin();
        emit(AuthAuthenticated(user: user, isFreshLogin: true));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignInWithAppleRequested(
      AuthSignInWithAppleRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithApple.call();
      if (user != null) {
        // This is a fresh Apple login
        final loginStateService = getIt<LoginStateService>();
        await loginStateService.recordAppleLogin();
        emit(AuthAuthenticated(user: user, isFreshLogin: true));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignedOut(
      AuthSignedOut event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await signOut.call();
      // Clear login state when signing out
      final loginStateService = getIt<LoginStateService>();
      await loginStateService.clearLoginState();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onMarkVerified(
      AuthMarkVerified event, Emitter<AuthState> emit) async {
    final current = state;
    if (current is AuthAuthenticated) {
      // Update the in-memory user to reflect verification (demo only).
      final updatedUser = current.user.copyWith(isVerified: true);
      // Persist updated user in repository so the verification status survives restarts (fake impl).
      try {
        final repo = getIt<AuthRepository>();
        await repo.persistCurrentUser(updatedUser);
      } catch (_) {
        // ignore persistence errors in demo mode
      }
      emit(AuthAuthenticated(user: updatedUser));
    }
  }

  Future<void> _onOtpVerificationRequested(
      AuthOtpVerificationRequested event, Emitter<AuthState> emit) async {
    emit(const AuthOtpVerificationLoading());
    try {
      final repo = getIt<AuthRepository>();
      final user = await repo.verifyOtp(otp: event.otp, pinId: event.pinId);

      if (user != null) {
        emit(AuthRegistrationComplete(user: user));
        // Also emit authenticated state
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Invalid OTP. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onResendOtpRequested(
      AuthResendOtpRequested event, Emitter<AuthState> emit) async {
    try {
      final repo = getIt<AuthRepository>();
      final success = await repo.resendOtp(phone: event.phone);

      if (!success) {
        emit(const AuthError(
            message: 'Failed to resend OTP. Please try again.'));
      } else {
        emit(AuthOtpSent(phone: event.phone));
      }
      // Note: We don't change state on success, just let user try entering OTP again
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
      AuthForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final repo = getIt<AuthRepository>();
      await repo.forgotPassword(email: event.email);

      // Don't change auth state, just show success message
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
      AuthResetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final repo = getIt<AuthRepository>();
      final success = await repo.resetPassword(
        token: event.token,
        newPassword: event.newPassword,
      );

      if (success) {
        emit(const AuthUnauthenticated());
      } else {
        emit(const AuthError(
            message: 'Failed to reset password. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
