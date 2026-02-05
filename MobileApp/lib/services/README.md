# MySQL Database API Integration for CleMoPI

This Flutter app connects to your MySQL database through the backend API server running in Docker.

## 🚀 Setup

### 1. Backend Server Configuration

Your backend is already running on Docker:

```
Backend: http://localhost:4000
MySQL: localhost:3306
```

### 2. Update API Base URL

Open `lib/services/api_config.dart` and update the base URL with your computer's IP address:

```dart
static const String baseUrl = 'http://YOUR_IP:4000/api/v1';
```

**Find your IP address:**

- **macOS/Linux**: `ipconfig getifaddr en0`
- **Windows**: `ipconfig` (look for IPv4 Address)

**Important Notes:**

- ✅ Use your computer's IP (e.g., `http://10.53.84.51:4000`) for physical devices
- ✅ Use `http://10.0.2.2:4000` for Android emulator (special address for host)
- ❌ Don't use `localhost` or `127.0.0.1` on physical devices
- ❌ Make sure your device and computer are on the same WiFi network

### 3. Install Dependencies

```bash
cd MobileApp
flutter pub get
```

## 📦 Packages Used

- `http: ^1.2.2` - HTTP client for API calls
- `shared_preferences: ^2.3.3` - Store authentication tokens locally
- `sqflite: ^2.3.3+2` - SQLite for offline caching (optional)
- `path_provider: ^2.1.5` - File system paths

## 🔧 Available Services

### 1. AuthService

Handles user authentication:

```dart
import 'package:clemopi_app/services/auth_service.dart';

final authService = AuthService();

// Login
final response = await authService.login(
  email: 'user@example.com',
  password: 'password123',
);

if (response['success']) {
  print('Logged in! Token saved automatically.');
  final userData = response['data'];
}

// Register
await authService.register(
  email: 'new@example.com',
  password: 'password123',
  name: 'John Doe',
  phone: '+1234567890',
);

// Get user data
await authService.getUserData('userId');

// Update user
await authService.updateUserData('userId', {'name': 'Updated Name'});

// Upload profile image
await authService.uploadImage('userId', '/path/to/image.jpg');

// Logout
await authService.logout();

// Check if authenticated
bool isAuth = await authService.isAuthenticated();
```

### 2. ScooterService

Manage kickscooters:

```dart
import 'package:clemopi_app/services/scooter_service.dart';

final scooterService = ScooterService();

// Get all scooters
final response = await scooterService.getAllScooters();
if (response['success']) {
  List scooters = response['data'];
}

// Get single scooter
await scooterService.getScooter('scooter123');

// Update scooter
await scooterService.updateScooter({
  'id': 'scooter123',
  'battery_level': 85,
  'status': 'available',
});

// Lock/Unlock scooter
await scooterService.updateKeyState(
  scooterId: 'scooter123',
  keyState: true, // true = unlock, false = lock
);

// Get available scooters only
await scooterService.getAvailableScooters();

// Get nearby scooters (within 2km)
await scooterService.getNearbyScooters(
  latitude: 33.5731,
  longitude: -7.5898,
  maxDistance: 2.0,
);
```

### 3. ClientService

Manage clients:

```dart
import 'package:clemopi_app/services/client_service.dart';

final clientService = ClientService();

// Get all clients
await clientService.getAllClients();

// Get single client
await clientService.getClient('client123');

// Create client
await clientService.createClient({
  'name': 'Client Name',
  'email': 'client@example.com',
  'phone': '+1234567890',
});

// Update client
await clientService.updateClient('client123', {
  'name': 'Updated Name',
});

// Delete client
await clientService.deleteClient('client123');
```

### 4. DashboardService

Get dashboard statistics:

```dart
import 'package:clemopi_app/services/dashboard_service.dart';

final dashboardService = DashboardService();

// Get all dashboard data
final response = await dashboardService.getDashboardData();

// Get analytics only
await dashboardService.getAnalytics();

// Get header data only
await dashboardService.getHeaderData();
```

## 🎯 Usage in Widgets

### Example 1: Display Scooter List

```dart
class ScooterListPage extends StatelessWidget {
  final ScooterService _scooterService = ScooterService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scooters')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _scooterService.getAllScooters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!['success']) {
            return Center(
              child: Text('Error: ${snapshot.data?['error'] ?? 'Unknown error'}'),
            );
          }

          final scooters = snapshot.data!['data'] as List;

          return ListView.builder(
            itemCount: scooters.length,
            itemBuilder: (context, index) {
              final scooter = scooters[index];
              return ListTile(
                leading: Icon(Icons.electric_scooter),
                title: Text('Scooter ${scooter['id']}'),
                subtitle: Text('Battery: ${scooter['battery_level']}%'),
                trailing: Chip(
                  label: Text(scooter['status']),
                  backgroundColor: scooter['status'] == 'available'
                      ? Colors.green
                      : Colors.orange,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Example 2: Login Form

```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    final response = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (response['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['error']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

## 🔐 Authentication Flow

1. **Login** → Token is automatically saved to `SharedPreferences`
2. **API Calls** → Token is automatically included in headers
3. **Logout** → Token is cleared from storage
4. **Check Auth** → Use `await authService.isAuthenticated()`

## 🌐 API Endpoints

All endpoints are defined in `lib/services/api_config.dart`:

```
POST   /api/v1/login
POST   /api/v1/register
POST   /api/v1/logout
GET    /api/v1/users/:userId
PUT    /api/v1/users/:userId
POST   /api/v1/upload/:userId
GET    /api/v1/kickscooters
GET    /api/v1/kickscooter/:id
PUT    /api/v1/kickscooters
PUT    /api/v1/kickscooter/key-state
GET    /api/v1/clients
GET    /api/v1/clients/:id
POST   /api/v1/clients
PUT    /api/v1/clients/:id
DELETE /api/v1/clients/:id
GET    /api/v1/dashboard
```

## 📱 Response Format

All API responses follow this structure:

```dart
{
  'success': true/false,
  'data': {...}, // on success
  'error': 'Error message', // on failure
  'statusCode': 200
}
```

## 🔄 Offline Support (Optional)

Combine API calls with SQLite caching:

```dart
Future<List> getScootersWithCache() async {
  try {
    // Try API first
    final response = await scooterService.getAllScooters();
    if (response['success']) {
      final scooters = response['data'];
      // Save to SQLite
      await scooterStorage.syncScooters(scooters);
      return scooters;
    }
  } catch (e) {
    print('API failed, using cache');
  }

  // Fall back to cache
  return await scooterStorage.getAllScooters();
}
```

## 🐛 Debugging

### Check Backend Connection

```bash
# Test from terminal
curl http://YOUR_IP:4000/api/v1/kickscooters
```

### Common Issues

1. **Connection refused**

   - Check if backend is running: `docker ps`
   - Verify IP address in `api_config.dart`
   - Ensure device and computer are on same WiFi

2. **Timeout errors**

   - Increase timeout in `api_config.dart`
   - Check firewall settings

3. **401 Unauthorized**

   - Token expired or invalid
   - Call `logout()` and login again

4. **CORS errors** (if using web)
   - Backend already configured to allow requests

## 📚 Additional Resources

- See `lib/services/api_usage_example.dart` for more examples
- Backend API: `http://YOUR_IP:4000/api/v1`
- MySQL database: Uses the same database as your web frontend
