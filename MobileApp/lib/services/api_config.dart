class ApiConfig {
  // Base URL - Updated with your Mac's current IP address
  // For Android Emulator use: 'http://10.0.2.2:4000/api/v1' (special IP that routes to host)
  // For physical device on same network: Use your Mac's IP address
  static const String baseUrl = 'http://192.168.164.80:4000/api/v1';

  // Alternative IPs:
  // Android Emulator: 'http://10.0.2.2:4000/api/v1'
  // Physical device (current): 'http://10.253.136.199:4000/api/v1'

  // API Endpoints
  static const String login = '$baseUrl/client/login';
  static const String register = '$baseUrl/client/register';
  static const String logout = '$baseUrl/logout';

  static String getUser(String userId) => '$baseUrl/users/$userId';
  static String updateUser(String userId) => '$baseUrl/users/$userId';
  static String uploadImage(String userId) => '$baseUrl/upload/$userId';

  static const String kickscooters = '$baseUrl/kickscooters';
  static String kickscooter(String idScooter) =>
      '$baseUrl/kickscooter/$idScooter';
  static const String updateKeyState = '$baseUrl/kickscooter/key-state';
  static const String unlockScooter = '$baseUrl/kickscooter/unlock';
  static const String lockScooter = '$baseUrl/kickscooter/lock';
  static const String unlockStation = '$baseUrl/kickscooter/station-unlock';
  static const String scooterInfo = '$baseUrl/kickscooter/info';
  static const String downloadExcel = '$baseUrl/downloadExcel';

  // Client endpoints (backend uses /user and /users)
  static const String clients = '$baseUrl/users'; // GET all clients
  static const String createClient = '$baseUrl/user'; // POST create client
  static String client(String userId) =>
      '$baseUrl/user/$userId'; // GET/PUT/DELETE single client

  static const String dashboard = '$baseUrl/dashboard';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
