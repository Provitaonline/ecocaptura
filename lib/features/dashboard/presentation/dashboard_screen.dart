import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/services/telemetry_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TelemetryService _telemetryService = TelemetryService();
  StreamSubscription<double>? _tiltSubscription;

  // Preserved state metrics
  double _tiltY = 0.0;
  final double _heading = 0.0; // Ready for compass package later
  final String _gpsInfo = "Waiting for GNSS satellite lock...";
  final String _cameraInfo = "Camera pipeline closed (Idle)";

  @override
  void initState() {
    super.initState();
    // Subscribe to your isolated telemetry stream engine on boot
    _tiltSubscription = _telemetryService.startTiltStream().listen((tilt) {
      setState(() {
        _tiltY = tilt;
      });
    });
  }

  @override
  void dispose() {
    // Always clean up stream channels to avoid background battery drain
    _tiltSubscription?.cancel();
    _telemetryService.stopTiltStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ecocaptura Live HUD')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          key: const Key('main_padding'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDataCard("🧭 Compass Heading", "${_heading.toStringAsFixed(1)}°"),
              const SizedBox(height: 12),
              _buildDataCard(
                "📐 Normalized Device Tilt", 
                "Current Tilt: ${_tiltY.toStringAsFixed(1)}°\n"
                "Orientation: ${MediaQuery.of(context).orientation == Orientation.portrait ? 'Portrait (Upright)' : 'Landscape (Rotated)'}"
              ),
              const SizedBox(height: 12),
              _buildDataCard("🌐 GPS Coordinates", _gpsInfo),
              const SizedBox(height: 12),
              _buildDataCard("📸 Optics Diagnostic", _cameraInfo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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