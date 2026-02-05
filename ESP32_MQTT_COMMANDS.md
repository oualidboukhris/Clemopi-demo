# 🔌 ESP32 MQTT Commands for Scooter Control

## 📡 MQTT Broker Configuration

```cpp
const char* mqtt_server = "10.245.227.199";  // Your current IP
const int mqtt_port = 1883;
const char* mqtt_user = "";        // No authentication
const char* mqtt_password = "";
```

⚠️ **Note**: Update IP address if your Mac's network changes!

---

## 📨 MQTT Topics & Commands

### Subscribe Topic Pattern

Your ESP32 should subscribe to:

```cpp
String topic = "scooter/" + String(qrCode) + "/command";
// Example: "scooter/QR198676/command"
```

### Commands Received When QR Code is Scanned

When a user scans the QR code in the mobile app, your ESP32 will receive **4 commands** in sequence:

1. **`unlock`** - Legacy unlock command
2. **`STATION_UNLOCK`** - Unlock station/dock mechanism
3. **`SCOOTER_UNLOCK`** - Unlock scooter itself
4. **`SCOOTER_INFO`** - Request scooter information

---

## 🔧 ESP32 Implementation Example

```cpp
#include <WiFi.h>
#include <PubSubClient.h>

// WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// MQTT Broker
const char* mqtt_server = "10.245.227.199";
const int mqtt_port = 1883;

// Scooter QR Code (unique identifier)
const char* qrCode = "QR198676";  // Change for each scooter

WiFiClient espClient;
PubSubClient client(espClient);

// Pin definitions
#define STATION_LOCK_PIN 25    // GPIO for station lock relay
#define SCOOTER_LOCK_PIN 26    // GPIO for scooter lock relay
#define LED_PIN 2              // Built-in LED

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");

  // Convert payload to string
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.println(message);

  // Handle commands
  if (message == "unlock") {
    Serial.println("🔓 Received UNLOCK command");
    unlockAll();
  }
  else if (message == "STATION_UNLOCK") {
    Serial.println("🏢 Received STATION_UNLOCK command");
    unlockStation();
  }
  else if (message == "SCOOTER_UNLOCK") {
    Serial.println("🛴 Received SCOOTER_UNLOCK command");
    unlockScooter();
  }
  else if (message == "SCOOTER_INFO") {
    Serial.println("📊 Received SCOOTER_INFO request");
    sendScooterInfo();
  }
  else if (message == "lock") {
    Serial.println("🔒 Received LOCK command");
    lockAll();
  }
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");

    // Create a unique client ID
    String clientId = "ESP32Scooter-";
    clientId += String(qrCode);

    if (client.connect(clientId.c_str())) {
      Serial.println("connected");

      // Subscribe to command topic
      String topic = "scooter/" + String(qrCode) + "/command";
      client.subscribe(topic.c_str());
      Serial.print("Subscribed to: ");
      Serial.println(topic);

      // Flash LED to indicate connection
      digitalWrite(LED_PIN, HIGH);
      delay(500);
      digitalWrite(LED_PIN, LOW);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void unlockStation() {
  Serial.println("🏢 Unlocking station...");
  digitalWrite(STATION_LOCK_PIN, HIGH);  // Activate relay
  delay(2000);                           // Keep active for 2 seconds
  digitalWrite(STATION_LOCK_PIN, LOW);   // Deactivate relay
  Serial.println("✅ Station unlocked");
}

void unlockScooter() {
  Serial.println("🛴 Unlocking scooter...");
  digitalWrite(SCOOTER_LOCK_PIN, HIGH);  // Activate relay
  delay(2000);                           // Keep active for 2 seconds
  digitalWrite(SCOOTER_LOCK_PIN, LOW);   // Deactivate relay
  Serial.println("✅ Scooter unlocked");
}

void unlockAll() {
  Serial.println("🔓 Unlocking all...");
  unlockStation();
  delay(500);
  unlockScooter();
}

void lockAll() {
  Serial.println("🔒 Locking all...");
  digitalWrite(STATION_LOCK_PIN, LOW);
  digitalWrite(SCOOTER_LOCK_PIN, LOW);
  Serial.println("✅ All locked");
}

void sendScooterInfo() {
  Serial.println("📊 Sending scooter info...");

  // Publish scooter info to response topic
  String responseTopic = "scooter/" + String(qrCode) + "/info";

  // Example: Read battery level (replace with actual sensor reading)
  int batteryLevel = 85;  // Replace with: analogRead(BATTERY_PIN)

  // Example: Get GPS coordinates (replace with actual GPS module)
  String coords = "33.5731,-7.5898";  // Replace with GPS reading

  // Create JSON response
  String info = "{";
  info += "\"qrCode\":\"" + String(qrCode) + "\",";
  info += "\"battery\":" + String(batteryLevel) + ",";
  info += "\"coords\":\"" + coords + "\",";
  info += "\"lock_state\":false,";
  info += "\"timestamp\":" + String(millis());
  info += "}";

  client.publish(responseTopic.c_str(), info.c_str());
  Serial.println("✅ Info sent: " + info);
}

void setup() {
  Serial.begin(115200);

  // Setup pins
  pinMode(STATION_LOCK_PIN, OUTPUT);
  pinMode(SCOOTER_LOCK_PIN, OUTPUT);
  pinMode(LED_PIN, OUTPUT);

  // Initialize locks to locked state
  digitalWrite(STATION_LOCK_PIN, LOW);
  digitalWrite(SCOOTER_LOCK_PIN, LOW);

  // Connect to WiFi
  setup_wifi();

  // Setup MQTT
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);

  Serial.println("🛴 Scooter Controller Started");
  Serial.print("QR Code: ");
  Serial.println(qrCode);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}
```

---

## 🔄 Complete Flow

### When User Scans QR Code:

```
1. User opens mobile app
2. Taps "Unlock Scooter"
3. Scans QR code: "QR198676"
4. App sends unlock request to backend
5. Backend publishes 4 MQTT commands:
   ├─ "unlock"           → ESP32 unlocks both
   ├─ "STATION_UNLOCK"   → ESP32 unlocks station
   ├─ "SCOOTER_UNLOCK"   → ESP32 unlocks scooter
   └─ "SCOOTER_INFO"     → ESP32 sends info back
6. ESP32 receives commands and executes
7. User can now use the scooter
```

---

## 🧪 Testing MQTT Commands

### Test from terminal (Mac):

```bash
# Test unlock
mosquitto_pub -h 10.245.227.199 -p 1883 -t "scooter/QR198676/command" -m "unlock"

# Test station unlock
mosquitto_pub -h 10.245.227.199 -p 1883 -t "scooter/QR198676/command" -m "STATION_UNLOCK"

# Test scooter unlock
mosquitto_pub -h 10.245.227.199 -p 1883 -t "scooter/QR198676/command" -m "SCOOTER_UNLOCK"

# Test info request
mosquitto_pub -h 10.245.227.199 -p 1883 -t "scooter/QR198676/command" -m "SCOOTER_INFO"

# Test lock
mosquitto_pub -h 10.245.227.199 -p 1883 -t "scooter/QR198676/command" -m "lock"
```

### Monitor ESP32 responses:

```bash
mosquitto_sub -h 10.245.227.199 -p 1883 -t "scooter/#" -v
```

---

## 📋 Hardware Checklist

- [ ] ESP32 board
- [ ] 2x Relay modules (5V) for locks
- [ ] Power supply (12V recommended)
- [ ] Voltage regulator (12V → 5V for ESP32)
- [ ] Electric locks (station + scooter)
- [ ] Wiring and connectors
- [ ] Optional: Battery level sensor
- [ ] Optional: GPS module

---

## ⚙️ Pin Configuration

| Pin     | Function         | Description                 |
| ------- | ---------------- | --------------------------- |
| GPIO 25 | STATION_LOCK_PIN | Controls station lock relay |
| GPIO 26 | SCOOTER_LOCK_PIN | Controls scooter lock relay |
| GPIO 2  | LED_PIN          | Status LED (built-in)       |
| GND     | Ground           | Common ground               |
| 5V      | Power            | ESP32 power supply          |

---

## 🐛 Troubleshooting

### ESP32 not connecting to MQTT:

1. Check WiFi credentials
2. Verify IP address: `10.245.227.199`
3. Ensure both devices on same network
4. Check firewall allows port 1883

### Commands not received:

1. Verify subscription topic matches
2. Check MQTT broker logs: `docker logs clemopi_mosquitto`
3. Monitor with: `mosquitto_sub -h 10.245.227.199 -t "#" -v`

### Locks not working:

1. Test relay with manual GPIO control
2. Check power supply voltage
3. Verify relay connections
4. Test with multimeter

---

## 📚 Next Steps

1. ✅ Update ESP32 code with your QR code
2. ✅ Configure WiFi credentials
3. ✅ Connect hardware (relays, locks)
4. ✅ Upload code to ESP32
5. ✅ Test with mobile app
6. ✅ Monitor serial output
7. ✅ Deploy to physical scooter

---

**Created**: 2026-01-16  
**Backend IP**: `10.245.227.199:4000`  
**MQTT Broker**: `10.245.227.199:1883`
