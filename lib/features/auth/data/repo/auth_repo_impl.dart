import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventora/features/auth/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  int? _resendToken;

  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromJson(doc.data()!);
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    amc,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await user.updateDisplayName(name);

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        createdAt: Timestamp.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Phone Verification - Send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function(UserCredential credential) onAutoVerify,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          final userCredential = await _auth.signInWithCredential(credential);
          onAutoVerify(userCredential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(_handleAuthException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout handled
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP and Sign In
  Future<UserModel> verifyOTP({
    required String verificationId,
    required String otp,
    String? name,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user exists
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        // Existing user
        return UserModel.fromJson(doc.data()!);
      } else {
        // New user - create profile
        if (name == null || name.isEmpty) {
          throw Exception('Name is required for new users');
        }

        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: user.email ?? '',
          phoneNumber: user.phoneNumber,
          createdAt: Timestamp.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Resend OTP
  Future<void> resendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerify: (_) {},
    );
  }

  // Password Reset
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update Profile
  Future<void> updateProfile({String? name, String? profileImageUrl}) async {
    final user = currentUser;
    if (user == null) throw Exception('No user logged in');

    if (name != null) {
      await user.updateDisplayName(name);
    }

    if (profileImageUrl != null) {
      await user.updatePhotoURL(profileImageUrl);
    }

    await _firestore.collection('users').doc(user.uid).update({
      if (name != null) 'name': name,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    });
  }

  // Increment Events Created
  Future<void> incrementEventsCreated(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'eventsCreated': FieldValue.increment(1),
    });
  }

  // Increment Bookings Made
  Future<void> incrementBookingsMade(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'bookingsMade': FieldValue.increment(1),
    });
  }

  // Handle Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for that email';
      case 'user-not-found':
        return 'No user found for that email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This user has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please try again';
      case 'invalid-verification-id':
        return 'Verification session expired. Please resend OTP';
      case 'session-expired':
        return 'OTP session expired. Please request a new code';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}
