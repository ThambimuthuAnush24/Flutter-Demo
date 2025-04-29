// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.register(
        _emailController.text,
        _passwordController.text,
        _fullNameController.text,
      );
      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSocialLogin(UserCredential userCredential, String provider) async {
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to retrieve token.")),
      );
      return;
    }

    try {
      await _apiService.socialLogin(idToken, provider);
      Navigator.pushReplacementNamed(context, '/signin'); // Or go to dashboard
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Backend login failed: $e")),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      await _handleSocialLogin(userCredential, 'google');
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final userCredential = await _auth.signInWithCredential(credential);
        await _handleSocialLogin(userCredential, 'facebook');
      }
    } catch (e) {
      debugPrint('Facebook Sign-In Error: $e');
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );
      final oauth = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      final userCredential = await _auth.signInWithCredential(oauth);
      await _handleSocialLogin(userCredential, 'apple');
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
    }
  }

  Widget _socialIcon(String path, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        width: 40,
        child: Image.asset(path, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildLabeledField(
    String label,
    String placeholder, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Color(0xFFE8EFFF),
            suffixIcon: isPassword ? Icon(Icons.visibility) : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2853AF),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      _buildLabeledField(
                        'Email/Phone Number',
                        'Enter your email or phone number',
                        controller: _emailController,
                      ),
                      SizedBox(height: 12),
                      _buildLabeledField(
                        'Full Name',
                        'Enter your full name',
                        controller: _fullNameController,
                      ),
                      SizedBox(height: 12),
                      _buildLabeledField(
                        'Password',
                        'Enter your password',
                        isPassword: true,
                        controller: _passwordController,
                      ),
                      SizedBox(height: 12),
                      _buildLabeledField(
                        'Confirm Password',
                        'Re-enter your password',
                        isPassword: true,
                        controller: _confirmPasswordController,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2853AF),
                            minimumSize: Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white),
                                )
                              : Text('Create Account', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Sign up with"),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialIcon("assets/google.png", _signInWithGoogle),
                          SizedBox(width: 38),
                          _socialIcon("assets/apple.png", _signInWithApple),
                          SizedBox(width: 38),
                          _socialIcon("assets/facebook.png", _signInWithFacebook),
                        ],
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signin');
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'By signing up you agree to our ',
                            children: [
                              TextSpan(
                                text: 'Terms ',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: 'and '),
                              TextSpan(
                                text: 'Conditions of Use',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
