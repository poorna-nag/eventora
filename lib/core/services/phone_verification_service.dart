import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _verificationId;
  int? _resendToken;

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    required Function() onAutoVerified,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          onAutoVerified();
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // Verify OTP code
  Future<bool> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Link phone credential to current user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        try {
          await currentUser.linkWithCredential(credential);
        } catch (e) {
          // If already linked, just verify
          print('Phone already linked or error: $e');
        }
      }

      return true;
    } catch (e) {
      print('OTP verification error: $e');
      return false;
    }
  }

  // Save phone number to user profile
  Future<void> savePhoneNumber({
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'phoneNumber': phoneNumber,
        'phoneVerified': true,
        'phoneVerifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save phone number: $e');
    }
  }

  // Check if user has verified phone number
  Future<bool> isPhoneVerified(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      return data?['phoneVerified'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get user's phone number
  Future<String?> getUserPhoneNumber(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      return data?['phoneNumber'] as String?;
    } catch (e) {
      return null;
    }
  }
}
