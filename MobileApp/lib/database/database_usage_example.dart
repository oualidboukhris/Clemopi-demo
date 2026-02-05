import 'package:flutter/material.dart';
import '../database/cache_service.dart';
import '../database/user_local_storage.dart';
import '../database/scooter_local_storage.dart';

/// Example: How to use the local database in your app
class DatabaseUsageExample {
  final CacheService _cacheService = CacheService();
  final UserLocalStorage _userStorage = UserLocalStorage();
  final ScooterLocalStorage _scooterStorage = ScooterLocalStorage();

  // Example 1: Using Cache Service
  Future<void> exampleCacheUsage() async {
    // Save data with expiration
    await _cacheService.saveCache(
      'user_settings',
      {'theme': 'dark', 'language': 'en'},
      expiresIn: Duration(hours: 24),
    );

    // Retrieve cached data
    final settings = await _cacheService.getCache('user_settings');
    print('Settings: $settings');

    // Check if cache exists
    bool hasCache = await _cacheService.hasValidCache('user_settings');
    print('Has valid cache: $hasCache');

    // Clear specific cache
    await _cacheService.deleteCache('user_settings');

    // Clear all expired cache
    await _cacheService.clearExpiredCache();
  }

  // Example 2: Using User Local Storage
  Future<void> exampleUserStorage() async {
    // Save user data
    await _userStorage.saveUser(
      userId: 'user123',
      name: 'John Doe',
      email: 'john@example.com',
      phone: '+1234567890',
      additionalData: {
        'preferences': {'notifications': true},
        'subscription': 'premium',
      },
    );

    // Get user data
    final user = await _userStorage.getUser('user123');
    print('User: $user');

    // Update user
    await _userStorage.updateUser(
      'user123',
      {'name': 'John Updated'},
    );

    // Get all users
    final allUsers = await _userStorage.getAllUsers();
    print('All users: $allUsers');

    // Delete user
    await _userStorage.deleteUser('user123');
  }

  // Example 3: Using Scooter Local Storage
  Future<void> exampleScooterStorage() async {
    // Save scooter data
    await _scooterStorage.saveScooter(
      scooterId: 'scooter001',
      batteryLevel: 85,
      latitude: 33.5731,
      longitude: -7.5898,
      status: 'available',
    );

    // Get specific scooter
    final scooter = await _scooterStorage.getScooter('scooter001');
    print('Scooter: $scooter');

    // Get all scooters
    final allScooters = await _scooterStorage.getAllScooters();
    print('All scooters: $allScooters');

    // Get nearby scooters
    final nearbyScooters = await _scooterStorage.getNearbyScooters(
      latitude: 33.5731,
      longitude: -7.5898,
      range: 0.01,
    );
    print('Nearby scooters: $nearbyScooters');

    // Get scooters by status
    final availableScooters =
        await _scooterStorage.getScootersByStatus('available');
    print('Available scooters: $availableScooters');

    // Update scooter
    await _scooterStorage.updateScooter(
      'scooter001',
      {'battery_level': 75, 'status': 'in_use'},
    );

    // Batch sync from server
    await _scooterStorage.syncScooters([
      {
        'scooter_id': 'scooter002',
        'battery_level': 90,
        'latitude': 33.5732,
        'longitude': -7.5899,
        'status': 'available',
      },
      {
        'scooter_id': 'scooter003',
        'battery_level': 65,
        'latitude': 33.5733,
        'longitude': -7.5897,
        'status': 'charging',
      },
    ]);
  }

  // Example 4: Offline-First Pattern
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    // Try to get from cache first
    final cached = await _cacheService.getCache('user_$userId');
    if (cached != null) {
      print('Returning cached user data');
      return cached;
    }

    // If not in cache, fetch from Firebase/API
    print('Fetching from server...');
    // final userData = await fetchFromFirebase(userId);

    // Save to cache for next time (expires in 1 hour)
    // await _cacheService.saveCache(
    //   'user_$userId',
    //   userData,
    //   expiresIn: Duration(hours: 1),
    // );

    // return userData;
    return null;
  }

  // Example 5: Using in a Widget
  Widget exampleWidget() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userStorage.getUser('user123'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final user = snapshot.data;
        if (user == null) {
          return Text('No user found');
        }

        return Column(
          children: [
            Text('Name: ${user['name']}'),
            Text('Email: ${user['email']}'),
            Text('Phone: ${user['phone']}'),
          ],
        );
      },
    );
  }
}
