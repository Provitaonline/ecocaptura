import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ecocaptura/backend/user_api.dart';
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum AuthResult { success, cancelled, failed }

class AuthService {
  // Singleton pattern
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<bool> isAuthenticatedNotifier = ValueNotifier<bool>(false);
  final _secureStorage = const FlutterSecureStorage();
  final _userApi = UserApi();

  // Storage keys
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUsername = 'current_username';

  Future<void> init() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: ApiConstants.googleClientId,
    );
    await checkInitialAuth();
  }

  Future<bool> isAuthenticated() async {
    // A user is considered authenticated if we have a valid refresh token stored
    return (await getStoredRefreshToken()) != null;
  }

  /// Helper to get the ID token without redundant prompts
  Future<String?> getGoogleIdToken() async {
    try {
      final GoogleSignInAccount? existingAccount = 
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      
      final GoogleSignInAccount account = existingAccount ?? 
          await GoogleSignIn.instance.authenticate();
      
      final GoogleSignInAuthentication auth = account.authentication;
      
      return auth.idToken;
    } catch (e) {
      debugPrint('Google Token Error: $e');
      return null;
    }
  }

  String? _cachedIdToken;

  Future<AuthResult> loginWithGoogle({String? username}) async {
    try {
      final String? idToken = _cachedIdToken ?? await getGoogleIdToken();
      
      if (idToken == null) return AuthResult.cancelled;
      
      _cachedIdToken = idToken; 

      if (username == null) {
        var response = await _userApi.validateUser(idToken);

        debugPrint('DEBUG validateUser response: $response');

        if (response['status'] == 200) {
          final String resolvedUsername = response['user']['username'];
          
          // Expecting backend to return both tokens upon login validation
          final String accessToken = response['accessToken'];
          final String refreshToken = response['refreshToken'];

          await _saveSession(
            accessToken: accessToken, 
            refreshToken: refreshToken, 
            username: resolvedUsername,
          );
          
          _cachedIdToken = null; 
          return AuthResult.success;
        }
        return AuthResult.failed;
      } 
      
      var regResponse = await _userApi.registerUser(idToken, username);
      if (regResponse['status'] == 201) {
        final String resolvedUsername = regResponse['user']['username'];
        
        final String accessToken = regResponse['accessToken'];
        final String refreshToken = regResponse['refreshToken'];

        await _saveSession(
          accessToken: accessToken, 
          refreshToken: refreshToken, 
          username: resolvedUsername,
        );
        
        _cachedIdToken = null; 
        return AuthResult.success;
      }

      return AuthResult.failed;
    } catch (e) {
      debugPrint('Auth error: $e');
      return AuthResult.failed;
    }
  }

  Future<void> _saveSession({
    required String accessToken, 
    required String refreshToken, 
    required String username,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
    await _secureStorage.write(key: _keyUsername, value: username);
    isAuthenticatedNotifier.value = true;
  }

  Future<void> checkInitialAuth() async {
    isAuthenticatedNotifier.value = await isAuthenticated();
  }

  Future<void> logout() async {
    await GoogleSignIn.instance.signOut();
    await _secureStorage.delete(key: _keyAccessToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyUsername);
    _cachedIdToken = null;
    isAuthenticatedNotifier.value = false;
  }

  /// Get the short-lived access token for API requests
  Future<String?> getStoredAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  /// Get the long-lived refresh token for session recovery & refreshing
  Future<String?> getStoredRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  Future<String?> getStoredUsername() async {
    return await _secureStorage.read(key: _keyUsername);
  }

  /// Executes an HTTP request with automatic access token injection and 401 retry-on-refresh logic.
  Future<http.Response> authenticatedRequest(
    Future<http.Response> Function(String accessToken) requestFn,
  ) async {
    String? accessToken = await _secureStorage.read(key: _keyAccessToken);
    
    // If access token is missing entirely, check if we can refresh right away
    if (accessToken == null) {
      debugPrint('[AuthService] Access token missing. Attempting session recovery via refresh token...');
      final refreshed = await _refreshTokens();
      if (refreshed) {
        accessToken = await _secureStorage.read(key: _keyAccessToken);
      }
      
      if (accessToken == null) {
        throw Exception('MissingToken: No active session available. Please log in.');
      }
    }

    // First attempt with current access token
    var response = await requestFn(accessToken);

    // If unauthorized (covers expired 'InvalidToken' or revoked sessions), attempt refresh once
    if (response.statusCode == 401) {
      debugPrint('[AuthService] Received 401 Unauthorized (InvalidToken/Expired). Attempting token refresh...');
      final refreshed = await _refreshTokens();
      
      if (refreshed) {
        accessToken = await _secureStorage.read(key: _keyAccessToken);
        if (accessToken != null) {
          debugPrint('[AuthService] Token refreshed successfully. Retrying request...');
          response = await requestFn(accessToken);
        }
      } else {
        throw Exception('InvalidToken: Session expired or invalid. Please log in again.');
      }
    }

    return response;
  }

  /// Refreshes access tokens using the stored refresh token
  Future<bool> _refreshTokens() async {
    try {
      final refreshToken = await _secureStorage.read(key: _keyRefreshToken);
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/refresh'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _secureStorage.write(key: _keyAccessToken, value: data['accessToken']);
        if (data['refreshToken'] != null) {
          await _secureStorage.write(key: _keyRefreshToken, value: data['refreshToken']);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[AuthService] Error refreshing tokens: $e');
      return false;
    }
  }
}