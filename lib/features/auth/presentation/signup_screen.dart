import 'package:eventora/core/app_const/app_colors.dart';
import 'package:eventora/core/app_const/app_strings.dart';
import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/core/services/permission_service.dart';
import 'package:eventora/core/utils/validators.dart';
import 'package:eventora/core/widgets/custom_button.dart';
import 'package:eventora/core/widgets/custom_text_field.dart';
import 'package:eventora/core/widgets/safety_warning_dialog.dart';
import 'package:eventora/core/widgets/terms_and_conditions_dialog.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_event.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _onSignUpSuccess(BuildContext context) async {
    // Show Terms & Conditions dialog
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => TermsAndConditionsDialog(
        onAccept: () async {
          // Show Safety Warning after accepting terms
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SafetyWarningDialog(
              onAcknowledge: () {
                if (mounted) {
                  context.read<AuthBloc>().add(AuthCheckRequested());
                  _checkAgePermissionsAndNavigate(
                    context.read<AuthBloc>().state as AuthAuthenticated,
                  );
                }
              },
            ),
          );
        },
      ),
    );

    if (accepted == false || accepted == null) {
      if (mounted) {
        context.read<AuthBloc>().add(AuthLogoutRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.acceptTermsWarning),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _checkAgePermissionsAndNavigate(AuthAuthenticated state) async {
    if (state.user.isAgeVerified != true) {
      NavigationService.pushReplacementNamed(
        routeName: AppRoutes.ageVerification,
      );
      return;
    }

    final shouldShowPermissions = await PermissionService.shouldShowRequest(
      state.user.uid,
    );
    if (shouldShowPermissions) {
      NavigationService.pushReplacementNamed(
        routeName: AppRoutes.permissions,
        arguments: state.user.uid,
      );
    } else {
      NavigationService.pushReplacementNamed(routeName: AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _onSignUpSuccess(context);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    AppStrings.createAccount,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.signupSubtitle,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return _buildSignUpForm(state is AuthLoading);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.signup,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _nameController,
            hintText: AppStrings.name,
            validator: Validators.validateName,
            prefixIcon: const Icon(
              Icons.person_outline,
              color: AppColors.iconColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _emailController,
            hintText: AppStrings.email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.iconColor,
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            hintText: AppStrings.password,
            obscureText: _obscurePassword,
            validator: Validators.validatePassword,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.iconColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            hintText: AppStrings.confirmPassword,
            obscureText: _obscureConfirmPassword,
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.iconColor,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: AppStrings.signup,
            onPressed: _handleSignUp,
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: RichText(
                text: TextSpan(
                  text: AppStrings.alreadyHaveAccount,
                  style: const TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                      text: AppStrings.login,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
