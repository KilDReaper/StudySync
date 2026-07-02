import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  // Initialize and check if user has stored tokens
  Future<void> tryAutoLogin() async {
    final token = await ApiService.getAccessToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final response = await ApiService.get('/auth/me');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          _user = UserModel.fromJson(body['data']['user'] ?? body['data']);
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        // Try refreshing if access token expired
        final refreshed = await ApiService.refreshTokens();
        if (refreshed) {
          final retryResponse = await ApiService.get('/auth/me');
          if (retryResponse.statusCode == 200) {
            final body = jsonDecode(retryResponse.body);
            _user = UserModel.fromJson(body['data']['user'] ?? body['data']);
            _status = AuthStatus.authenticated;
          } else {
            _status = AuthStatus.unauthenticated;
          }
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      // Offline fallback: keep token but set status to unauthenticated if connection failed
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // Register a new user
  Future<bool> register(String fullName, String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'fullName': fullName,
        'email': email,
        'password': password,
      });

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['status'] == 'success') {
        final accessToken = body['accessToken'];
        final refreshToken = body['refreshToken'] ?? ''; // Express server might send cookie or in body
        await ApiService.saveTokens(accessToken, refreshToken);
        _user = UserModel.fromJson(body['data']['user'] ?? body['data']);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] ?? 'Registration failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please check your network and backend status.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Log in
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['status'] == 'success') {
        final accessToken = body['accessToken'];
        final refreshToken = body['refreshToken'] ?? '';
        await ApiService.saveTokens(accessToken, refreshToken);
        _user = UserModel.fromJson(body['data']['user'] ?? body['data']);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = body['message'] ?? 'Invalid email or password';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please check your network and backend status.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // Log out
  Future<void> logout() async {
    try {
      await ApiService.post('/auth/logout', {});
    } catch (e) {
      // Proceed with local logout even if server request fails
    }
    await ApiService.clearTokens();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
