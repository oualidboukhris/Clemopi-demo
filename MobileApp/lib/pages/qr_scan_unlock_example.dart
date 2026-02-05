import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../services/scooter_service.dart';

/// Example page showing how to scan QR code and unlock scooter
///
/// Usage:
/// 1. User opens this page
/// 2. Scans scooter QR code (e.g., "QR198676")
/// 3. App calls unlock API
/// 4. MQTT message sent to scooter
/// 5. Physical scooter unlocks!
class QRScanUnlockPage extends StatefulWidget {
  const QRScanUnlockPage({Key? key}) : super(key: key);

  @override
  State<QRScanUnlockPage> createState() => _QRScanUnlockPageState();
}

class _QRScanUnlockPageState extends State<QRScanUnlockPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;
  final ScooterService _scooterService = ScooterService();

  String? scannedCode;
  bool isUnlocking = false;
  String? statusMessage;

  @override
  void dispose() {
    qrController?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      qrController = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      if (scanData.code != null && scanData.code!.isNotEmpty && !isUnlocking) {
        // Pause camera to prevent multiple scans
        await controller.pauseCamera();

        setState(() {
          scannedCode = scanData.code;
          isUnlocking = true;
          statusMessage = 'Unlocking scooter ${scanData.code}...';
        });

        // Call unlock API
        try {
          final result =
              await _scooterService.unlockScooterByQR(scanData.code!);

          if (result['error'] == false && result['isValid'] == true) {
            setState(() {
              statusMessage =
                  result['message'] ?? '✅ Scooter unlocked successfully!';
            });

            // Show success dialog with scooter info
            if (mounted) {
              _showSuccessDialog(scanData.code!, result['scooter'] ?? {});
            }
          } else {
            setState(() {
              statusMessage = result['message'] ?? '❌ Invalid QR Code';
            });

            // Show error dialog
            if (mounted) {
              _showErrorDialog(result['message'] ?? 'Invalid QR Code');
            }

            // Resume camera after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                controller.resumeCamera();
                setState(() {
                  isUnlocking = false;
                  statusMessage = null;
                });
              }
            });
          }
        } catch (e) {
          setState(() {
            statusMessage = '❌ Failed to unlock: $e';
          });

          // Resume camera after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              controller.resumeCamera();
              setState(() {
                isUnlocking = false;
                statusMessage = null;
              });
            }
          });
        }
      }
    });
  }

  void _showSuccessDialog(String qrCode, Map<String, dynamic> scooterInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text('Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scooter $qrCode unlocked!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (scooterInfo.isNotEmpty) ...[
              _buildInfoRow('Battery', '${scooterInfo['battery']}%'),
              _buildInfoRow('Region', scooterInfo['region'] ?? 'N/A'),
              _buildInfoRow('Status', 'Unlocked 🔓'),
              const SizedBox(height: 12),
            ],
            const Text(
              'The MQTT message has been sent to unlock the physical scooter.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume camera for next scan
              qrController?.resumeCamera();
              setState(() {
                isUnlocking = false;
                statusMessage = null;
                scannedCode = null;
              });
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('Invalid QR Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'This QR code is not registered in the system. Please scan a valid CleMoPI scooter QR code.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume camera for next scan
              qrController?.resumeCamera();
              setState(() {
                isUnlocking = false;
                statusMessage = null;
                scannedCode = null;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog_OLD(String qrCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Success!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scooter $qrCode unlocked successfully!'),
            const SizedBox(height: 16),
            const Text(
              'The MQTT message has been sent to unlock the physical scooter.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Resume camera for next scan
              qrController?.resumeCamera();
              setState(() {
                isUnlocking = false;
                statusMessage = null;
                scannedCode = null;
              });
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR to Unlock'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.deepPurple,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
                if (isUnlocking)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    statusMessage ?? 'Scan scooter QR code to unlock',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusMessage?.contains('✅') == true
                          ? Colors.green
                          : statusMessage?.contains('❌') == true
                              ? Colors.red
                              : Colors.black87,
                    ),
                  ),
                  if (scannedCode != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'QR Code: $scannedCode',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
