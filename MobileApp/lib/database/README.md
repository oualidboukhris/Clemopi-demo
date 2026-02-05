# Local Database Setup for CleMoPI

This app now includes SQLite local database support for offline data storage and caching.

## 📦 Packages Added

- `sqflite: ^2.3.3+2` - SQLite database for Flutter
- `path_provider: ^2.1.5` - Access to common file system locations
- `path: ^1.9.0` - Path manipulation utilities

## 🗄️ Database Structure

The database includes three main tables:

### 1. Cache Table

Stores temporary cached data with optional expiration.

```sql
- id: INTEGER PRIMARY KEY
- key: TEXT (unique cache key)
- value: TEXT (JSON encoded data)
- created_at: INTEGER (timestamp)
- expires_at: INTEGER (expiration timestamp, nullable)
```

### 2. User Data Table

Stores user information locally.

```sql
- id: INTEGER PRIMARY KEY
- user_id: TEXT (unique user identifier)
- name: TEXT
- email: TEXT
- phone: TEXT
- data: TEXT (JSON encoded additional data)
- last_updated: INTEGER (timestamp)
```

### 3. Scooter Cache Table

Stores scooter information for offline access.

```sql
- id: INTEGER PRIMARY KEY
- scooter_id: TEXT (unique scooter identifier)
- battery_level: INTEGER
- latitude: REAL
- longitude: REAL
- status: TEXT
- last_synced: INTEGER (timestamp)
```

## 🚀 Quick Start

### 1. Import the services you need:

```dart
import 'package:clemopi_app/database/cache_service.dart';
import 'package:clemopi_app/database/user_local_storage.dart';
import 'package:clemopi_app/database/scooter_local_storage.dart';
```

### 2. Initialize services:

```dart
final CacheService cacheService = CacheService();
final UserLocalStorage userStorage = UserLocalStorage();
final ScooterLocalStorage scooterStorage = ScooterLocalStorage();
```

## 💡 Usage Examples

### Cache Service

#### Save data with expiration:

```dart
// Save for 24 hours
await cacheService.saveCache(
  'user_settings',
  {'theme': 'dark', 'language': 'en'},
  expiresIn: Duration(hours: 24),
);

// Save permanently (no expiration)
await cacheService.saveCache(
  'app_config',
  {'version': '1.0.0'},
);
```

#### Retrieve cached data:

```dart
final settings = await cacheService.getCache('user_settings');
if (settings != null) {
  print('Theme: ${settings['theme']}');
}
```

#### Check if cache exists and is valid:

```dart
bool hasCache = await cacheService.hasValidCache('user_settings');
```

#### Clear cache:

```dart
// Clear specific cache
await cacheService.deleteCache('user_settings');

// Clear all expired cache
await cacheService.clearExpiredCache();

// Clear all cache
await cacheService.clearAllCache();
```

### User Local Storage

#### Save user:

```dart
await userStorage.saveUser(
  userId: 'user123',
  name: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  additionalData: {
    'preferences': {'notifications': true},
    'subscription': 'premium',
  },
);
```

#### Get user:

```dart
final user = await userStorage.getUser('user123');
if (user != null) {
  print('Name: ${user['name']}');
  print('Email: ${user['email']}');
}
```

#### Update user:

```dart
await userStorage.updateUser(
  'user123',
  {'name': 'John Updated', 'phone': '+9876543210'},
);
```

### Scooter Local Storage

#### Save scooter:

```dart
await scooterStorage.saveScooter(
  scooterId: 'scooter001',
  batteryLevel: 85,
  latitude: 33.5731,
  longitude: -7.5898,
  status: 'available',
);
```

#### Get nearby scooters:

```dart
final nearbyScooters = await scooterStorage.getNearbyScooters(
  latitude: 33.5731,
  longitude: -7.5898,
  range: 0.01, // ~1km
);
```

#### Get scooters by status:

```dart
final availableScooters = await scooterStorage.getScootersByStatus('available');
```

#### Batch sync from server:

```dart
await scooterStorage.syncScooters([
  {
    'scooter_id': 'scooter002',
    'battery_level': 90,
    'latitude': 33.5732,
    'longitude': -7.5899,
    'status': 'available',
  },
  // ... more scooters
]);
```

## 🔄 Offline-First Pattern

Use this pattern to provide seamless offline experience:

```dart
Future<Map<String, dynamic>?> getScooterData(String scooterId) async {
  // 1. Try cache first
  final cached = await cacheService.getCache('scooter_$scooterId');
  if (cached != null) {
    return cached;
  }

  // 2. If not cached, fetch from Firebase
  try {
    final data = await fetchFromFirebase(scooterId);

    // 3. Save to cache for next time
    await cacheService.saveCache(
      'scooter_$scooterId',
      data,
      expiresIn: Duration(minutes: 30),
    );

    return data;
  } catch (e) {
    // 4. If offline, try local database
    return await scooterStorage.getScooter(scooterId);
  }
}
```

## 🧹 Maintenance

### Clear expired cache periodically:

```dart
// Call this when app starts or periodically
await cacheService.clearExpiredCache();
```

### Database location:

The database is stored at:

- iOS: `Library/Application Support/clemopi.db`
- Android: `/data/data/com.clemopi.um6p/databases/clemopi.db`

## 📝 Adding Custom Tables

To add your own table:

1. Open `lib/database/database_helper.dart`
2. Add your table creation in the `_onCreate` method:

```dart
await db.execute('''
  CREATE TABLE your_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    field1 TEXT,
    field2 INTEGER,
    created_at INTEGER NOT NULL
  )
''');
```

3. Create a service class similar to `cache_service.dart`
4. Increment the database version number

## ⚠️ Important Notes

- The database is created on first access
- All timestamps are stored as milliseconds since epoch
- JSON data is stored as strings in TEXT fields
- Use `ConflictAlgorithm.replace` for upsert operations
- Always handle null values when retrieving data

## 🐛 Debugging

To view database contents during development:

### Android:

```bash
adb shell
cd /data/data/com.clemopi.um6p/databases
sqlite3 clemopi.db
```

### iOS:

Use a SQLite browser tool or copy the database file from the simulator.

## 📚 Additional Resources

- [sqflite documentation](https://pub.dev/packages/sqflite)
- [path_provider documentation](https://pub.dev/packages/path_provider)
- See `lib/database/database_usage_example.dart` for more examples
