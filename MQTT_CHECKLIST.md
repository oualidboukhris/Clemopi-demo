# ✅ MQTT Integration Checklist

## 📦 Installation & Setup

- [x] Install MQTT client library (`npm install mqtt`)
- [x] Create MQTT configuration module (`Backend/config/mqtt.js`)
- [x] Add MQTT environment variables to `.env.example`
- [x] Update `docker-compose.yml` with Mosquitto service
- [x] Add MQTT initialization to `Backend/bin/www.js`

## 🔧 Backend Implementation

- [x] Import MQTT service in kickscooters controller
- [x] Create `lockScooter()` function
- [x] Create `unlockScooter()` function
- [x] Add lock/unlock routes to `routes/kickscooters.router.js`
- [x] Update database on lock/unlock operations
- [x] Add error handling for MQTT operations

## 📝 Documentation

- [x] Create `MQTT_INTEGRATION.md` (complete guide)
- [x] Create `MQTT_SETUP_SUMMARY.md` (quick reference)
- [x] Create `ARCHITECTURE_DIAGRAM.txt` (visual diagram)
- [x] Create `README.md` (project overview)
- [x] Create Flutter integration example
- [x] Create test script (`test_mqtt.sh`)
- [x] Create quick start script (`quick_start.sh`)

## 🧪 Testing

- [ ] Install Mosquitto broker locally

  ```bash
  brew install mosquitto  # macOS
  brew services start mosquitto
  ```

- [ ] Test MQTT connection

  ```bash
  ./test_mqtt.sh
  ```

- [ ] Test backend MQTT integration

  ```bash
  cd Backend
  npm start
  # Check for "✅ Connected to MQTT Broker" message
  ```

- [ ] Test unlock API endpoint

  ```bash
  # Subscribe to MQTT topic first
  mosquitto_sub -h localhost -t "scooter/#" -v

  # Then call API (requires authentication)
  curl -X POST http://localhost:4000/api/v1/kickscooter/unlock \
    -H "Content-Type: application/json" \
    -d '{"qrCode":"QR198676"}'
  ```

- [ ] Test lock API endpoint

  ```bash
  curl -X POST http://localhost:4000/api/v1/kickscooter/lock \
    -H "Content-Type: application/json" \
    -d '{"qrCode":"QR198676"}'
  ```

## 📱 Mobile App Integration

- [ ] Add HTTP package if not exists

  ```yaml
  dependencies:
    http: ^1.0.0
  ```

- [ ] Create ScooterService class (see `MQTT_INTEGRATION_EXAMPLE.dart`)
- [ ] Update QR scan handler to call unlock API

  ```dart
  void onQRScanned(String qrCode) async {
    final result = await ScooterService.unlockScooter(
      qrCode, token, xsrfToken
    );
    if (result['success']) {
      // Start ride
    }
  }
  ```

- [ ] Add lock function to end ride

  ```dart
  void endRide(String qrCode) async {
    await ScooterService.lockScooter(qrCode, token, xsrfToken);
  }
  ```

- [ ] Test on real device or emulator

## 🔩 Hardware Integration (ESP32/Arduino)

- [ ] Set up ESP32 with WiFi capability
- [ ] Install MQTT library

  ```cpp
  // Arduino Library Manager
  PubSubClient by Nick O'Leary
  ```

- [ ] Configure WiFi credentials

  ```cpp
  const char* ssid = "YOUR_WIFI";
  const char* password = "YOUR_PASSWORD";
  ```

- [ ] Subscribe to scooter command topic

  ```cpp
  String topic = "scooter/" + scooterQRCode + "/command";
  client.subscribe(topic.c_str());
  ```

- [ ] Implement lock/unlock mechanism

  ```cpp
  void callback(char* topic, byte* payload, unsigned int length) {
    String message = String((char*)payload);
    if (message == "unlock") {
      digitalWrite(RELAY_PIN, HIGH); // Open lock
    } else if (message == "lock") {
      digitalWrite(RELAY_PIN, LOW); // Close lock
    }
  }
  ```

- [ ] Test hardware with manual MQTT commands

  ```bash
  mosquitto_pub -h YOUR_BACKEND_IP -t "scooter/QR198676/command" -m "unlock"
  ```

## 🐳 Docker Deployment

- [ ] Update `.env` file with production values
- [ ] Build and start services

  ```bash
  docker-compose up -d
  ```

- [ ] Verify all containers are running

  ```bash
  docker-compose ps
  ```

- [ ] Check Mosquitto logs

  ```bash
  docker-compose logs mosquitto
  ```

- [ ] Check Backend logs

  ```bash
  docker-compose logs backend
  ```

- [ ] Test MQTT from host to container

  ```bash
  mosquitto_pub -h localhost -t "scooter/TEST/command" -m "unlock"
  ```

## 🔐 Security Hardening

- [ ] Enable MQTT authentication

  ```bash
  # Create password file
  mosquitto_passwd -c /etc/mosquitto/passwd clemopi_user
  ```

- [ ] Configure TLS/SSL for MQTT (production)

  ```env
  MQTT_PROTOCOL=mqtts
  MQTT_PORT=8883
  ```

- [ ] Implement API rate limiting
- [ ] Add user permission checks

  ```javascript
  // Verify user has permission to unlock this scooter
  if (user.banned || user.balance < 0) {
    return res.status(403).json({ error: "Insufficient permissions" });
  }
  ```

- [ ] Log all lock/unlock actions

  ```javascript
  console.log(`[AUDIT] User ${userId} unlocked scooter ${qrCode}`);
  ```

## 📊 Monitoring & Maintenance

- [ ] Set up MQTT message logging
- [ ] Monitor scooter connection status

  ```javascript
  // Track last seen timestamp for each scooter
  ```

- [ ] Implement health checks

  ```javascript
  app.get("/health", (req, res) => {
    const mqttConnected = mqttClient.connected;
    res.json({
      status: "ok",
      mqtt: mqttConnected ? "connected" : "disconnected",
    });
  });
  ```

- [ ] Set up alerts for disconnected scooters
- [ ] Create dashboard for MQTT statistics

## 🚀 Future Enhancements

- [ ] Bidirectional MQTT (hardware → backend status updates)
- [ ] Real-time battery level monitoring via MQTT
- [ ] GPS location updates via MQTT
- [ ] Anti-theft alerts (motion detection)
- [ ] Fleet-wide commands (lock all scooters in region)
- [ ] Scooter diagnostics via MQTT
- [ ] Remote firmware updates (OTA)

## 📋 Pre-Production Checklist

- [ ] All tests passing ✓
- [ ] Documentation complete and reviewed ✓
- [ ] Security audit completed
- [ ] Load testing performed
- [ ] Backup strategy in place
- [ ] Monitoring and alerting configured
- [ ] Rollback plan documented
- [ ] Team trained on new system

## ✨ Success Criteria

- [ ] User can scan QR code and unlock scooter via mobile app
- [ ] Physical scooter lock responds within 2 seconds
- [ ] Database updates reflect lock state changes
- [ ] System handles 100+ concurrent unlock requests
- [ ] Zero message loss (MQTT QoS 1)
- [ ] 99.9% uptime for MQTT broker

---

## 📞 Support Resources

- **Documentation**: `MQTT_INTEGRATION.md`
- **Architecture**: `ARCHITECTURE_DIAGRAM.txt`
- **Testing**: `test_mqtt.sh`
- **Quick Start**: `quick_start.sh`

## 🐛 Known Issues

None currently. Report issues to the development team.

---

**Last Updated**: December 30, 2025
**Status**: ✅ Ready for Testing
