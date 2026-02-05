import 'dart:convert';
import 'database_helper.dart';

class CacheService {
  final DatabaseHelper _db = DatabaseHelper();

  // Save data to cache
  Future<void> saveCache(
    String key,
    dynamic value, {
    Duration? expiresIn,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = expiresIn != null ? now + expiresIn.inMilliseconds : null;

    await _db.insert('cache', {
      'key': key,
      'value': jsonEncode(value),
      'created_at': now,
      'expires_at': expiresAt,
    });
  }

  // Get data from cache
  Future<dynamic> getCache(String key) async {
    final results = await _db.query(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final cache = results.first;
    final expiresAt = cache['expires_at'] as int?;

    // Check if expired
    if (expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiresAt) {
        await deleteCache(key);
        return null;
      }
    }

    return jsonDecode(cache['value'] as String);
  }

  // Delete cache by key
  Future<void> deleteCache(String key) async {
    await _db.delete(
      'cache',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await _db.deleteAll('cache');
  }

  // Clear expired cache
  Future<void> clearExpiredCache() async {
    await _db.clearExpiredCache();
  }

  // Check if cache exists and is valid
  Future<bool> hasValidCache(String key) async {
    final data = await getCache(key);
    return data != null;
  }
}
