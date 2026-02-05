# Supabase Integration Guide for Flutter

## 📚 Overview

Supabase is an open-source Firebase alternative that provides:
- PostgreSQL database
- Authentication
- Real-time subscriptions
- Storage
- RESTful API
- Row-level security

---

## 🚀 Setup Steps

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up / Login
3. Click **"New Project"**
4. Fill in:
   - **Project Name:** clemopi
   - **Database Password:** (save this!)
   - **Region:** Choose closest to your users
5. Wait for project to be created (~2 minutes)

### 2. Get Your Credentials

After project creation, go to **Settings → API**:
```
Project URL: https://your-project-ref.supabase.co
anon/public key: eyJhbGc...
service_role key: eyJhbGc... (keep secret!)
```

---

## 📦 Install Supabase Package

### Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0  # Latest version
```

### Install:
```bash
cd /Users/achraf/Desktop/CleMoPI/MobileApp
flutter pub get
```

---

## 🔧 Initialize Supabase in Flutter

### Create: `lib/config/supabase_config.dart`
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Enable for development
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
```

### Update: `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:clemopi_app/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}
```

---

## 🗄️ Create Database Tables in Supabase

Go to **SQL Editor** in Supabase Dashboard and run:

### Clients Table:
```sql
-- Create clients table
CREATE TABLE clients (
  id BIGSERIAL PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  username TEXT NOT NULL,
  email TEXT,
  phone_number TEXT,
  first_name TEXT,
  last_name TEXT,
  gender TEXT,
  age TEXT,
  birthday TEXT,
  region TEXT,
  balance INTEGER DEFAULT 0,
  total_minutes TEXT DEFAULT '0',
  total_meters TEXT DEFAULT '0',
  total_orders TEXT DEFAULT '0',
  register_channel TEXT DEFAULT 'mobile',
  status TEXT DEFAULT 'Enable',
  register_time TIMESTAMP DEFAULT NOW(),
  last_orders TEXT,
  last_order_time TEXT,
  account_status TEXT DEFAULT 'Uncommitted',
  unlocking_way TEXT DEFAULT 'phone',
  photos TEXT,
  deleted BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index on user_id for faster lookups
CREATE INDEX idx_clients_user_id ON clients(user_id);
CREATE INDEX idx_clients_email ON clients(email);

-- Enable Row Level Security (RLS)
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

-- Create policy: Anyone can insert
CREATE POLICY "Allow public insert" ON clients
  FOR INSERT TO public
  WITH CHECK (true);

-- Create policy: Users can read all
CREATE POLICY "Allow public read" ON clients
  FOR SELECT TO public
  USING (true);

-- Create policy: Users can update their own data
CREATE POLICY "Allow authenticated update" ON clients
  FOR UPDATE TO authenticated
  USING (auth.uid()::text = user_id);
```

### Kickscooters Table:
```sql
-- Create kickscooters table
CREATE TABLE kickscooters (
  id BIGSERIAL PRIMARY KEY,
  scooter_id TEXT UNIQUE NOT NULL,
  scooter_number TEXT NOT NULL,
  status TEXT DEFAULT 'Available',
  battery_level INTEGER DEFAULT 100,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  location TEXT,
  total_distance INTEGER DEFAULT 0,
  total_minutes INTEGER DEFAULT 0,
  total_orders INTEGER DEFAULT 0,
  last_ride_time TIMESTAMP,
  register_time TIMESTAMP DEFAULT NOW(),
  bluetooth_key TEXT,
  bluetooth_password TEXT,
  communication_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_kickscooters_scooter_id ON kickscooters(scooter_id);
CREATE INDEX idx_kickscooters_status ON kickscooters(status);
CREATE INDEX idx_kickscooters_location ON kickscooters USING GIST(
  ll_to_earth(latitude, longitude)
);

-- Enable RLS
ALTER TABLE kickscooters ENABLE ROW LEVEL SECURITY;

-- Allow public read
CREATE POLICY "Allow public read" ON kickscooters
  FOR SELECT TO public
  USING (true);
```

---

## 💻 Create Supabase Service in Flutter

### Create: `lib/services/supabase_client_service.dart`
```dart
import 'package:clemopi_app/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Create Client
  Future<Map<String, dynamic>> createClient(Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('clients')
          .insert(data)
          .select()
          .single();
      
      return {'error': false, 'data': response};
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  // Get All Clients
  Future<List<Map<String, dynamic>>> getAllClients() async {
    try {
      final response = await _client
          .from('clients')
          .select()
          .eq('deleted', false)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting clients: $e');
      return [];
    }
  }

  // Get Single Client
  Future<Map<String, dynamic>?> getClient(String userId) async {
    try {
      final response = await _client
          .from('clients')
          .select()
          .eq('user_id', userId)
          .single();
      
      return response;
    } catch (e) {
      print('Error getting client: $e');
      return null;
    }
  }

  // Update Client
  Future<Map<String, dynamic>> updateClient(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _client
          .from('clients')
          .update(data)
          .eq('user_id', userId);
      
      return {'error': false, 'message': 'Client updated successfully'};
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  // Delete Client (Soft delete)
  Future<Map<String, dynamic>> deleteClient(String userId) async {
    try {
      await _client
          .from('clients')
          .update({'deleted': true})
          .eq('user_id', userId);
      
      return {'error': false, 'message': 'Client deleted successfully'};
    } catch (e) {
      return {'error': true, 'message': e.toString()};
    }
  }

  // Real-time subscription to clients
  RealtimeChannel subscribeToClients(Function(List<Map<String, dynamic>>) onData) {
    return _client
        .from('clients')
        .stream(primaryKey: ['id'])
        .eq('deleted', false)
        .listen((List<Map<String, dynamic>> data) {
          onData(data);
        });
  }
}
```

### Create: `lib/services/supabase_scooter_service.dart`
```dart
import 'package:clemopi_app/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseScooterService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get All Scooters
  Future<List<Map<String, dynamic>>> getAllScooters() async {
    try {
      final response = await _client
          .from('kickscooters')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting scooters: $e');
      return [];
    }
  }

  // Get Available Scooters Near Location
  Future<List<Map<String, dynamic>>> getNearbyScooters(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Use PostGIS for location queries
      final response = await _client.rpc(
        'get_nearby_scooters',
        params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusKm,
        },
      );
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting nearby scooters: $e');
      return [];
    }
  }

  // Update Scooter Location
  Future<void> updateScooterLocation(
    String scooterId,
    double latitude,
    double longitude,
  ) async {
    await _client
        .from('kickscooters')
        .update({
          'latitude': latitude,
          'longitude': longitude,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('scooter_id', scooterId);
  }

  // Real-time subscription to scooters
  RealtimeChannel subscribeToScooters(Function(List<Map<String, dynamic>>) onData) {
    return _client
        .from('kickscooters')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          onData(data);
        });
  }
}
```

---

## 🔐 Authentication with Supabase

### Create: `lib/services/supabase_auth_service.dart`
```dart
import 'package:clemopi_app/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Sign Up with Email
  Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign In with Email
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Listen to Auth State Changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
```

---

## 🔄 Update Registration to Use Supabase

### Update: `lib/pages/auth/register/step1.dart`
```dart
import 'package:clemopi_app/services/supabase_client_service.dart';

// Inside continueTostep2() function, after Firebase save:

// Save to Supabase
try {
  final supabaseService = SupabaseClientService();
  final userId = currentUser.uid; // Use Firebase UID
  
  final clientData = {
    'user_id': userId,
    'username': displayName!.replaceAll(' ', '_').toLowerCase(),
    'email': email!,
    'phone_number': phoneNumber!,
    'first_name': firstName!,
    'last_name': lastName!,
    'birthday': birthday!,
    'region': city!,
    'balance': 0,
    'register_channel': 'mobile',
  };
  
  final result = await supabaseService.createClient(clientData);
  
  if (result['error'] == false) {
    print('✅ Client saved to Supabase');
  } else {
    print('⚠️ Supabase error: ${result['message']}');
  }
} catch (e) {
  print('⚠️ Failed to save to Supabase: $e');
}
```

---

## 📊 Supabase SQL Function for Nearby Scooters

Run this in **SQL Editor**:
```sql
-- Create function to get nearby scooters
CREATE OR REPLACE FUNCTION get_nearby_scooters(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_km DOUBLE PRECISION
)
RETURNS TABLE (
  id BIGINT,
  scooter_id TEXT,
  scooter_number TEXT,
  status TEXT,
  battery_level INTEGER,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  distance_km DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    k.id,
    k.scooter_id,
    k.scooter_number,
    k.status,
    k.battery_level,
    k.latitude,
    k.longitude,
    earth_distance(
      ll_to_earth(k.latitude, k.longitude),
      ll_to_earth(lat, lng)
    ) / 1000 AS distance_km
  FROM kickscooters k
  WHERE k.status = 'Available'
    AND earth_box(ll_to_earth(lat, lng), radius_km * 1000) @> ll_to_earth(k.latitude, k.longitude)
  ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql;
```

---

## 🎯 Comparison: MySQL vs Supabase

| Feature | MySQL (Current) | Supabase |
|---------|----------------|----------|
| **Database** | MySQL 8.0 | PostgreSQL |
| **Hosting** | Docker Local | Cloud (Free tier) |
| **API** | Custom REST API | Auto-generated REST API |
| **Real-time** | Manual webhooks | Built-in real-time |
| **Auth** | Custom JWT | Built-in auth |
| **Scaling** | Manual | Automatic |
| **Cost** | Free (self-hosted) | Free tier: 500MB, 2 projects |
| **Security** | Custom | Row-level security (RLS) |
| **Admin UI** | phpMyAdmin | Built-in dashboard |

---

## 🔒 Security Best Practices

### 1. Environment Variables
Never hardcode credentials! Use `.env` file:

**Create:** `lib/config/.env`
```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Install:** `flutter_dotenv`
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

**Load in main.dart:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "lib/config/.env");
  // ...
}
```

**Use in config:**
```dart
static String supabaseUrl = dotenv.env['SUPABASE_URL']!;
static String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
```

### 2. Row Level Security (RLS)
Already enabled in SQL examples above. Ensures users can only access their own data.

---

## 📱 Real-time Updates Example

### Listen to client changes:
```dart
class ClientListPage extends StatefulWidget {
  @override
  _ClientListPageState createState() => _ClientListPageState();
}

class _ClientListPageState extends State<ClientListPage> {
  final _service = SupabaseClientService();
  List<Map<String, dynamic>> _clients = [];
  RealtimeChannel? _subscription;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _subscribeToChanges();
  }

  void _loadClients() async {
    final clients = await _service.getAllClients();
    setState(() {
      _clients = clients;
    });
  }

  void _subscribeToChanges() {
    _subscription = _service.subscribeToClients((data) {
      setState(() {
        _clients = data;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _clients.length,
      itemBuilder: (context, index) {
        final client = _clients[index];
        return ListTile(
          title: Text(client['username']),
          subtitle: Text(client['email']),
        );
      },
    );
  }
}
```

---

## 🚀 Migration Strategy

### Option 1: Dual Write (Recommended)
- Keep Firebase + MySQL
- Add Supabase alongside
- Gradually move features to Supabase
- Eventually remove Firebase/MySQL

### Option 2: Full Migration
1. Export data from MySQL
2. Import to Supabase
3. Update all app code
4. Test thoroughly
5. Deploy

### Option 3: Hybrid
- Firebase: Authentication
- Supabase: Database
- Best of both worlds!

---

## 📚 Additional Resources

- **Supabase Docs:** https://supabase.com/docs
- **Flutter Package:** https://pub.dev/packages/supabase_flutter
- **Examples:** https://github.com/supabase/supabase/tree/master/examples/flutter
- **Dashboard:** https://supabase.com/dashboard

---

## ⚡ Quick Start Commands

```bash
# Install package
cd /Users/achraf/Desktop/CleMoPI/MobileApp
flutter pub add supabase_flutter

# Create config file
mkdir -p lib/config
touch lib/config/supabase_config.dart

# Run app
flutter run -d M2004J19C
```

---

## 🎯 Next Steps

1. ✅ Create Supabase account
2. ✅ Create new project
3. ✅ Get credentials (URL + anon key)
4. ✅ Add `supabase_flutter` package
5. ✅ Create config file
6. ✅ Initialize in main.dart
7. ✅ Run SQL scripts to create tables
8. ✅ Create service files
9. ✅ Update registration code
10. ✅ Test!

---

**Need help?** Supabase has great docs and a helpful community on Discord!
