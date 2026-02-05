import 'dart:math' as math;
import 'api_service.dart';
import 'api_config.dart';

class ScooterService {
  final ApiService _api = ApiService();

  // Get all kickscooters
  Future<Map<String, dynamic>> getAllScooters() async {
    return await _api.get(ApiConfig.kickscooters);
  }

  // Get single kickscooter
  Future<Map<String, dynamic>> getScooter(String scooterId) async {
    return await _api.get(ApiConfig.kickscooter(scooterId));
  }

  // Update kickscooter
  Future<Map<String, dynamic>> updateScooter(
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      ApiConfig.kickscooters,
      data,
    );
  }

  // Update key state
  Future<Map<String, dynamic>> updateKeyState({
    required String scooterId,
    required bool keyState,
  }) async {
    return await _api.put(
      ApiConfig.updateKeyState,
      {
        'scooterId': scooterId,
        'keyState': keyState,
      },
    );
  }

  // Unlock scooter by QR code (public endpoint - no auth required)
  Future<Map<String, dynamic>> unlockScooterByQR(String qrCode) async {
    try {
      final response = await _api.post(
        ApiConfig.unlockScooter,
        {'qrCode': qrCode},
        requiresAuth: false, // Public endpoint, no authentication needed
      );

      // The API service wraps response in {success, data, statusCode}
      // Extract the actual data
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        return {
          'error': true,
          'message': response['error'] ?? 'Failed to unlock scooter',
          'isValid': false,
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to unlock scooter: $e',
        'isValid': false,
      };
    }
  }

  // Get scooter info by QR code (public endpoint - sends SCOOTER_INFO command)
  Future<Map<String, dynamic>> getScooterInfoByQR(String qrCode) async {
    try {
      final response = await _api.post(
        ApiConfig.scooterInfo,
        {'qrCode': qrCode},
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        return {
          'error': true,
          'message': response['error'] ?? 'Failed to get scooter info',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to get scooter info: $e',
      };
    }
  }

  // Lock scooter by QR code (public endpoint - sends STATION_LOCK and SCOOTER_LOCK commands)
  Future<Map<String, dynamic>> lockScooterByQR(String qrCode) async {
    try {
      final response = await _api.post(
        ApiConfig.lockScooter,
        {'qrCode': qrCode},
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      } else {
        return {
          'error': true,
          'message': response['error'] ?? 'Failed to lock scooter',
        };
      }
    } catch (e) {
      return {
        'error': true,
        'message': 'Failed to lock scooter: $e',
      };
    }
  }

  // Get available scooters (filter by status)
  Future<Map<String, dynamic>> getAvailableScooters() async {
    final response = await getAllScooters();

    if (response['success']) {
      final scooters = response['data'] as List;
      final available =
          scooters.where((s) => s['status'] == 'available').toList();
      return {
        'success': true,
        'data': available,
      };
    }

    return response;
  }

  // Get nearby scooters (requires location filtering on client side)
  Future<Map<String, dynamic>> getNearbyScooters({
    required double latitude,
    required double longitude,
    double maxDistance = 1.0, // km
  }) async {
    final response = await getAllScooters();

    if (response['success']) {
      final scooters = response['data'] as List;

      // Filter scooters by distance
      final nearby = scooters.where((scooter) {
        final lat = scooter['latitude'] as double?;
        final lng = scooter['longitude'] as double?;

        if (lat == null || lng == null) return false;

        final distance = _calculateDistance(latitude, longitude, lat, lng);
        return distance <= maxDistance;
      }).toList();

      return {
        'success': true,
        'data': nearby,
      };
    }

    return response;
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
