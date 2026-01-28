import 'dart:ui';
import 'package:eventora/core/app_const/app_strings.dart';
import 'package:eventora/core/app_const/auth_background.dart';
import 'package:eventora/core/navigation/navigation_service.dart';
import 'package:eventora/core/services/permission_service.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eventora/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  Future<void> _navigateFromAuth(AuthAuthenticated state) async {
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
        if (_hasNavigated) return;

        if (state is AuthAuthenticated) {
          _hasNavigated = true;
          _navigateFromAuth(state);
        } else if (state is AuthUnauthenticated || state is AuthError) {
          _hasNavigated = true;
          NavigationService.pushReplacementNamed(routeName: AppRoutes.login);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AuthBackground(child: Container()),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _logo(),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.appNameWithAge,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.asset(
          'assets/images/icon.png',
          fit: BoxFit.cover,
          width: 120,
          height: 120,
        ),
      ),
    );
  }
}
