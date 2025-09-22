import 'package:meta/meta.dart';
import '../../domain/entities/user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
}

/// Emitted after an OTP is successfully sent to the user's phone number.
class AuthOtpSent extends AuthState {
  final String? phone;
  const AuthOtpSent({this.phone});
}

class AuthAwaitingOtpVerification extends AuthState {
  final User? tempUser;
  final String? pinId;
  const AuthAwaitingOtpVerification({this.tempUser, this.pinId});
}

class AuthOtpVerificationLoading extends AuthState {
  const AuthOtpVerificationLoading();
}

class AuthRegistrationComplete extends AuthState {
  final User user;
  const AuthRegistrationComplete({required this.user});
}
