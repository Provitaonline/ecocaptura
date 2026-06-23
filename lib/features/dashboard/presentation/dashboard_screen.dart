import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/l10n/app_localizations.dart';
import '../../../../core/services/telemetry_service.dart';
import 'controllers/capture_controller.dart';
// Import your new modular components
import 'widgets/dashboard_drawer.dart';
import 'widgets/captura_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TelemetryService _telemetryService = TelemetryService();
  final CaptureController _captureController = CaptureController();
  StreamSubscription<double>? _tiltSubscription;

  double _tiltY = 0.0;
  final double _heading = 0.0;
  final String _gpsInfo = "Waiting for GNSS satellite lock...";

  @override
  void initState() {
    super.initState();
    _captureController.loadCaptures();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _tiltSubscription = _telemetryService.startTiltStream().listen((tilt) {
          setState(() { _tiltY = tilt; });
        });
      }
    });
  }

  @override
  void dispose() {
    _tiltSubscription?.cancel();
    _telemetryService.stopTiltStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              // Logo restored
              Icon(Icons.eco, color: Colors.teal.shade300, size: 28),
              const SizedBox(width: 8),
              Text(
                i18n.appTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
      // Drawer is now modularized
      endDrawer: DashboardDrawer(i18n: i18n),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDataCard("🧭 Compass Heading", "${_heading.toStringAsFixed(1)}°"),
            const SizedBox(height: 12),
            _buildDataCard("📐 Normalized Device Tilt", "Current Tilt: ${_tiltY.toStringAsFixed(1)}°"),
            const SizedBox(height: 12),
            _buildDataCard("🌐 GPS Coordinates", _gpsInfo),
            const SizedBox(height: 12),
            
            // List is now modularized
            const Divider(height: 40),
            Text(i18n.recentCapturas, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            CapturaList(controller: _captureController, i18n: i18n),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text(i18n.btnNewCaptura),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildDataCard(String title, String content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(content, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}