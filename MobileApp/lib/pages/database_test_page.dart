import 'package:flutter/material.dart';
import '../services/scooter_service.dart';
import '../services/client_service.dart';

/// Quick test page to verify MySQL database connection
class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  final ScooterService _scooterService = ScooterService();
  final ClientService _clientService = ClientService();
  String _status = 'Not tested';
  bool _isLoading = false;
  String? _result;

  // Controllers for creating a new client
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
      _result = null;
    });

    try {
      final response = await _scooterService.getAllScooters();

      setState(() {
        _isLoading = false;
        if (response['success']) {
          _status = '✅ Connected successfully!';
          final scooters = response['data'] as List;
          _result = 'Found ${scooters.length} scooters in database\n\n'
              'First few scooters:\n${scooters.take(3).map((s) => '- ${s['id']}: ${s['battery_level']}%').join('\n')}';
        } else {
          _status = '❌ Connection failed';
          _result = 'Error: ${response['error']}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Connection error';
        _result = 'Exception: ${e.toString()}\n\n'
            'Tips:\n'
            '• Check if backend is running: docker ps\n'
            '• Verify IP address in api_config.dart\n'
            '• Ensure device and computer on same WiFi';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MySQL Database Test'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connection Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        fontSize: 16,
                        color: _status.contains('✅')
                            ? Colors.green
                            : _status.contains('❌')
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _testConnection,
                icon: const Icon(Icons.refresh),
                label: const Text('Test Database Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            const SizedBox(height: 16),
            if (_result != null)
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Result:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // CREATE CLIENT SECTION
            const Text(
              '📝 Create New Client in MySQL',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createClient,
              icon: const Icon(Icons.add_circle),
              label: const Text('Create Client in MySQL Database'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Configuration',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Update API URL in:\nlib/services/api_config.dart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createClient() async {
    // Validate input
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      setState(() {
        _status = '❌ Please fill all fields';
        _result = 'All fields are required to create a client';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Creating client...';
      _result = null;
    });

    try {
      // Generate a unique userId
      final userId = 'test_${DateTime.now().millisecondsSinceEpoch}';

      // Split username into first and last name
      final nameParts = _usernameController.text.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final clientData = {
        'userId': userId,
        'username': _usernameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'firstName': firstName,
        'lastName': lastName,
        'balance': 100,
        'registerChannel': 'mobile',
        'status': 'Enable',
        'accountStatus': 'Uncommitted',
      };

      final response = await _clientService.createClient(clientData);

      setState(() {
        _isLoading = false;
        if (response['success']) {
          _status = '✅ Client created successfully!';
          _result = 'Client saved to MySQL database:\n\n'
              'UserID: $userId\n'
              'Username: ${_usernameController.text}\n'
              'Email: ${_emailController.text}\n'
              'Phone: ${_phoneController.text}\n\n'
              'Check your database:\n'
              'SELECT * FROM clients WHERE userId = \'$userId\';';

          // Clear form
          _usernameController.clear();
          _emailController.clear();
          _phoneController.clear();
        } else {
          _status = '❌ Failed to create client';
          _result = 'Error: ${response['error']}\n\n'
              'Possible causes:\n'
              '• Not logged in (need authentication token)\n'
              '• Backend not accessible\n'
              '• Database connection issue';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error creating client';
        _result = 'Exception: ${e.toString()}\n\n'
            'Make sure:\n'
            '• You are logged in\n'
            '• Backend is running\n'
            '• Device and Mac on same WiFi';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
