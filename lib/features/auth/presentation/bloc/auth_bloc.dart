import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_event.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthPhoneVerificationRequested>(_onAuthPhoneVerificationRequested);
    on<AuthOTPVerificationRequested>(_onAuthOTPVerificationRequested);
    on<AuthResendOTPRequested>(_onAuthResendOTPRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = authRepository.currentUser;
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (user != null && isLoggedIn) {
        final userData = await authRepository.getCurrentUserData();
        if (userData != null) {
          emit(AuthAuthenticated(user: userData));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await authRepository.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthPhoneVerificationRequested(
    AuthPhoneVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPhoneVerifying());

    try {
      await authRepository.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId) {
          emit(
            AuthOTPSent(
              verificationId: verificationId,
              phoneNumber: event.phoneNumber,
            ),
          );
        },
        onError: (error) {
          emit(AuthError(message: error));
        },
        onAutoVerify: (credential) async {
          // Auto-verification successful (Android only)
          try {
            final userData = await authRepository.getCurrentUserData();
            if (userData != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', true);
              emit(AuthAuthenticated(user: userData));
            }
          } catch (e) {
            emit(AuthError(message: e.toString()));
          }
        },
      );
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthOTPVerificationRequested(
    AuthOTPVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthOTPVerifying());

    try {
      final user = await authRepository.verifyOTP(
        verificationId: event.verificationId,
        otp: event.otp,
        name: event.name,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthResendOTPRequested(
    AuthResendOTPRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPhoneVerifying());

    try {
      await authRepository.resendOTP(
        phoneNumber: event.phoneNumber,
        onCodeSent: (verificationId) {
          emit(
            AuthOTPSent(
              verificationId: verificationId,
              phoneNumber: event.phoneNumber,
            ),
          );
        },
        onError: (error) {
          emit(AuthError(message: error));
        },
      );
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await authRepository.resetPassword(email: event.email);
      emit(AuthPasswordResetSent());
    } catch (e) {
      emit(AuthError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
