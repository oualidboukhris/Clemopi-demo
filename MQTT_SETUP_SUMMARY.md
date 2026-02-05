# MQTT Integration Summary

## ✅ What Was Implemented

### 1. Backend Changes

- ✅ Installed `mqtt` npm package
- ✅ Created `/Backend/config/mqtt.js` - MQTT service module
- ✅ Updated `/Backend/controller/kickscooters.controller.js` - Added lock/unlock functions
- ✅ Updated `/Backend/routes/kickscooters.router.js` - Added API endpoints
- ✅ Updated `/Backend/bin/www.js` - Initialize MQTT connection on startup
- ✅ Updated `.env.example` - Added MQTT configuration variables

### 2. Infrastructure

- ✅ Updated `docker-compose.yml` - Added Mosquitto MQTT broker service
- ✅ Added Docker volumes for MQTT data persistence

### 3. Documentation

- ✅ Created `MQTT_INTEGRATION.md` - Complete integration guide
- ✅ Created `test_mqtt.sh` - MQTT testing script
- ✅ Created `MobileApp/MQTT_INTEGRATION_EXAMPLE.dart` - Flutter example code

## 🎯 How It Works

```
Mobile App (Scans QR: "QR198676")
         ↓
POST /api/v1/kickscooter/unlock
         ↓
Backend validates & publishes MQTT
         ↓
Topic: "scooter/QR198676/command"
Message: "unlock"
         ↓
Mosquitto Broker (localhost:1883)
         ↓
Physical Scooter Hardware (ESP32/Arduino)
         ↓
Relay activates → Lock mechanism opens
```

## 🚀 Quick Start

### 1. Install Mosquitto (macOS)

```bash
brew install mosquitto
brew services start mosquitto
```

### 2. Configure Environment

```bash
cd Backend
cp .env.example .env
# Edit .env to ensure MQTT settings are correct
```

### 3. Install Dependencies

```bash
npm install
```

### 4. Start Backend

```bash
npm start
```

Expected output:

```
Server api listening on port 4000
✅ Connected to MQTT Broker: mqtt://localhost:1883
```

## 🧪 Testing

### Test MQTT Broker

```bash
# Terminal 1: Subscribe to scooter commands
mosquitto_sub -h localhost -t "scooter/#" -v

# Terminal 2: Publish test command
mosquitto_pub -h localhost -t "scooter/QR198676/command" -m "unlock"
```

### Test API Endpoints

```bash
# Run the test script
./test_mqtt.sh
```

### Test with curl (requires authentication)

```bash
# 1. Login first
curl -X POST http://localhost:4000/api/v1/client/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}' \
  -c cookies.txt

# 2. Unlock scooter
curl -X POST http://localhost:4000/api/v1/kickscooter/unlock \
  -H "Content-Type: application/json" \
  -H "x-xsrf-token: YOUR_TOKEN" \
  -b cookies.txt \
  -d '{"qrCode":"QR198676"}'
```

## 📱 Mobile App Integration

Update your QR scan handler in Flutter:

```dart
import 'package:clemopi_app/services/scooter_service.dart';

// After scanning QR code
final result = await ScooterService.unlockScooter(
  qrCode: scannedQRCode,
  token: userToken,
  xsrfToken: xsrfToken,
);

if (result['success']) {
  // Scooter unlocked! Start ride
  print('Unlocked: ${result['message']}');
}
```

See `MobileApp/MQTT_INTEGRATION_EXAMPLE.dart` for complete example.

## 🔧 Hardware Integration

For ESP32/Arduino scooter hardware:

```cpp
// Subscribe to: scooter/QR198676/command
// On message "unlock": Activate relay/servo
// On message "lock": Deactivate relay/servo
```

See `MQTT_INTEGRATION.md` for complete Arduino example.

## 🐳 Docker Deployment

```bash
# Start all services (MySQL, Backend, Frontend, Mosquitto)
docker-compose up -d

# Check logs
docker-compose logs -f mosquitto
docker-compose logs -f backend

# Stop services
docker-compose down
```

## 📊 API Endpoints

### Unlock Scooter

```
POST /api/v1/kickscooter/unlock
Body: { "qrCode": "QR198676" }
Auth: Required (JWT token + XSRF token)
```

### Lock Scooter

```
POST /api/v1/kickscooter/lock
Body: { "qrCode": "QR198676" }
Auth: Required (JWT token + XSRF token)
```

## 🔐 Environment Variables

Add to your `.env` file:

```env
# MQTT Configuration
MQTT_HOST=localhost
MQTT_PORT=1883
MQTT_PROTOCOL=mqtt
MQTT_USERNAME=
MQTT_PASSWORD=
```

For Docker deployment, the backend will use:

```env
MQTT_HOST=mosquitto  # Container name
```

## 📝 Database

The `kickscooters` table tracks lock state:

```sql
INSERT INTO kickscooters (
  qrCode,
  lock_state,
  battery,
  coords,
  ...
) VALUES (
  'QR198676',
  'false',  -- 'false' = unlocked, 'true' = locked
  '85',
  '33.5731,-7.5898',
  ...
);
```

## 🎉 Next Steps

1. ✅ Test MQTT broker connection
2. ✅ Test API endpoints with Postman/curl
3. ⏳ Integrate unlock function in mobile app QR scan handler
4. ⏳ Deploy hardware (ESP32) with MQTT client
5. ⏳ Test end-to-end: Mobile → Backend → MQTT → Hardware
6. ⏳ Add status feedback from hardware to app
7. ⏳ Implement battery level updates via MQTT

## 🐛 Troubleshooting

**MQTT not connecting:**

- Check Mosquitto is running: `brew services list`
- Verify port 1883 is open: `lsof -i :1883`
- Check backend logs for connection errors

**API returns 401:**

- Ensure you're logged in and have valid tokens
- Check cookie and XSRF token are being sent

**Hardware not receiving messages:**

- Verify hardware is subscribed to correct topic: `scooter/{qrCode}/command`
- Test with mosquitto_sub: `mosquitto_sub -h localhost -t "scooter/#" -v`
- Check hardware network connectivity

## 📚 Documentation

- Full guide: `MQTT_INTEGRATION.md`
- Flutter example: `MobileApp/MQTT_INTEGRATION_EXAMPLE.dart`
- Test script: `test_mqtt.sh`

---

**Status:** ✅ Ready for Testing
**Last Updated:** December 30, 2025
