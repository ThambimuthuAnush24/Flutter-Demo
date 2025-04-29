import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_tutorial_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/code_verification_screen.dart';
import 'screens/reset_password_screen.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF2853AF),
        scaffoldBackgroundColor: Colors.white,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF2853AF),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2853AF),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFE8EFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF2853AF)),
          ),
        ),
      ),
      routes: {
        AppRoutes.welcome: (context) => WelcomeTutorialScreen(),
        AppRoutes.signUp: (context) => SignUpScreen(),
        AppRoutes.signIn: (context) => SignInScreen(),
        AppRoutes.forgotPassword: (context) => ForgotPasswordScreen(),
        AppRoutes.codeVerification: (context) => CodeVerificationScreen(),
        AppRoutes.resetPassword: (context) => ResetPasswordScreen(),
      },
      initialRoute: AppRoutes.welcome,
    );
  }
}
