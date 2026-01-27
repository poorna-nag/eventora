import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/core/utils/validators.dart';
import 'package:eventora/core/widgets/custom_button.dart';
import 'package:eventora/core/widgets/custom_text_field.dart';
import 'package:eventora/core/widgets/safety_warning_dialog.dart';
import 'package:eventora/core/widgets/terms_and_conditions_dialog.dart';
import 'package:eventora/features/auth/data/auth_service.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_event.dart';
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
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

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
                    // Update AuthBloc checking
                    if (mounted) {
                      context.read<AuthBloc>().add(AuthCheckRequested());
                      _checkAgeAndNavigate();
                    }
                  },
                ),
              );
            },
          ),
        );

        // If user declined terms (accepted is null or false), sign them out locally
        // Note: Terms dialog returning null implies dismissal without accept
        // But barrierDismissible is false, so they must check box and Accept
        // However, if they somehow close it...

        // Actually, logic above waits for showDialog.
        // If they accept, onAccept runs.
        // The dialog itself returns result.

        if (accepted == false || accepted == null) {
          await _authService.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'You must accept the Terms & Conditions to use this app',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkAgeAndNavigate() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (!mounted) return;

      if (userData != null && userData.isAgeVerified == true) {
        NavigationService.pushReplacementNamed(routeName: AppRoutes.home);
      } else {
        NavigationService.pushReplacementNamed(
          routeName: AppRoutes.ageVerification,
        );
      }
    } catch (e) {
      // Fallback
      NavigationService.pushReplacementNamed(
        routeName: AppRoutes.ageVerification,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Login to continue",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: _buildLoginForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Login",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            hintText: "Email",
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.orange),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            hintText: "Password",
            obscureText: _obscurePassword,
            validator: Validators.validatePassword,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
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
                "Forgot Password?",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Log In',
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("OR", style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Create Account',
            onPressed: () {
              NavigationService.pushNamed(routeName: AppRoutes.signin);
            },
            backgroundColor: const Color(0xFF3B5BD6),
          ),
        ],
      ),
    );
  }
}
