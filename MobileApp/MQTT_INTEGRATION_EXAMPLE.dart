// MQTT Integration for Flutter Mobile App
// Add this to your Flutter app to handle scooter unlock/lock

import 'package:http/http.dart' as http;
import 'dart:convert';

class ScooterService {
  static const String baseUrl = 'http://YOUR_BACKEND_IP:4000/api/v1';

  // Unlock scooter by QR code
  static Future<Map<String, dynamic>> unlockScooter(
      String qrCode, String token, String xsrfToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kickscooter/unlock'),
        headers: {
          'Content-Type': 'application/json',
          'x-xsrf-token': xsrfToken,
          'Cookie': '_arl=$token',
        },
        body: jsonEncode({
          'qrCode': qrCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to unlock scooter',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Lock scooter by QR code
  static Future<Map<String, dynamic>> lockScooter(
      String qrCode, String token, String xsrfToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kickscooter/lock'),
        headers: {
          'Content-Type': 'application/json',
          'x-xsrf-token': xsrfToken,
          'Cookie': '_arl=$token',
        },
        body: jsonEncode({
          'qrCode': qrCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to lock scooter',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}

// Usage Example in Flutter Widget:
/*
// After QR code scan
void onQRScanned(String qrCode) async {
  // Show loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(child: CircularProgressIndicator()),
  );

  // Get stored auth tokens
  String? token = await UserService.getToken();
  String? xsrfToken = await UserService.getXsrfToken();

  // Unlock the scooter
  final result = await ScooterService.unlockScooter(qrCode, token!, xsrfToken!);
  
  Navigator.pop(context); // Close loading

  if (result['success']) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔓 ${result['message']}'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Start ride timer, update UI, etc.
    startRide(qrCode);
  } else {
    // Show error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ ${result['message']}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// When ending ride
void endRide(String qrCode) async {
  final result = await ScooterService.lockScooter(qrCode, token, xsrfToken);
  
  if (result['success']) {
    // Show success, stop timer, show ride summary
    print('Scooter locked successfully');
  }
}
*/
