#!/bin/bash

# CleMoPI Quick Start Script
# This script helps you set up the development environment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════╗"
echo "║   CleMoPI Quick Start Setup           ║"
echo "╔═══════════════════════════════════════╗"
echo -e "${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found${NC}"
    echo -e "${BLUE}Creating .env from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✅ .env file created${NC}"
    echo -e "${YELLOW}⚠️  Please edit .env with your configuration before continuing${NC}"
    echo ""
    read -p "Press Enter after editing .env file..."
fi

# Check Node.js
echo -e "${BLUE}Checking Node.js...${NC}"
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✅ Node.js installed: $NODE_VERSION${NC}"
else
    echo -e "${RED}❌ Node.js not found${NC}"
    echo "Install from: https://nodejs.org/"
    exit 1
fi

# Check MySQL
echo -e "${BLUE}Checking MySQL...${NC}"
if command -v mysql &> /dev/null; then
    MYSQL_VERSION=$(mysql --version)
    echo -e "${GREEN}✅ MySQL installed${NC}"
else
    echo -e "${YELLOW}⚠️  MySQL not found${NC}"
    echo "Install with: brew install mysql (macOS) or apt install mysql-server (Ubuntu)"
fi

# Check Mosquitto
echo -e "${BLUE}Checking Mosquitto MQTT Broker...${NC}"
if command -v mosquitto &> /dev/null; then
    echo -e "${GREEN}✅ Mosquitto installed${NC}"
    
    # Check if mosquitto is running
    if pgrep -x "mosquitto" > /dev/null; then
        echo -e "${GREEN}✅ Mosquitto is running${NC}"
    else
        echo -e "${YELLOW}⚠️  Mosquitto not running${NC}"
        echo -e "${BLUE}Starting Mosquitto...${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew services start mosquitto
        else
            sudo systemctl start mosquitto
        fi
        sleep 2
        echo -e "${GREEN}✅ Mosquitto started${NC}"
    fi
else
    echo -e "${RED}❌ Mosquitto not found${NC}"
    echo "Install with:"
    echo "  macOS: brew install mosquitto"
    echo "  Ubuntu: sudo apt install mosquitto mosquitto-clients"
    exit 1
fi

# Backend setup
echo ""
echo -e "${BLUE}Setting up Backend...${NC}"
cd Backend

if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}Installing backend dependencies...${NC}"
    npm install
    echo -e "${GREEN}✅ Backend dependencies installed${NC}"
else
    echo -e "${GREEN}✅ Backend dependencies already installed${NC}"
fi

cd ..

# Frontend setup
echo ""
echo -e "${BLUE}Setting up Frontend...${NC}"
cd Frontend

if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}Installing frontend dependencies...${NC}"
    npm install
    echo -e "${GREEN}✅ Frontend dependencies installed${NC}"
else
    echo -e "${GREEN}✅ Frontend dependencies already installed${NC}"
fi

cd ..

# Database setup
echo ""
echo -e "${BLUE}Checking Database...${NC}"
read -p "Do you want to initialize the database? (y/n): " init_db

if [ "$init_db" = "y" ]; then
    echo -e "${BLUE}Initializing database...${NC}"
    read -p "MySQL root password: " -s mysql_password
    echo ""
    
    if mysql -u root -p"$mysql_password" < Backend/clemopi_db.sql; then
        echo -e "${GREEN}✅ Database initialized successfully${NC}"
    else
        echo -e "${RED}❌ Database initialization failed${NC}"
        echo "You may need to create the database manually"
    fi
fi

# Test MQTT
echo ""
echo -e "${BLUE}Testing MQTT connection...${NC}"
if mosquitto_pub -h localhost -t "test/clemopi" -m "hello" 2>/dev/null; then
    echo -e "${GREEN}✅ MQTT connection successful${NC}"
else
    echo -e "${RED}❌ MQTT connection failed${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════╗"
echo "║     Setup Complete! 🎉                 ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Start Backend:"
echo -e "   ${YELLOW}cd Backend && npm start${NC}"
echo ""
echo "2. Start Frontend (in another terminal):"
echo -e "   ${YELLOW}cd Frontend && npm start${NC}"
echo ""
echo "3. Test MQTT integration:"
echo -e "   ${YELLOW}./test_mqtt.sh${NC}"
echo ""
echo "4. Access services:"
echo "   • Backend API: http://localhost:4000"
echo "   • Frontend: http://localhost:3000"
echo "   • MQTT Broker: localhost:1883"
echo ""
echo "5. Read documentation:"
echo "   • README.md"
echo "   • MQTT_INTEGRATION.md"
echo "   • MQTT_SETUP_SUMMARY.md"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
