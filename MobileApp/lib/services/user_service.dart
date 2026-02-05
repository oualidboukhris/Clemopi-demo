import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage logged-in user data locally (replaces Firebase Auth)
class UserService {
  static const String _userKey = 'current_user';

  /// Save user data after login
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  /// Get user data from SharedPreferences
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final user = await getUser();
    return user?['userId']?.toString();
  }

  /// Clear user data (logout)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }
}
