const mqtt = require("mqtt");
require("dotenv").config();

// MQTT Configuration
const MQTT_CONFIG = {
  host: process.env.MQTT_HOST || "localhost",
  port: process.env.MQTT_PORT || 1883,
  protocol: process.env.MQTT_PROTOCOL || "mqtt",
  username: process.env.MQTT_USERNAME || "",
  password: process.env.MQTT_PASSWORD || "",
};

// Create MQTT client
let client = null;

// Connect to MQTT Broker
function connectMQTT() {
  const brokerUrl = `${MQTT_CONFIG.protocol}://${MQTT_CONFIG.host}:${MQTT_CONFIG.port}`;

  const options = {
    clientId: `clemopi_backend_${Math.random().toString(16).substr(2, 8)}`,
    clean: true,
    connectTimeout: 4000,
    reconnectPeriod: 1000,
  };

  // Add credentials if provided
  if (MQTT_CONFIG.username) {
    options.username = MQTT_CONFIG.username;
    options.password = MQTT_CONFIG.password;
  }

  client = mqtt.connect(brokerUrl, options);

  client.on("connect", () => {
    console.log("✅ Connected to MQTT Broker:", brokerUrl);
  });

  client.on("error", (err) => {
    console.error("❌ MQTT Connection Error:", err.message);
  });

  client.on("reconnect", () => {
    console.log("🔄 Reconnecting to MQTT Broker...");
  });

  client.on("close", () => {
    console.log("⚠️  MQTT Connection Closed");
  });

  return client;
}

// Publish message to MQTT topic
function publishMessage(topic, message) {
  return new Promise((resolve, reject) => {
    if (!client || !client.connected) {
      return reject(new Error("MQTT client not connected"));
    }

    client.publish(topic, message, { qos: 1, retain: false }, (err) => {
      if (err) {
        console.error(`❌ Failed to publish to ${topic}:`, err);
        reject(err);
      } else {
        console.log(`✅ Published to ${topic}: ${message}`);
        resolve();
      }
    });
  });
}

// Subscribe to MQTT topic
function subscribeTopic(topic, callback) {
  if (!client || !client.connected) {
    console.error("MQTT client not connected");
    return;
  }

  client.subscribe(topic, { qos: 1 }, (err) => {
    if (err) {
      console.error(`❌ Failed to subscribe to ${topic}:`, err);
    } else {
      console.log(`✅ Subscribed to topic: ${topic}`);
    }
  });

  client.on("message", (receivedTopic, message) => {
    if (receivedTopic === topic) {
      callback(message.toString());
    }
  });
}

// Send lock command to scooter
async function lockScooter(qrCode) {
  const topic = `scooter/${qrCode}/command`;
  await publishMessage(topic, "lock");
}

// Send unlock command to scooter
async function unlockScooter(qrCode) {
  const topic = `scooter/${qrCode}/command`;
  await publishMessage(topic, "unlock");
}

// Send STATION_UNLOCK command to scooter
async function stationUnlock(qrCode) {
  const topic = `scooter/${qrCode}/command`;
  await publishMessage(topic, "STATION_UNLOCK");
  // Also publish to esp32/commands for direct ESP32 communication
  await publishMessage("esp32/commands", "STATION_UNLOCK");
}

// Send STATION_LOCK command to scooter
async function stationLock(qrCode) {
  const topic = `scooter/${qrCode}/command`;
  await publishMessage(topic, "STATION_LOCK");
  // Also publish to esp32/commands for direct ESP32 communication
  await publishMessage("esp32/commands", "STATION_LOCK");
}

// Send SCOOTER_UNLOCK command to scooter
async function scooterUnlock(qrCode) {
  const topic = `scooter/${qrCode}/command`;
  await publishMessage(topic, "SCOOTER_UNLOCK");
  // Also publish to esp32/commands for direct ESP32 communication
  await publishMessage("esp32/commands", "SCOOTER_UNLOCK");
}

// Send SCOOTER_LOCK command to scooter
async function scooterLock(qrCode) {
  const topic = `scooter/${qrCode}/command`;
  await publishMessage(topic, "SCOOTER_LOCK");
  // Also publish to esp32/commands for direct ESP32 communication
  await publishMessage("esp32/commands", "SCOOTER_LOCK");
}

// Send SCOOTER_INFO request to scooter
async function scooterInfo(qrCode) {
  const topic = `scooter/${qrCode}/command`;
  await publishMessage(topic, "SCOOTER_INFO");
  // Also publish to esp32/commands for direct ESP32 communication
  await publishMessage("esp32/commands", "SCOOTER_INFO");
}

// Get MQTT client instance
function getClient() {
  return client;
}

// Disconnect MQTT client
function disconnect() {
  if (client) {
    client.end();
    console.log("🔌 MQTT Client Disconnected");
  }
}

module.exports = {
  connectMQTT,
  publishMessage,
  subscribeTopic,
  lockScooter,
  unlockScooter,
  stationUnlock,
  stationLock,
  scooterUnlock,
  scooterLock,
  scooterInfo,
  getClient,
  disconnect,
};
