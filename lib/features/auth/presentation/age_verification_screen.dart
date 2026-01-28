import 'package:eventora/core/app_const/app_colors.dart';
import 'package:eventora/core/app_const/app_strings.dart';
import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/core/widgets/custom_button.dart';
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
  bool _isLoading = false;

  Future<void> _handleAgeConfirmation(bool isOver18) async {
    final authRepo = context.read<AuthBloc>().authRepository;

    if (isOver18) {
      setState(() => _isLoading = true);
      try {
        await authRepo.verifyAge();
        if (mounted) {
          context.read<AuthBloc>().add(AuthCheckRequested());
          NavigationService.pushReplacementNamed(routeName: AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppStrings.unknownError}: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      await authRepo.signOut();
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
        NavigationService.pushReplacementNamed(routeName: AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.underAgeError),
            backgroundColor: AppColors.error,
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
                    color: AppColors.background,
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
                        color: AppColors.iconColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.ageVerificationTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textHeadline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.ageVerificationQuestion,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.ageWarning,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomButton(
                        text: AppStrings.yesOver18,
                        onPressed: () => _handleAgeConfirmation(true),
                        isLoading: _isLoading,
                        backgroundColor: AppColors.iconColor,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: AppStrings.noUnder18,
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
