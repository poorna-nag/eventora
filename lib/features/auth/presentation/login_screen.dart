import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/core/utils/validators.dart';
import 'package:eventora/core/widgets/custom_button.dart';
import 'package:eventora/core/widgets/custom_text_field.dart';
import 'package:eventora/features/auth/data/auth_service.dart';
import 'package:flutter/material.dart';

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
        NavigationService.pushReplacementNamed(routeName: AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
