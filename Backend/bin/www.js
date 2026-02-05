const server = require("../app");
const mqttService = require("../config/mqtt");
require("dotenv").config();

// Connect to MQTT Broker
mqttService.connectMQTT();

server.listen(process.env.PORT_SERVER, () => {
  console.log(`Server api listening on port ${process.env.PORT_SERVER}`);
});

// Graceful shutdown
process.on("SIGINT", () => {
  console.log("\n🛑 Shutting down gracefully...");
  mqttService.disconnect();
  process.exit(0);
});
