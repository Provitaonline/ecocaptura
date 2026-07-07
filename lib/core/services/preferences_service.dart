import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Static instance to access everywhere
  static late SharedPreferences _prefs;

  // Initialize this at app startup (e.g., in main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Language Getter/Setter
  String? get language => _prefs.getString('language');
  
  Future<void> setLanguage(String value) async {
    await _prefs.setString('language', value);
  }

  // Token Getter/Setter
  String? get token => _prefs.getString('token');
  
  Future<void> setToken(String value) async {
    await _prefs.setString('token', value);
  }
}