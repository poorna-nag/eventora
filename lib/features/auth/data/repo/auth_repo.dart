import 'dart:io';

import 'package:eventora/features/auth/data/user_model.dart';

abstract class AuthRepo {
  Future<bool> singin(UserModel userData);
  Future<bool> login(String email, String passcode);
  Future<void> signInWithGoogle();
  Future<void> uploadToDrive(List<File> files);
}
