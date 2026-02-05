#!/bin/bash

# Test script for MQTT integration
# Usage: ./test_mqtt.sh

echo "🧪 CleMoPI MQTT Integration Test"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
MQTT_HOST=${MQTT_HOST:-localhost}
MQTT_PORT=${MQTT_PORT:-1883}
QR_CODE="QR198676"
TOPIC="scooter/$QR_CODE/command"

# Check if mosquitto_pub is installed
if ! command -v mosquitto_pub &> /dev/null; then
    echo -e "${RED}❌ mosquitto_pub not found${NC}"
    echo "Install with:"
    echo "  macOS: brew install mosquitto"
    echo "  Ubuntu: sudo apt-get install mosquitto-clients"
    exit 1
fi

echo -e "${GREEN}✅ Mosquitto clients installed${NC}"

# Test 1: Subscribe to topic (in background)
echo ""
echo "📡 Test 1: Subscribing to MQTT topic..."
echo "Topic: $TOPIC"

mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -t "$TOPIC" -v > /tmp/mqtt_test.log 2>&1 &
SUB_PID=$!
sleep 2

if ps -p $SUB_PID > /dev/null; then
    echo -e "${GREEN}✅ Successfully subscribed to topic${NC}"
else
    echo -e "${RED}❌ Failed to subscribe to topic${NC}"
    exit 1
fi

# Test 2: Publish unlock command
echo ""
echo "🔓 Test 2: Publishing UNLOCK command..."
if mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t "$TOPIC" -m "unlock"; then
    echo -e "${GREEN}✅ UNLOCK command published${NC}"
    sleep 1
    
    if grep -q "unlock" /tmp/mqtt_test.log; then
        echo -e "${GREEN}✅ UNLOCK command received${NC}"
    else
        echo -e "${YELLOW}⚠️  Message not received (check subscriber)${NC}"
    fi
else
    echo -e "${RED}❌ Failed to publish UNLOCK command${NC}"
fi

# Test 3: Publish lock command
echo ""
echo "🔒 Test 3: Publishing LOCK command..."
if mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t "$TOPIC" -m "lock"; then
    echo -e "${GREEN}✅ LOCK command published${NC}"
    sleep 1
    
    if grep -q "lock" /tmp/mqtt_test.log; then
        echo -e "${GREEN}✅ LOCK command received${NC}"
    else
        echo -e "${YELLOW}⚠️  Message not received (check subscriber)${NC}"
    fi
else
    echo -e "${RED}❌ Failed to publish LOCK command${NC}"
fi

# Test 4: Listen to all scooter topics
echo ""
echo "🔍 Test 4: Monitoring all scooter topics (5 seconds)..."
timeout 5 mosquitto_sub -h $MQTT_HOST -p $MQTT_PORT -t "scooter/#" -v 2>&1 | head -n 10 &
MONITOR_PID=$!

sleep 1
# Send test messages
mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t "scooter/TEST001/command" -m "test1" &
mosquitto_pub -h $MQTT_HOST -p $MQTT_PORT -t "scooter/TEST002/command" -m "test2" &

wait $MONITOR_PID 2>/dev/null
echo -e "${GREEN}✅ Monitoring complete${NC}"

# Cleanup
kill $SUB_PID 2>/dev/null
rm -f /tmp/mqtt_test.log

echo ""
echo "=================================="
echo -e "${GREEN}🎉 MQTT Integration Test Complete${NC}"
echo ""
echo "Next Steps:"
echo "1. Start the backend server: cd Backend && npm start"
echo "2. Test the API endpoints with curl (see MQTT_INTEGRATION.md)"
echo "3. Integrate with mobile app"
echo ""
