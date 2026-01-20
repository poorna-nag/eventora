import 'package:equatable/equatable.dart';
import 'package:eventora/features/auth/data/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Phone Authentication States
class AuthPhoneVerifying extends AuthState {}

class AuthOTPSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthOTPSent({required this.verificationId, required this.phoneNumber});

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class AuthOTPVerifying extends AuthState {}

// Password Reset State
class AuthPasswordResetSent extends AuthState {}
