# 📱 QR Code Generation Guide

## Overview

Generate and manage QR codes for your CleMoPI scooters that can be scanned by the mobile app to unlock them.

## 🎯 Features

- ✅ Generate QR codes for any scooter by QR code ID
- ✅ Download individual QR codes as PNG images
- ✅ View all scooters with their QR codes
- ✅ Print QR codes for physical attachment to scooters
- ✅ Web interface for easy management
- ✅ Batch operations for multiple scooters

## 📡 API Endpoints

### 1. Generate QR Code (JSON with Base64 Image)

```http
GET /api/v1/kickscooter/:qrCode/qrcode
```

**Example:**

```bash
curl http://localhost:4000/api/v1/kickscooter/QR198676/qrcode \
  -H "Cookie: _arl=YOUR_TOKEN"
```

**Response:**

```json
{
  "error": false,
  "message": "QR code generated successfully",
  "qrCode": "QR198676",
  "qrCodeImage": "data:image/png;base64,iVBORw0KGgoAAAANS...",
  "scooter": {
    "id": 1,
    "qrCode": "QR198676",
    "battery": "85",
    "coords": "33.5731,-7.5898"
  }
}
```

### 2. Download QR Code (PNG File)

```http
GET /api/v1/kickscooter/:qrCode/qrcode/download
```

**Example:**

```bash
curl http://localhost:4000/api/v1/kickscooter/QR198676/qrcode/download \
  -H "Cookie: _arl=YOUR_TOKEN" \
  -o scooter-QR198676.png
```

**Response:** PNG image file

### 3. Get All Scooters with QR Codes

```http
GET /api/v1/kickscooters/qrcodes/all
```

**Example:**

```bash
curl http://localhost:4000/api/v1/kickscooters/qrcodes/all \
  -H "Cookie: _arl=YOUR_TOKEN"
```

**Response:**

```json
{
  "error": false,
  "message": "Scooters with QR codes retrieved successfully",
  "count": 5,
  "scooters": [
    {
      "id": 1,
      "qrCode": "QR198676",
      "battery": "85",
      "coords": "33.5731,-7.5898",
      "lock_state": "false",
      "qrCodeImage": "data:image/png;base64,..."
    },
    ...
  ]
}
```

## 🖥️ Web Interface

Access the QR code management interface at:

```
http://localhost:4000/public/qr-codes.html
```

### Features:

- 📋 View all scooters with QR codes
- 🔍 Search scooters by QR code
- 💾 Download individual QR codes
- 🖨️ Print individual or all QR codes
- 🔄 Refresh to load latest data
- 📱 Responsive design

### Screenshots Description:

**Main View:**

- Grid layout showing all scooters
- Each card displays:
  - QR code ID
  - QR code image (scannable)
  - Battery level with color coding
  - Lock status (locked/unlocked)
  - GPS coordinates
  - Download and Print buttons

**Actions:**

- **Refresh Button**: Reload QR codes from database
- **Print All**: Opens print dialog for all cards
- **Search Bar**: Filter scooters by QR code
- **Individual Download**: Save QR code as PNG
- **Individual Print**: Print single QR code

## 📱 Mobile App Integration

### Scanning QR Codes

The mobile app should scan the QR code and extract the scooter ID:

```dart
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey();
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan Scooter QR Code')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // Pause scanning
      controller.pauseCamera();

      // Extract QR code (e.g., "QR198676")
      String qrCode = scanData.code ?? '';

      if (qrCode.isNotEmpty) {
        // Call unlock API
        await unlockScooter(qrCode);
      }

      // Resume scanning if needed
      controller.resumeCamera();
    });
  }

  Future<void> unlockScooter(String qrCode) async {
    try {
      final result = await ScooterService.unlockScooter(
        qrCode: qrCode,
        token: userToken,
        xsrfToken: xsrfToken,
      );

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔓 Scooter unlocked!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to ride screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideScreen(qrCode: qrCode),
          ),
        );
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error unlocking scooter: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
```

## 🏭 Production Workflow

### 1. Generate QR Codes for All Scooters

Use the web interface or API to generate QR codes for your fleet.

### 2. Print QR Code Stickers

```bash
# Access the web interface
open http://localhost:4000/public/qr-codes.html

# Or use API to download all
for qr in QR198676 QR198677 QR198678; do
  curl -o "qr-$qr.png" \
    http://localhost:4000/api/v1/kickscooter/$qr/qrcode/download
done
```

**Print Settings:**

- Size: 5cm x 5cm (recommended)
- Material: Waterproof sticker paper
- Quality: 300 DPI minimum
- Laminate for outdoor durability

### 3. Attach to Physical Scooters

- Clean the surface
- Place QR code on visible location (handlebar or body)
- Apply protective laminate
- Test scanning with mobile app

### 4. Test Workflow

```
1. User opens mobile app
2. User taps "Unlock Scooter"
3. Camera opens to scan QR code
4. User scans QR code on scooter
5. App extracts QR code ID (e.g., "QR198676")
6. App calls API: POST /kickscooter/unlock
7. Backend validates and publishes MQTT "unlock"
8. Physical scooter receives command and unlocks
9. User starts riding
```

## 🔧 Troubleshooting

### QR Code Not Scanning

**Problem:** Mobile app can't read QR code

**Solutions:**

- Ensure good lighting
- Clean QR code sticker
- Hold phone steady
- Check QR code is not damaged
- Regenerate and reprint QR code

### API Returns 404

**Problem:** Scooter not found

**Solutions:**

```bash
# Verify scooter exists in database
mysql -u root -p clemopi_db -e "SELECT * FROM kickscooters WHERE qrCode='QR198676';"

# Check API endpoint
curl http://localhost:4000/api/v1/kickscooter/QR198676
```

### Authentication Issues

**Problem:** 401 Unauthorized

**Solutions:**

- Login first to get token
- Include cookie in request
- Check token expiration

```bash
# Login first
curl -X POST http://localhost:4000/api/v1/user/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@clemopi.com","password":"password"}' \
  -c cookies.txt

# Then use token
curl http://localhost:4000/api/v1/kickscooters/qrcodes/all \
  -b cookies.txt
```

## 📊 QR Code Specifications

| Property         | Value                   |
| ---------------- | ----------------------- |
| Format           | PNG                     |
| Size (API)       | 300x300 pixels          |
| Size (Download)  | 500x500 pixels          |
| Error Correction | Medium                  |
| Margin           | 2-4 modules             |
| Colors           | Black on White          |
| Data             | Plain text (QR code ID) |

## 🎨 Customization

### Change QR Code Appearance

Edit `/Backend/controller/kickscooters.controller.js`:

```javascript
const qrCodeDataURL = await QRCode.toDataURL(qrCode, {
  width: 500, // Increase size
  margin: 4, // More white space
  color: {
    dark: "#667eea", // Custom color
    light: "#FFFFFF", // Background
  },
});
```

### Add Logo to QR Code

```javascript
const QRCode = require("qrcode");
const { createCanvas, loadImage } = require("canvas");

async function generateQRWithLogo(qrCode) {
  // Generate QR code
  const canvas = createCanvas(500, 500);
  await QRCode.toCanvas(canvas, qrCode);

  // Load and add logo
  const ctx = canvas.getContext("2d");
  const logo = await loadImage("path/to/logo.png");
  const logoSize = 80;
  const x = (500 - logoSize) / 2;
  const y = (500 - logoSize) / 2;
  ctx.drawImage(logo, x, y, logoSize, logoSize);

  return canvas.toDataURL();
}
```

## 🔐 Security Best Practices

1. **Unique QR Codes**: Each scooter must have a unique QR code
2. **Database Validation**: Always verify QR code exists before unlocking
3. **Authentication**: Require user login before generating/scanning
4. **Rate Limiting**: Prevent QR code generation abuse
5. **Audit Logging**: Log all QR code scans and unlocks
6. **Physical Security**: Use tamper-evident stickers

## 📈 Analytics

Track QR code usage:

```sql
-- Most scanned scooters
SELECT qrCode, totalOrders, scanStatus
FROM kickscooters
ORDER BY totalOrders DESC
LIMIT 10;

-- Scooters never scanned
SELECT qrCode, register_time
FROM kickscooters
WHERE scanStatus = '' OR scanStatus IS NULL;
```

## 🚀 Next Steps

1. ✅ Generate QR codes for existing scooters
2. ⏳ Print and attach QR codes to physical scooters
3. ⏳ Update mobile app QR scanner
4. ⏳ Test end-to-end: Scan → Unlock → Ride
5. ⏳ Set up analytics dashboard
6. ⏳ Implement QR code rotation (security)

---

**Documentation Last Updated:** December 30, 2025
**Status:** ✅ Ready for Production
