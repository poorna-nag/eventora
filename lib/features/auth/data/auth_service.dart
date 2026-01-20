import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:eventora/features/auth/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final AuthRepository _authRepository = AuthRepository();

  User? get currentUser => _authRepository.currentUser;

  Stream<User?> get authStateChanges => _authRepository.authStateChanges;

  Future<UserModel?> getCurrentUserData() async {
    return await _authRepository.getCurrentUserData();
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.signUp(
      name: name,
      email: email,
      password: password,
    );
    await _saveLoginState(true);
    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.signIn(email: email, password: password);
    await _saveLoginState(true);
    return user;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    await _saveLoginState(false);
  }

  Future<void> resetPassword(String email) async {
    await _authRepository.resetPassword(email: email);
  }

  Future<void> updateProfile({String? name, String? profileImageUrl}) async {
    await _authRepository.updateProfile(
      name: name,
      profileImageUrl: profileImageUrl,
    );
  }

  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
