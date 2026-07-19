import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/l10n/locale_controller.dart';
import './core/services/preferences_service.dart';
import 'package:path_provider/path_provider.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferencesService.init();

  final savedLanguage = PreferencesService().language;
  final systemLanguage = Platform.localeName.split('_')[0]; // e.g., 'pt'
  
  // Supported languages
  const supported = ['en', 'es'];

  final String finalLocale = savedLanguage ?? (supported.contains(systemLanguage) ? systemLanguage : 'en');

  LocaleController.instance.setLocale(Locale(finalLocale));
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  clearTempFiles();

  await AuthService.instance.init();

  runApp(const EcocapturaApp());
}

Future<void> clearTempFiles() async {
  final tempDir = await getTemporaryDirectory();
  final files = await tempDir.list().toList();
  for (final file in files) {
    if (file.path.endsWith('.zip')) {
      await file.delete();
    }
  }
}