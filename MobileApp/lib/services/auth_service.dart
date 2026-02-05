import 'api_service.dart';
import 'api_config.dart';

class AuthService {
  final ApiService _api = ApiService();

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiConfig.login,
      {
        'username': email, // Backend expects 'username' field
        'password': password,
      },
      requiresAuth: false,
    );

    if (response['success']) {
      // Backend returns xsrfToken in response and sets _arl cookie via Set-Cookie header
      // We need to extract the cookie token from the response headers
      // and the xsrfToken from the response body
      final xsrfToken = response['data']['xsrfToken'];

      // Note: http package doesn't expose Set-Cookie headers easily
      // For now, we'll extract tokens from the response
      // In production, consider using dio package for better cookie handling

      if (xsrfToken != null) {
        // Store both tokens
        // The cookie token would normally come from Set-Cookie header
        // For testing, we'll need to handle this differently
        await _api.saveTokens(xsrfToken: xsrfToken);
      }
    }

    return response;
  }

  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final response = await _api.post(
      ApiConfig.register,
      {
        'email': email,
        'password': password,
        'name': name,
        if (phone != null) 'phone': phone,
      },
      requiresAuth: false,
    );

    if (response['success']) {
      // Save token from response
      final token = response['data']['token'];
      if (token != null) {
        await _api.saveToken(token);
      }
    }

    return response;
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    final response = await _api.post(
      ApiConfig.logout,
      {},
      requiresAuth: true,
    );

    // Clear token regardless of response
    await _api.clearToken();

    return response;
  }

  // Get user data
  Future<Map<String, dynamic>> getUserData(String userId) async {
    return await _api.get(
      ApiConfig.getUser(userId),
      requiresAuth: true,
    );
  }

  // Update user data
  Future<Map<String, dynamic>> updateUserData(
    String userId,
    Map<String, dynamic> data,
  ) async {
    return await _api.put(
      ApiConfig.updateUser(userId),
      data,
      requiresAuth: true,
    );
  }

  // Upload user image
  Future<Map<String, dynamic>> uploadImage(
    String userId,
    String imagePath,
  ) async {
    return await _api.uploadFile(
      ApiConfig.uploadImage(userId),
      imagePath,
      'image',
    );
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _api.isAuthenticated();
  }
}
