import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/core/widgets/custom_button.dart';
import 'package:eventora/features/auth/data/repo/auth_repo_impl.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AgeVerificationScreen extends StatefulWidget {
  const AgeVerificationScreen({super.key});

  @override
  State<AgeVerificationScreen> createState() => _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends State<AgeVerificationScreen> {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;

  Future<void> _handleAgeConfirmation(bool isOver18) async {
    if (isOver18) {
      setState(() => _isLoading = true);
      try {
        await _authRepository.verifyAge();
        if (mounted) {
          // Refresh auth state to update currentUser and then navigate home
          context.read<AuthBloc>().add(AuthCheckRequested());
          NavigationService.pushReplacementNamed(routeName: AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      // User is under 18
      await _authRepository.signOut();
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
        NavigationService.pushReplacementNamed(routeName: AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be 18+ to use this app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 60,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Age Verification',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Are you 18 years of age or older?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This app contains content suitable only for adults.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: 'Yes, I am 18+',
                        onPressed: () => _handleAgeConfirmation(true),
                        isLoading: _isLoading,
                        backgroundColor: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'No, I am under 18',
                        onPressed: () => _handleAgeConfirmation(false),
                        backgroundColor: Colors.grey.shade200,
                        textColor: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
