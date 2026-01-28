import 'package:eventora/core/app_const/app_colors.dart';
import 'package:eventora/core/app_const/app_strings.dart';
import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  Future<void> _onLoginSuccess(
    BuildContext context,
    AuthAuthenticated state,
  ) async {
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
                  _checkAgeAndNavigate(state);
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

  void _checkAgeAndNavigate(AuthAuthenticated state) {
    if (state.user.isAgeVerified == true) {
      NavigationService.pushReplacementNamed(routeName: AppRoutes.home);
    } else {
      NavigationService.pushReplacementNamed(
        routeName: AppRoutes.ageVerification,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _onLoginSuccess(context, state);
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
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      AppStrings.welcomeBack,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.loginSubtitle,
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
                          return _buildLoginForm(state is AuthLoading);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.login,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            hintText: AppStrings.email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                NavigationService.pushNamed(
                  routeName: AppRoutes.forgotPassword,
                );
              },
              child: const Text(
                AppStrings.forgotPassword,
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: AppStrings.login,
            onPressed: _handleLogin,
            isLoading: isLoading,
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          CustomButton(
            text: AppStrings.createAccount,
            onPressed: () {
              NavigationService.pushNamed(routeName: AppRoutes.signin);
            },
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppStrings.or, style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
