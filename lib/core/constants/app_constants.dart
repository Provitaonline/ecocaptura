class QualityReasons {
  static const String poorGps = 'poor_gps';
  static const String blurry = 'blurry';
  static const String obstructed = 'obstructed';
  static const String other = 'other';

  static const List<String> all = [poorGps, blurry, obstructed, other];
}

class AppInfo {
  static const String orgName = "Provita";
  static const String supportEmail = "rikitraki@gmail.com";
}

class ApiConstants {
  // Authentication Configuration
  static const String googleClientId = '1094233920540-0p9k7abpr4769drbm70f0f33os3caa9c.apps.googleusercontent.com';
  
  // Base URLs
  static const String baseUrl = 'https://fgq9vq9c6j.execute-api.us-east-2.amazonaws.com/Prod';
  
  // Endpoints
  static const String registerEndpoint = '/user';
  static const String tokenEndpoint = '/token';
}