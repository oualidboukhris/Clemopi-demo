# MySQL Direct Access Configuration for Mobile Development

## ✅ Setup Complete!

Your MySQL database is now accessible from your mobile device on the same network.

## 📱 Connection Details

- **Host:** `10.24.84.32` (your Mac's IP)
- **Port:** `3306`
- **Database:** `clemopi_db`
- **Username:** `mobile_user`
- **Password:** `mobile_password_2024`

## 🔧 Configuration Files

### 1. Flutter App Configuration
The database configuration is in: `MobileApp/lib/services/database_config.dart`

```dart
DatabaseConfig.host = '10.24.84.32';
DatabaseConfig.port = 3306;
DatabaseConfig.database = 'clemopi_db';
```

### 2. API Backend Configuration (Already Working)
Your backend API is still accessible at:
- **URL:** `http://10.24.84.32:4000/api/v1`

## 📝 How to Use

### Option 1: Use REST API (Recommended for Production)
Continue using the API services created earlier:
```dart
import 'package:clemopi_um6p/services/api_service.dart';
import 'package:clemopi_um6p/services/scooter_service.dart';

// All your API calls work through the backend
final scooters = await ScooterService().getAllScooters();
```

### Option 2: Direct MySQL Connection (Development Only)
If you want to connect directly to MySQL from Flutter, you'll need to add a MySQL package:

```yaml
dependencies:
  mysql1: ^0.20.0  # Add this to pubspec.yaml
```

Then use it:
```dart
import 'package:mysql1/mysql1.dart';
import 'package:clemopi_um6p/services/database_config.dart';

Future<void> connectToDatabase() async {
  final conn = await MySqlConnection.connect(ConnectionSettings(
    host: DatabaseConfig.host,
    port: DatabaseConfig.port,
    user: DatabaseConfig.username,
    password: DatabaseConfig.password,
    db: DatabaseConfig.database,
  ));
  
  var results = await conn.query('SELECT * FROM kickscooters');
  print('Results: $results');
  
  await conn.close();
}
```

## 🔐 Security Notes

⚠️ **Important:** This configuration is for DEVELOPMENT ONLY!

- The `mobile_user` account is configured to accept connections from any IP (`%`)
- This is NOT secure for production use
- For production, always use:
  1. The REST API (already configured at port 4000)
  2. SSL/TLS encryption
  3. Proper authentication tokens
  4. Restricted user permissions

## 🧪 Testing the Connection

### Test 1: From Your Phone Terminal (if you have Termux)
```bash
mysql -h 10.24.84.32 -P 3306 -u mobile_user -pmobile_password_2024 clemopi_db
```

### Test 2: From Your Mac
```bash
docker exec clemopi_mysql mysql -u mobile_user -pmobile_password_2024 -e "SHOW DATABASES;"
```

### Test 3: From Flutter App
Use the REST API test page already created:
- Navigate to the Database Test Page in your app
- Click "Test MySQL Connection"
- It will fetch data through the backend API

## 🔄 If Your IP Changes

Your Mac's IP might change when you reconnect to the network. To update:

1. **Get new IP:**
   ```bash
   ipconfig getifaddr en0
   ```

2. **Update Flutter API config:**
   Edit `MobileApp/lib/services/api_config.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_NEW_IP:4000/api/v1';
   ```

3. **Update database config (if using direct connection):**
   Edit `MobileApp/lib/services/database_config.dart`:
   ```dart
   static const String host = 'YOUR_NEW_IP';
   ```

## 🐳 Docker Commands

### Check MySQL container status:
```bash
docker ps --filter "name=clemopi_mysql"
```

### View MySQL logs:
```bash
docker logs clemopi_mysql
```

### Restart MySQL container:
```bash
docker restart clemopi_mysql
```

### Connect to MySQL from Mac:
```bash
docker exec -it clemopi_mysql mysql -u mobile_user -pmobile_password_2024 clemopi_db
```

## 📊 Database Information

### Existing Tables
- `users` - User accounts and authentication
- `kickscooters` - Scooter locations and status
- `clients` - Client information
- `header_dashboard` - Dashboard header data
- `analytics_dashboard` - Analytics data

### Check Tables:
```sql
SHOW TABLES;
DESCRIBE kickscooters;
SELECT COUNT(*) FROM kickscooters;
```

## 🚀 Recommended Approach

For your mobile app development, I recommend:

1. ✅ **Keep using the REST API** (port 4000)
   - Already secured with token authentication
   - Backend handles all business logic
   - Cleaner separation of concerns
   - Works the same in production

2. ✅ **Use SQLite for offline caching**
   - Already configured in your app
   - Works without network
   - Automatic sync with backend

3. ❌ **Avoid direct MySQL connection from mobile**
   - Security risks
   - No business logic layer
   - Harder to maintain
   - Won't work in production

## 📱 Current Mobile App Architecture

```
┌─────────────────┐
│  Flutter App    │
│  (Your Phone)   │
└────────┬────────┘
         │ HTTP Requests (port 4000)
         │ Token Authentication
         ↓
┌─────────────────┐
│  Backend API    │
│  (Node.js)      │
│  10.24.84.32    │
└────────┬────────┘
         │ SQL Queries (port 3306)
         ↓
┌─────────────────┐
│  MySQL DB       │
│  (Docker)       │
└─────────────────┘
```

This architecture is already working perfectly! 🎉
