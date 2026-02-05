# MQTT Integration for CleMoPI Scooter Lock/Unlock

## Overview

This integration enables real-time communication between the CleMoPI backend and physical scooter hardware using MQTT (Message Queuing Telemetry Transport) protocol via Mosquitto broker.

## Architecture

```
Mobile App (QR Scan)
    ↓
Backend API (POST /api/v1/kickscooter/unlock)
    ↓
MQTT Broker (Mosquitto - localhost:1883)
    ↓
Physical Scooter Hardware (subscribed to scooter/{qrCode}/command)
    ↓
Lock/Unlock Mechanism
```

## Installation

### 1. Install Mosquitto Broker

**macOS:**

```bash
brew install mosquitto
brew services start mosquitto
```

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install mosquitto mosquitto-clients
sudo systemctl start mosquitto
sudo systemctl enable mosquitto
```

**Docker:**

```bash
docker run -d --name mosquitto -p 1883:1883 -p 9001:9001 eclipse-mosquitto
```

### 2. Configure Environment Variables

Copy `.env.example` and update:

```bash
cp .env.example .env
```

Add MQTT configuration:

```env
MQTT_HOST=localhost
MQTT_PORT=1883
MQTT_PROTOCOL=mqtt
MQTT_USERNAME=
MQTT_PASSWORD=
```

### 3. Install Dependencies

```bash
cd Backend
npm install
```

## API Endpoints

### Unlock Scooter

**POST** `/api/v1/kickscooter/unlock`

**Headers:**

```
Authorization: Bearer <token>
x-xsrf-token: <xsrf-token>
Cookie: _arl=<access_token>
```

**Body:**

```json
{
  "qrCode": "QR198676"
}
```

**Response:**

```json
{
  "error": false,
  "message": "Scooter unlocked successfully",
  "qrCode": "QR198676"
}
```

### Lock Scooter

**POST** `/api/v1/kickscooter/lock`

**Headers:**

```
Authorization: Bearer <token>
x-xsrf-token: <xsrf-token>
Cookie: _arl=<access_token>
```

**Body:**

```json
{
  "qrCode": "QR198676"
}
```

**Response:**

```json
{
  "error": false,
  "message": "Scooter locked successfully",
  "qrCode": "QR198676"
}
```

## MQTT Topics

### Command Topic

**Topic:** `scooter/{qrCode}/command`
**Messages:** `lock` or `unlock`

Example:

- `scooter/QR198676/command` → `unlock`
- `scooter/QR198676/command` → `lock`

### Status Topic (Future Enhancement)

**Topic:** `scooter/{qrCode}/status`
**Messages:** `locked`, `unlocked`, `error`, etc.

## Testing

### 1. Test MQTT Broker

```bash
# Subscribe to all scooter topics
mosquitto_sub -h localhost -t "scooter/#" -v

# In another terminal, publish a test message
mosquitto_pub -h localhost -t "scooter/QR198676/command" -m "unlock"
```

### 2. Test with API (using curl)

```bash
# First, login to get token
curl -X POST http://localhost:4000/api/v1/client/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}' \
  -c cookies.txt

# Unlock scooter
curl -X POST http://localhost:4000/api/v1/kickscooter/unlock \
  -H "Content-Type: application/json" \
  -H "x-xsrf-token: YOUR_XSRF_TOKEN" \
  -b cookies.txt \
  -d '{"qrCode":"QR198676"}'

# Lock scooter
curl -X POST http://localhost:4000/api/v1/kickscooter/lock \
  -H "Content-Type: application/json" \
  -H "x-xsrf-token: YOUR_XSRF_TOKEN" \
  -b cookies.txt \
  -d '{"qrCode":"QR198676"}'
```

### 3. Monitor MQTT Messages

```bash
# In one terminal, monitor all messages
mosquitto_sub -h localhost -t "#" -v

# In another, start the backend server
cd Backend
npm start
```

## Hardware Integration

### ESP32/Arduino Example (Scooter Hardware)

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* mqtt_server = "YOUR_BACKEND_IP";
const char* scooter_id = "QR198676";

WiFiClient espClient;
PubSubClient client(espClient);

void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  if (message == "unlock") {
    // Activate unlock mechanism (relay, servo, etc.)
    digitalWrite(LOCK_PIN, HIGH);
    Serial.println("Scooter UNLOCKED");
  } else if (message == "lock") {
    // Activate lock mechanism
    digitalWrite(LOCK_PIN, LOW);
    Serial.println("Scooter LOCKED");
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(LOCK_PIN, OUTPUT);

  WiFi.begin(ssid, password);
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  String topic = "scooter/" + String(scooter_id) + "/command";
  client.subscribe(topic.c_str());
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}
```

## Workflow

1. **User scans QR code** in mobile app
2. **Mobile app sends unlock request** to backend API with QR code
3. **Backend validates** user authentication and scooter existence
4. **Backend publishes MQTT message** to `scooter/{qrCode}/command` topic with payload `unlock`
5. **Physical scooter hardware** (subscribed to topic) receives message
6. **Hardware activates** unlock mechanism (relay, servo, etc.)
7. **Backend updates database** with new lock state (`lock_state = 'false'`)
8. **Response sent** back to mobile app

## Database Schema

The `kickscooters` table includes:

- `qrCode`: Unique identifier for the scooter
- `lock_state`: Current lock status ('true' = locked, 'false' = unlocked)
- Other fields for battery, location, status, etc.

## Security Considerations

1. **Authentication**: All API endpoints require JWT token authentication
2. **MQTT Security**:
   - Use MQTT username/password (configure in `.env`)
   - For production, enable TLS/SSL (mqtts://)
   - Use client certificates for hardware
3. **Authorization**: Verify user has permission to unlock specific scooter
4. **Rate Limiting**: Implement to prevent abuse
5. **Logging**: All lock/unlock actions are logged

## Troubleshooting

### MQTT Connection Issues

```bash
# Check if Mosquitto is running
brew services list  # macOS
systemctl status mosquitto  # Linux

# Test connection
mosquitto_pub -h localhost -t "test" -m "hello"
mosquitto_sub -h localhost -t "test"
```

### Backend Not Connecting to MQTT

- Check `MQTT_HOST` and `MQTT_PORT` in `.env`
- Verify firewall allows port 1883
- Check backend logs for connection errors

### Scooter Hardware Not Receiving Messages

- Verify hardware is connected to same network
- Check topic subscription matches: `scooter/{qrCode}/command`
- Monitor with: `mosquitto_sub -h localhost -t "scooter/#" -v`

## Production Deployment

### Using Docker Compose

See `docker-compose.yml` for Mosquitto service configuration.

### Cloud MQTT Brokers (Alternative)

For production, consider:

- **AWS IoT Core**
- **Azure IoT Hub**
- **CloudMQTT** (managed Mosquitto)
- **HiveMQ Cloud**

Update `.env` accordingly:

```env
MQTT_HOST=your-cloud-broker.com
MQTT_PORT=8883
MQTT_PROTOCOL=mqtts
MQTT_USERNAME=your_username
MQTT_PASSWORD=your_password
```

## Future Enhancements

1. **Bidirectional Communication**: Hardware sends status updates back
2. **Battery Monitoring**: Real-time battery updates via MQTT
3. **GPS Tracking**: Location updates from hardware
4. **Alerts**: Send notifications for low battery, unauthorized movement
5. **Fleet Management**: Bulk commands for multiple scooters
6. **Analytics**: Track usage patterns, lock/unlock frequency

## Support

For issues or questions, refer to:

- Mosquitto Documentation: https://mosquitto.org/documentation/
- MQTT Protocol: https://mqtt.org/
- Node.js MQTT Client: https://github.com/mqttjs/MQTT.js
