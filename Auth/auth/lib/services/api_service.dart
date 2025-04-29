import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://10.10.42.117:8000/api/auth/";
  final storage = FlutterSecureStorage();

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await storage.write(key: 'auth_token', value: token);
  }

  // Login method with optional social login
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool isSocialLogin = false,
    String? socialProvider,
    String? socialToken,
  }) async {
    final url = Uri.parse("${baseUrl}login/");
    try {
      final body = isSocialLogin
          ? {
              "email": email,
              "social_provider": socialProvider,
              "social_token": socialToken,
            }
          : {
              "email": email,
              "password": password,
            };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        await saveToken(data['token']); // Save the token here
      }
      return data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Social login method
  Future<Map<String, dynamic>> socialLogin(String token, String provider) async {
    final url = Uri.parse("${baseUrl}social-login/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "provider": provider,
          "token": token,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        await saveToken(data['token']); // Save the token here
      }
      return data;
    } catch (e) {
      throw Exception('Social login failed: $e');
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(String email, String password, String fullName) async {
    final url = Uri.parse("${baseUrl}register/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "full_name": fullName,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['token'] != null) {
        await saveToken(data['token']); // Save the token here
      }
      return data;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Send forgot password email
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse("${baseUrl}forgot-password/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Forgot password request failed: $e');
    }
  }

  // Verify reset code
  Future<Map<String, dynamic>> verifyCode(String code) async {
    final url = Uri.parse("${baseUrl}verify-code/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"code": code}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        await storage.write(key: 'reset_token', value: data['token']);
      }
      return data;
    } catch (e) {
      throw Exception('Code verification failed: $e');
    }
  }

  // Resend code
  Future<Map<String, dynamic>> resendVerificationCode() async {
    final url = Uri.parse("${baseUrl}resend-code/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Resend code failed: $e');
    }
  }

  // Reset user password
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    final url = Uri.parse("${baseUrl}reset-password/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "new_password": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'reset_token');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Reset password failed: $e');
    }
  }

  // Fetch user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No auth token found');
    }

    final url = Uri.parse("${baseUrl}profile/");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Get profile failed: $e');
    }
  }

  // Log out
  Future<void> logout() async {
    try {
      await storage.delete(key: 'auth_token');
      await storage.delete(key: 'reset_token');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Check if token exists (user authenticated)
  Future<bool> isAuthenticated() async {
    final token = await storage.read(key: 'auth_token');
    return token != null;
  }

  // Get stored token
  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  // Get reset token
  Future<String?> getResetToken() async {
    return await storage.read(key: 'reset_token');
  }

  // Mark tutorial as seen
  Future<void> markTutorialSeen() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('Unauthorized');

    final url = Uri.parse("${baseUrl}tutorial/seen/");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark tutorial as seen');
      }
    } catch (e) {
      throw Exception('Mark tutorial as seen failed: $e');
    }
  }
}
