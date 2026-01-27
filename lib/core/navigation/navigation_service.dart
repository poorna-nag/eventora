import 'package:eventora/features/auth/presentation/age_verification_screen.dart';
import 'package:eventora/features/auth/presentation/forgot_password_screen.dart';
import 'package:eventora/features/auth/presentation/login_screen.dart';
import 'package:eventora/features/auth/presentation/signup_screen.dart';
import 'package:eventora/features/create/event_confirm_screen.dart';
import 'package:eventora/features/events/home_screen.dart';
import 'package:eventora/splash_screen.dart';
import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<T?> pushNamed<T extends Object?>({
    required String routeName,
    Object? arguments,
  }) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<
    T extends Object?,
    TO extends Object?
  >({required String routeName, Object? arguments, TO? result}) {
    return navigator!.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static void pop() {
    return navigatorKey.currentState!.pop();
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.sp:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.signin:
        return MaterialPageRoute(
          builder: (context) => const SignUpScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.eventcreate:
        return MaterialPageRoute(
          builder: (_) => const EventConfirmScreen(),
          settings: settings,
        );

      case AppRoutes.ageVerification:
        return MaterialPageRoute(
          builder: (_) => const AgeVerificationScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}

class AppRoutes {
  static const String sp = '/sp';
  static const String signin = '/signin';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = "/home";
  static const String eventcreate = "/eventcreate";
  static const String eventDetails = "/event-details";
  static const String createEvent = "/create-event";
  static const String myEvents = "/my-events";
  static const String myBookings = "/my-bookings";
  static const String profile = "/profile";
  static const String editProfile = "/edit-profile";
  static const String ageVerification = "/age-verification";
}
