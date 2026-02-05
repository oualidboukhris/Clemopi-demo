import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/scooter_service.dart';
import '../services/client_service.dart';
import '../services/dashboard_service.dart';

/// Example: How to use the API services to connect to your MySQL database
class ApiUsageExample {
  final AuthService _authService = AuthService();
  final ScooterService _scooterService = ScooterService();
  // ignore: unused_field
  final ClientService _clientService = ClientService();
  final DashboardService _dashboardService = DashboardService();

  // Example 1: Login
  Future<void> exampleLogin() async {
    final response = await _authService.login(
      email: 'user@example.com',
      password: 'password123',
    );

    if (response['success']) {
      print('Login successful!');
      print('User data: ${response['data']}');
      // Token is automatically saved
    } else {
      print('Login failed: ${response['error']}');
    }
  }

  // Example 2: Register
  Future<void> exampleRegister() async {
    final response = await _authService.register(
      email: 'newuser@example.com',
      password: 'password123',
      name: 'John Doe',
      phone: '+1234567890',
    );

    if (response['success']) {
      print('Registration successful!');
    } else {
      print('Registration failed: ${response['error']}');
    }
  }

  // Example 3: Get all scooters
  Future<void> exampleGetScooters() async {
    final response = await _scooterService.getAllScooters();

    if (response['success']) {
      final scooters = response['data'] as List;
      print('Found ${scooters.length} scooters');

      for (var scooter in scooters) {
        print('Scooter ${scooter['id']}: ${scooter['battery_level']}% battery');
      }
    } else {
      print('Failed to get scooters: ${response['error']}');
    }
  }

  // Example 4: Get nearby scooters
  Future<void> exampleGetNearbyScooters() async {
    final response = await _scooterService.getNearbyScooters(
      latitude: 33.5731,
      longitude: -7.5898,
      maxDistance: 2.0, // 2km radius
    );

    if (response['success']) {
      final scooters = response['data'] as List;
      print('Found ${scooters.length} nearby scooters');
    }
  }

  // Example 5: Update scooter key state
  Future<void> exampleUpdateKeyState(String scooterId, bool unlock) async {
    final response = await _scooterService.updateKeyState(
      scooterId: scooterId,
      keyState: unlock,
    );

    if (response['success']) {
      print('Key state updated: ${unlock ? "Unlocked" : "Locked"}');
    }
  }

  // Example 6: Get dashboard data
  Future<void> exampleGetDashboard() async {
    final response = await _dashboardService.getDashboardData();

    if (response['success']) {
      print('Dashboard data: ${response['data']}');
    }
  }

  // Example 7: Using in a Widget with error handling
  Widget exampleScooterListWidget() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _scooterService.getAllScooters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final response = snapshot.data;
        if (response == null || !response['success']) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  response?['error'] ?? 'Failed to load scooters',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry logic
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final scooters = response['data'] as List;

        if (scooters.isEmpty) {
          return Center(
            child: Text('No scooters available'),
          );
        }

        return ListView.builder(
          itemCount: scooters.length,
          itemBuilder: (context, index) {
            final scooter = scooters[index];
            return ListTile(
              leading: Icon(Icons.electric_scooter),
              title: Text('Scooter ${scooter['id']}'),
              subtitle: Text(
                'Battery: ${scooter['battery_level']}% - ${scooter['status']}',
              ),
              trailing: scooter['status'] == 'available'
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.cancel, color: Colors.red),
            );
          },
        );
      },
    );
  }

  // Example 8: Offline-first pattern with SQLite cache
  Future<List<dynamic>> getScootersWithCache() async {
    // Try to get from API
    try {
      final response = await _scooterService.getAllScooters();

      if (response['success']) {
        final scooters = response['data'] as List;

        // Save to SQLite for offline use
        // await _scooterStorage.syncScooters(scooters);

        return scooters;
      }
    } catch (e) {
      print('API error, falling back to cache: $e');
    }

    // If API fails, get from SQLite cache
    // return await _scooterStorage.getAllScooters();
    return [];
  }

  // Example 9: Login page with API integration
  Widget exampleLoginPage() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(title: Text('Login')),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 24),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() => isLoading = true);

                          final response = await _authService.login(
                            email: emailController.text,
                            password: passwordController.text,
                          );

                          setState(() => isLoading = false);

                          if (response['success']) {
                            // Navigate to home page
                            Navigator.pushReplacementNamed(context, '/home');
                          } else {
                            // Show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['error']),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text('Login'),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Example 10: Check authentication on app start
  Future<bool> checkAuthAndNavigate(BuildContext context) async {
    final isAuth = await _authService.isAuthenticated();

    if (isAuth) {
      // User is logged in
      Navigator.pushReplacementNamed(context, '/home');
      return true;
    } else {
      // User needs to login
      Navigator.pushReplacementNamed(context, '/login');
      return false;
    }
  }
}
