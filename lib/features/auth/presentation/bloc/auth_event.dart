import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

// Email Authentication Events
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

// Phone Authentication Events
class AuthPhoneVerificationRequested extends AuthEvent {
  final String phoneNumber;

  const AuthPhoneVerificationRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOTPVerificationRequested extends AuthEvent {
  final String verificationId;
  final String otp;
  final String? name; // For new users during signup

  const AuthOTPVerificationRequested({
    required this.verificationId,
    required this.otp,
    this.name,
  });

  @override
  List<Object?> get props => [verificationId, otp, name];
}

class AuthResendOTPRequested extends AuthEvent {
  final String phoneNumber;

  const AuthResendOTPRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

// Common Events
class AuthLogoutRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
