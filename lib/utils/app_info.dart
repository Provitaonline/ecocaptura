import 'package:package_info_plus/package_info_plus.dart';

class AppInfoService {
  static String? _cachedVersion;

  /// Returns "version+buildNumber" (e.g., "1.0.1+1")
  static Future<String> getAppVersion() async {
    if (_cachedVersion != null) return _cachedVersion!;

    final info = await PackageInfo.fromPlatform();
    _cachedVersion = "${info.version}+${info.buildNumber}";
    return _cachedVersion!;
  }
}