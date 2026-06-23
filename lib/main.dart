import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  // 1. Hook native window manager bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Globally allow portrait and landscape layouts
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // 3. Launch the orchestrator app
  runApp(const EcocapturaApp());
}