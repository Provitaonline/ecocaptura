import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../backend/user_api.dart';
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';

enum AuthResult { success, cancelled, failed }

class AuthService {
  // Singleton pattern
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ValueNotifier<bool> isAuthenticatedNotifier = ValueNotifier<bool>(false);
  final _secureStorage = const FlutterSecureStorage();
  final _userApi = UserApi();

  Future<void> init() async {
    await GoogleSignIn.instance.initialize(
      serverClientId: ApiConstants.googleClientId,
    );
    await checkInitialAuth();
  }

  /// RESTORED: Required by your UI components
  Future<bool> isAuthenticated() async {
    return (await getStoredToken()) != null;
  }

  /// Helper to get the ID token without redundant prompts
  Future<String?> getGoogleIdToken() async {
    try {
      // 1. Attempt to restore an existing session.
      // This returns the account if cached, or null if no session exists.
      final GoogleSignInAccount? existingAccount = 
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      
      // 2. Use the existing account, or prompt for a new one if null.
      final GoogleSignInAccount account = existingAccount ?? 
          await GoogleSignIn.instance.authenticate();
      
      // 3. Access authentication details (NO 'await' here)
      // This is the direct access that matches your version's signature.
      final GoogleSignInAuthentication auth = account.authentication;
      
      return auth.idToken;
    } catch (e) {
      print('Google Token Error: $e');
      return null;
    }
  }

  String? _cachedIdToken;

  Future<AuthResult> loginWithGoogle({String? username}) async {
    try {
      // 1. Prioritize existingIdToken (passed from UI), then our cache, then fetch new.
      final String? idToken = _cachedIdToken ?? await getGoogleIdToken();
      
      if (idToken == null) return AuthResult.cancelled;
      
      // Cache it for potential retry
      _cachedIdToken = idToken; 

      if (username == null) {
        var response = await _userApi.validateUser(idToken);
        if (response['status'] == 200) {
          await _saveSession(response['token']);
          _cachedIdToken = null; // Clear on success
          return AuthResult.success;
        }
        return AuthResult.failed;
      } 
      
      var regResponse = await _userApi.registerUser(idToken, username);
      if (regResponse['status'] == 201) {
        await _saveSession(regResponse['token']);
        _cachedIdToken = null; // Clear on success
        return AuthResult.success;
      }

      return AuthResult.failed;
    } catch (e) {
      print('Auth error: $e');
      return AuthResult.failed;
    }
  }

  Future<void> _saveSession(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
    isAuthenticatedNotifier.value = true;
  }

  Future<void> checkInitialAuth() async {
    isAuthenticatedNotifier.value = await isAuthenticated();
  }

  Future<void> logout() async {
    await GoogleSignIn.instance.signOut();
    await _secureStorage.delete(key: 'jwt_token');
    _cachedIdToken = null;
    isAuthenticatedNotifier.value = false;
  }

  Future<String?> getStoredToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }
}