import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _cookieToken; // The _arl cookie token
  String? _xsrfToken; // The XSRF token from response

  // Get stored cookie token (_arl)
  Future<String?> getCookieToken() async {
    if (_cookieToken != null) return _cookieToken;
    final prefs = await SharedPreferences.getInstance();
    _cookieToken = prefs.getString('cookie_token');
    return _cookieToken;
  }

  // Get stored XSRF token
  Future<String?> getXsrfToken() async {
    if (_xsrfToken != null) return _xsrfToken;
    final prefs = await SharedPreferences.getInstance();
    _xsrfToken = prefs.getString('xsrf_token');
    return _xsrfToken;
  }

  // Save tokens (called after login)
  Future<void> saveTokens({String? cookieToken, String? xsrfToken}) async {
    final prefs = await SharedPreferences.getInstance();

    if (cookieToken != null) {
      _cookieToken = cookieToken;
      await prefs.setString('cookie_token', cookieToken);
    }

    if (xsrfToken != null) {
      _xsrfToken = xsrfToken;
      await prefs.setString('xsrf_token', xsrfToken);
    }
  }

  // Clear tokens
  Future<void> clearToken() async {
    _cookieToken = null;
    _xsrfToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cookie_token');
    await prefs.remove('xsrf_token');
  }

  // Legacy method for backward compatibility
  Future<String?> getToken() => getCookieToken();

  Future<void> saveToken(String token) => saveTokens(cookieToken: token);

  // Get headers with authentication
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final cookieToken = await getCookieToken();
      final xsrfToken = await getXsrfToken();

      if (cookieToken != null && xsrfToken != null) {
        // Backend expects: Cookie with _arl token and X-XSRF-TOKEN header
        headers['Cookie'] = '_arl=$cookieToken';
        headers['X-XSRF-TOKEN'] = xsrfToken;
      }
    }

    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(
    String url, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      print('🌐 POST Request to: $url');
      print('📦 Request body: ${jsonEncode(body)}');

      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      print('✅ Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      // Extract cookie from Set-Cookie header (for login responses)
      if (!requiresAuth && response.headers['set-cookie'] != null) {
        _extractAndSaveCookie(response.headers['set-cookie']!);
      }

      return _handleResponse(response);
    } catch (e) {
      print('❌ POST Error to $url: ${e.toString()}');
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Extract cookie token from Set-Cookie header
  void _extractAndSaveCookie(String setCookieHeader) {
    try {
      // Format: _arl=token_value; Path=/; HttpOnly
      final cookies = setCookieHeader.split(';');
      for (var cookie in cookies) {
        if (cookie.trim().startsWith('_arl=')) {
          final cookieValue = cookie.trim().substring(5); // Remove '_arl='
          saveTokens(cookieToken: cookieValue);
          break;
        }
      }
    } catch (e) {
      print('Error extracting cookie: $e');
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.connectTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String url, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: requiresAuth);
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(ApiConfig.connectTimeout);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Upload file (multipart)
  Future<Map<String, dynamic>> uploadFile(
    String url,
    String filePath,
    String fieldName,
  ) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest('POST', Uri.parse(url));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Cookie'] = 'token=$token';
      }

      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      final streamedResponse =
          await request.send().timeout(ApiConfig.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'error': 'Upload error: ${e.toString()}',
      };
    }
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': body,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'error': body['message'] ?? body['error'] ?? 'Unknown error',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to parse response: ${e.toString()}',
        'statusCode': response.statusCode,
      };
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
