import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/l10n/locale_controller.dart';
import './core/services/preferences_service.dart';
import 'package:path_provider/path_provider.dart';
import 'core/services/auth_service.dart';

import './features/dashboard/presentation/controllers/capture_controller.dart';
import './features/dashboard/data/models/capture_model.dart';
import 'package:uuid/uuid.dart';

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

  // Stress test data
  final captureController = CaptureController();
  await captureController.loadCaptures();

  // Temporary stress test injection
  if (captureController.captures.isEmpty) {
    final fakeList = _generateFakeCaptures(1000);
    for (var capture in fakeList) {
      await captureController.addCapture(capture); // or your specific save method
    }
  }

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

List<CaptureModel> _generateFakeCaptures(int count) {
  final uuid = const Uuid();
  final List<CaptureModel> mockCaptures = [];

  for (int i = 1; i <= count; i++) {
    mockCaptures.add(
      CaptureModel(
        id: uuid.v4(),
        description: 'Stress test capture record #$i with some sample field notes.',
        photos: [],
        qualityScore: 3,
        //qualityReason: i % 2 == 0 ? 'Sample quality reason for record $i' : null,
        status: CaptureStatus.inProgress,
        timestamp: DateTime.now().subtract(Duration(minutes: i * 15)),
        shouldRetain: false,
      ),
    );
  }
  return mockCaptures;
}