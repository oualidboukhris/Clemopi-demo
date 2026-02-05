/// Database Configuration for Direct MySQL Connection
/// Use this for development mode when phone and Mac are on the same network
class DatabaseConfig {
  // Your Mac's IP address on the local network
  static const String host = '10.24.84.32';

  // MySQL port (exposed by Docker)
  static const int port = 3306;

  // Database name
  static const String database = 'clemopi_db';

  // Mobile user credentials (created for remote access)
  static const String username = 'mobile_user';
  static const String password = 'mobile_password_2024';

  // Connection string for MySQL
  static String get connectionString =>
      'mysql://$username:$password@$host:$port/$database';

  // For debugging
  static void printConfig() {
    print('=== MySQL Database Configuration ===');
    print('Host: $host');
    print('Port: $port');
    print('Database: $database');
    print('Username: $username');
    print('Connection String: $connectionString');
    print('====================================');
  }
}
