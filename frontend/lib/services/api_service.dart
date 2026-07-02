import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator, or your local machine IP for physical device
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  static String? _accessToken;

  // Save tokens to SharedPreferences
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  // Clear tokens on logout
  static Future<void> clearTokens() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  // Load access token from local cache
  static Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    return _accessToken;
  }

  // Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  // Perform API Refresh Token handshake
  static Future<bool> refreshTokens() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final newAccessToken = body['accessToken'];
        final newRefreshToken = body['refreshToken'] ?? refreshToken; // Fallback if refresh token wasn't rotated
        await saveTokens(newAccessToken, newRefreshToken);
        return true;
      }
    } catch (e) {
      // Network error or server unreachable
    }

    await clearTokens();
    return false;
  }

  // Helper function to build auth headers
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Core HTTP GET Request with automatic retry on token expiry
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    var headers = await _getHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 401) {
      final refreshed = await refreshTokens();
      if (refreshed) {
        headers = await _getHeaders();
        response = await http.get(url, headers: headers);
      }
    }
    return response;
  }

  // Core HTTP POST Request with automatic retry on token expiry
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    var headers = await _getHeaders();
    var response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 401) {
      final refreshed = await refreshTokens();
      if (refreshed) {
        headers = await _getHeaders();
        response = await http.post(url, headers: headers, body: jsonEncode(body));
      }
    }
    return response;
  }

  // Core HTTP PATCH Request
  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    var headers = await _getHeaders();
    var response = await http.patch(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 401) {
      final refreshed = await refreshTokens();
      if (refreshed) {
        headers = await _getHeaders();
        response = await http.patch(url, headers: headers, body: jsonEncode(body));
      }
    }
    return response;
  }

  // Core HTTP DELETE Request
  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    var headers = await _getHeaders();
    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 401) {
      final refreshed = await refreshTokens();
      if (refreshed) {
        headers = await _getHeaders();
        response = await http.delete(url, headers: headers);
      }
    }
    return response;
  }
}
