import 'package:eventora/core/services/phone_verification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneVerificationDialog extends StatefulWidget {
  final String userId;
  final Function(String phoneNumber) onVerified;

  const PhoneVerificationDialog({
    super.key,
    required this.userId,
    required this.onVerified,
  });

  @override
  State<PhoneVerificationDialog> createState() =>
      _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _phoneVerificationService = PhoneVerificationService();

  bool _isLoading = false;
  bool _otpSent = false;
  String? _verificationId;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _initResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });
    _tickTimer();
  }

  void _tickTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() => _resendTimer--);
        _tickTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showError('Please enter a valid 10-digit phone number');
      return;
    }

    setState(() => _isLoading = true);

    final phoneNumber = '+91$phone';
    debugPrint('Attempting to send OTP to $phoneNumber');

    try {
      await _phoneVerificationService.sendOTP(
        phoneNumber: phoneNumber,
        onCodeSent: (verificationId) {
          debugPrint('OTP Code Sent. Verification ID: $verificationId');
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _otpSent = true;
              _isLoading = false;
            });
            _initResendTimer();
            if (ScaffoldMessenger.of(context).mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP sent successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        },
        onError: (error) {
          debugPrint('OTP Error: $error');
          if (mounted) {
            setState(() => _isLoading = false);
            _showError(error);
          }
        },
        onAutoVerified: () async {
          debugPrint('OTP Auto-verified');
          if (mounted) {
            await _completeVerification();
          }
        },
      );
    } catch (e) {
      debugPrint('Exception in _sendOTP: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('An unexpected error occurred: $e');
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      _showError('Verification ID not found. Please resend OTP.');
      return;
    }

    setState(() => _isLoading = true);

    final verified = await _phoneVerificationService.verifyOTP(
      verificationId: _verificationId!,
      otp: _otpController.text.trim(),
    );

    if (verified) {
      await _completeVerification();
    } else {
      setState(() => _isLoading = false);
      _showError('Invalid OTP. Please try again.');
    }
  }

  Future<void> _completeVerification() async {
    final phoneNumber = '+91${_phoneController.text.trim()}';

    try {
      await _phoneVerificationService.savePhoneNumber(
        userId: widget.userId,
        phoneNumber: phoneNumber,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onVerified(phoneNumber);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to save phone number: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Verify Phone Number',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'We need to verify your phone number for security',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (!_otpSent) ...[
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '+91',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        hintText: '9876543210',
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '------',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sent to +91${_phoneController.text}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: _canResend ? _initResendTimer : null,
                    child: Text(
                      _canResend ? 'Resend OTP' : 'Resend in ${_resendTimer}s',
                      style: TextStyle(
                        color: _canResend ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : (_otpSent ? _verifyOTP : _sendOTP),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _otpSent ? 'Verify' : 'Send OTP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
