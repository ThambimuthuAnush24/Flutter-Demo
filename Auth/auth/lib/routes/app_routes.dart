import 'package:flutter/material.dart';
import '../screens/welcome_tutorial_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/signin_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/code_verification_screen.dart';
import '../screens/reset_password_screen.dart';

class AppRoutes {
  // Route names as constants
  static const String welcome = '/welcome';
  static const String signUp = '/signup';
  static const String signIn = '/signin';
  static const String forgotPassword = '/forgot-password';
  static const String codeVerification = '/code-verification';
  static const String resetPassword = '/reset-password';

  // Route map for MaterialApp
  static final Map<String, WidgetBuilder> routes = {
    welcome: (context) => WelcomeTutorialScreen(),
    signUp: (context) => SignUpScreen(),
    signIn: (context) => SignInScreen(),
    forgotPassword: (context) => ForgotPasswordScreen(),
    codeVerification: (context) => CodeVerificationScreen(),
    resetPassword: (context) => ResetPasswordScreen(),
  };

  // Initial route
  static const String initialRoute = welcome;
}