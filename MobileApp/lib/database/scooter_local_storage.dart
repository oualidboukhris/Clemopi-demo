import 'database_helper.dart';

class ScooterLocalStorage {
  final DatabaseHelper _db = DatabaseHelper();

  // Save scooter data
  Future<void> saveScooter({
    required String scooterId,
    int? batteryLevel,
    double? latitude,
    double? longitude,
    String? status,
  }) async {
    await _db.insert('scooter_cache', {
      'scooter_id': scooterId,
      'battery_level': batteryLevel,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'last_synced': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Get scooter data
  Future<Map<String, dynamic>?> getScooter(String scooterId) async {
    final results = await _db.query(
      'scooter_cache',
      where: 'scooter_id = ?',
      whereArgs: [scooterId],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  // Get all scooters
  Future<List<Map<String, dynamic>>> getAllScooters() async {
    return await _db.queryAll('scooter_cache');
  }

  // Get nearby scooters (simplified - within lat/lng range)
  Future<List<Map<String, dynamic>>> getNearbyScooters({
    required double latitude,
    required double longitude,
    double range = 0.01, // approximately 1km
  }) async {
    final results = await _db.rawQuery('''
      SELECT * FROM scooter_cache
      WHERE latitude BETWEEN ? AND ?
      AND longitude BETWEEN ? AND ?
      AND status = 'available'
    ''', [
      latitude - range,
      latitude + range,
      longitude - range,
      longitude + range,
    ]);

    return results;
  }

  // Update scooter
  Future<void> updateScooter(
    String scooterId,
    Map<String, dynamic> updates,
  ) async {
    updates['last_synced'] = DateTime.now().millisecondsSinceEpoch;

    await _db.update(
      'scooter_cache',
      updates,
      where: 'scooter_id = ?',
      whereArgs: [scooterId],
    );
  }

  // Delete scooter
  Future<void> deleteScooter(String scooterId) async {
    await _db.delete(
      'scooter_cache',
      where: 'scooter_id = ?',
      whereArgs: [scooterId],
    );
  }

  // Clear all scooters
  Future<void> clearAllScooters() async {
    await _db.deleteAll('scooter_cache');
  }

  // Get scooters by status
  Future<List<Map<String, dynamic>>> getScootersByStatus(String status) async {
    return await _db.query(
      'scooter_cache',
      where: 'status = ?',
      whereArgs: [status],
    );
  }

  // Sync scooters from server (batch save)
  Future<void> syncScooters(List<Map<String, dynamic>> scooters) async {
    for (var scooter in scooters) {
      await saveScooter(
        scooterId: scooter['scooter_id'],
        batteryLevel: scooter['battery_level'],
        latitude: scooter['latitude'],
        longitude: scooter['longitude'],
        status: scooter['status'],
      );
    }
  }
}
