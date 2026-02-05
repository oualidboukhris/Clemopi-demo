# 🛴 CleMoPI - Smart Scooter Rental Platform

A complete IoT-enabled scooter sharing platform with mobile app, web dashboard, and hardware integration.

## 🚀 Features

- **Mobile App (Flutter)**: QR code scanning, GPS tracking, ride management
- **Web Dashboard (React)**: Fleet management, analytics, user administration
- **Backend API (Node.js)**: RESTful API with JWT authentication
- **IoT Integration**: MQTT-based real-time scooter lock/unlock
- **Real-time Updates**: Firebase + MQTT for live data synchronization

## 📋 System Requirements

- Node.js 14+
- Flutter 3.6+
- MySQL 8.0
- Mosquitto MQTT Broker
- Docker & Docker Compose (optional)

## 🏗️ Architecture

```
Mobile App (Flutter) ─┐
                      ├──► Backend API (Express) ─┬──► MySQL Database
Web Dashboard (React)─┘                           │
                                                  ├──► Firebase Firestore
                                                  │
                                                  └──► MQTT Broker ──► Scooter Hardware
```

## 🔧 Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Clone repository
git clone https://github.com/Achraf-ahrach/CleMoPI.git
cd CleMoPI

# Configure environment
cp .env.example .env
# Edit .env with your configuration

# Start all services
docker-compose up -d

# Services will be available at:
# - Backend API: http://localhost:4000
# - Frontend: http://localhost:80
# - MySQL: localhost:3306
# - Mosquitto: localhost:1883
```

### Option 2: Manual Setup

#### 1. Database Setup

```bash
# Install MySQL
brew install mysql  # macOS
# OR
sudo apt install mysql-server  # Ubuntu

# Import database
mysql -u root -p < Backend/clemopi_db.sql
```

#### 2. Backend Setup

```bash
cd Backend
npm install

# Configure environment
cp ../.env.example .env
# Edit .env with your settings

# Start server
npm start
```

#### 3. Frontend Setup

```bash
cd Frontend
npm install

# Start development server
npm start
```

#### 4. MQTT Broker Setup

```bash
# Install Mosquitto
brew install mosquitto  # macOS
sudo apt install mosquitto  # Ubuntu

# Start broker
brew services start mosquitto  # macOS
sudo systemctl start mosquitto  # Ubuntu
```

#### 5. Mobile App Setup

```bash
cd MobileApp
flutter pub get
flutter run
```

## 🔐 Environment Configuration

Create a `.env` file in the project root:

```env
# MySQL
MYSQL_ROOT_PASSWORD=rootpassword
MYSQL_DATABASE=clemopi_db
MYSQL_USER=clemopi_user
MYSQL_PASSWORD=clemopi_pass

# Backend
PORT_SERVER=4000
DATABASE_HOST=localhost
DATABASE_USER=clemopi_user
DATABASE_PASSWORD=clemopi_pass
DATABASE_NAME=clemopi_db

# JWT Tokens
TOKEN=your_api_token
ACCESS_TOKEN=your_jwt_secret
ACCESS_TOKEN_EXPIRESIN=86400000
REFRESH_TOKEN=your_refresh_token_secret
REFRESH_TOKEN_EXPIRESIN=1000000

# MQTT
MQTT_HOST=localhost
MQTT_PORT=1883
MQTT_PROTOCOL=mqtt
MQTT_USERNAME=
MQTT_PASSWORD=

# Frontend
REACT_APP_GOOGLE_MAPS_KEY=your_google_maps_api_key
REACT_APP_URL=http://localhost:4000/api/v1
REACT_APP_URL_IMAGE=http://localhost:4000
```

## 📡 MQTT Integration

### Unlock Scooter

```bash
# Via API
POST /api/v1/kickscooter/unlock
Body: { "qrCode": "QR198676" }

# Direct MQTT (testing)
mosquitto_pub -h localhost -t "scooter/QR198676/command" -m "unlock"
```

### Lock Scooter

```bash
# Via API
POST /api/v1/kickscooter/lock
Body: { "qrCode": "QR198676" }

# Direct MQTT (testing)
mosquitto_pub -h localhost -t "scooter/QR198676/command" -m "lock"
```

See [MQTT_INTEGRATION.md](MQTT_INTEGRATION.md) for detailed documentation.

## 🧪 Testing

```bash
# Test MQTT integration
./test_mqtt.sh

# Test backend API
cd Backend
npm test  # (if tests are configured)

# Monitor MQTT messages
mosquitto_sub -h localhost -t "scooter/#" -v
```

## 📱 API Endpoints

### Authentication

- `POST /api/v1/client/register` - Register new user
- `POST /api/v1/client/login` - User login

### Scooters

- `GET /api/v1/kickscooters` - Get all scooters
- `GET /api/v1/kickscooter/:id` - Get scooter details
- `POST /api/v1/kickscooter/unlock` - Unlock scooter
- `POST /api/v1/kickscooter/lock` - Lock scooter

### Users

- `GET /api/v1/users` - Get all users (admin)
- `GET /api/v1/user/:userId` - Get user details
- `PUT /api/v1/balanceUpdate` - Update user balance

### Dashboard

- `GET /api/v1/dashboard/analytics` - Get analytics data
- `GET /api/v1/dashboard/header` - Get dashboard stats

## 🗂️ Project Structure

```
CleMoPI/
├── Backend/                 # Node.js Express API
│   ├── config/             # Database, Firebase, MQTT config
│   ├── controller/         # Business logic
│   ├── models/             # Sequelize models
│   ├── routes/             # API routes
│   └── middlewares/        # Auth, validation
├── Frontend/               # React web dashboard
│   ├── src/
│   │   ├── components/    # Reusable components
│   │   └── pages/         # Page components
│   └── public/
├── MobileApp/             # Flutter mobile app
│   └── lib/
│       ├── models/        # Data models
│       ├── pages/         # App screens
│       └── services/      # API services
├── Database/              # SQL dumps
├── docker-compose.yml     # Docker orchestration
└── .env.example          # Environment template
```

## 🔒 Security

- JWT token authentication
- XSRF token protection
- HTTP-only cookies
- Password hashing (bcrypt)
- Environment-based secrets
- MQTT access control (optional)

## 📊 Database Schema

### Main Tables

- `users` - Admin users
- `clients` - App users (customers)
- `kickscooters` - Scooter fleet
- `dashboard_header` - Dashboard statistics
- `dashboard_analytics` - Analytics data

## 🐛 Troubleshooting

### Backend won't start

```bash
# Check MySQL connection
mysql -u root -p -e "SHOW DATABASES;"

# Check environment variables
cat Backend/.env

# Check port availability
lsof -i :4000
```

### MQTT not working

```bash
# Check Mosquitto status
brew services list  # macOS
systemctl status mosquitto  # Linux

# Test connection
mosquitto_sub -h localhost -t "test" -v
mosquitto_pub -h localhost -t "test" -m "hello"
```

### Mobile app can't connect

```bash
# Check backend is running
curl http://localhost:4000/api/v1/kickscooters

# Update API URL in mobile app
# Edit MobileApp/lib/services/api_service.dart
```

## 📚 Documentation

- [MQTT Integration Guide](MQTT_INTEGRATION.md)
- [MQTT Setup Summary](MQTT_SETUP_SUMMARY.md)
- [Architecture Diagram](ARCHITECTURE_DIAGRAM.txt)
- [Firebase to MySQL Fix](FIREBASE_TO_MYSQL_FIX.md)
- [Supabase Integration](SUPABASE_INTEGRATION_GUIDE.md)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

MIT License - see LICENSE file for details

## 👥 Authors

- **Original Author**: BOUKHRIS Oualid
- **Current Maintainer**: Achraf Ahrach

## 🙏 Acknowledgments

- Firebase for real-time database
- Mosquitto for MQTT broker
- Flutter team for mobile framework
- React team for web framework

## 📞 Support

For issues and questions:

- Open an issue on GitHub
- Check existing documentation
- Review [MQTT_INTEGRATION.md](MQTT_INTEGRATION.md) for MQTT-specific issues

---

**Status**: ✅ Production Ready
**Last Updated**: December 30, 2025
**Version**: 2.0.0 (with MQTT integration)
