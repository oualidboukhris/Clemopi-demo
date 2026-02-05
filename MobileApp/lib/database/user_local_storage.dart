import 'dart:convert';
import 'database_helper.dart';

class UserLocalStorage {
  final DatabaseHelper _db = DatabaseHelper();

  // Save user data
  Future<void> saveUser({
    required String userId,
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? additionalData,
  }) async {
    await _db.insert('user_data', {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'data': additionalData != null ? jsonEncode(additionalData) : null,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get user data by user ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final results = await _db.query(
      'user_data',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final user = results.first;
    return {
      'user_id': user['user_id'],
      'name': user['name'],
      'email': user['email'],
      'phone': user['phone'],
      'data': user['data'] != null ? jsonDecode(user['data'] as String) : null,
      'last_updated': user['last_updated'],
    };
  }

  // Update user data
  Future<void> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    updates['last_updated'] = DateTime.now().millisecondsSinceEpoch;

    await _db.update(
      'user_data',
      updates,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _db.delete(
      'user_data',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final results = await _db.queryAll('user_data');
    return results.map((user) {
      return {
        'user_id': user['user_id'],
        'name': user['name'],
        'email': user['email'],
        'phone': user['phone'],
        'data':
            user['data'] != null ? jsonDecode(user['data'] as String) : null,
        'last_updated': user['last_updated'],
      };
    }).toList();
  }

  // Clear all user data
  Future<void> clearAllUsers() async {
    await _db.deleteAll('user_data');
  }
}
