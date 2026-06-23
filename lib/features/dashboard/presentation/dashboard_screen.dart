import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/l10n/app_localizations.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../../core/l10n/locale_controller.dart';
import 'controllers/capture_controller.dart';

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
      endDrawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal.shade800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    i18n.drawerHeader,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SThemeText(text: i18n.drawerSubtitle, color: Colors.white70),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(i18n.menuPairDevice),
              subtitle: Text(i18n.menuPairSubtitle),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(i18n.menuLanguage),
              subtitle: Text(
                Localizations.localeOf(context).languageCode == 'es' ? 'English' : 'Español',
              ),
              onTap: () {
                Navigator.pop(context);
                final currentLanguage = Localizations.localeOf(context).languageCode;
                LocaleController.instance.setLocale(Locale(currentLanguage == 'es' ? 'en' : 'es'));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(i18n.menuAbout),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
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
            
            const Divider(height: 40),
            Text(i18n.recentCapturas, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            
            ListenableBuilder(
              listenable: _captureController,
              builder: (context, _) {
                if (_captureController.captures.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(i18n.noCapturas, style: const TextStyle(fontStyle: FontStyle.italic)),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _captureController.captures.length,
                  itemBuilder: (context, index) {
                    final item = _captureController.captures[index];
                    return Card(
                      child: ListTile(
                        title: Text(item['description'] ?? i18n.unnamedCapture),
                        subtitle: Text(item['timestamp'] ?? ''),
                        leading: const Icon(Icons.photo_library),
                      ),
                    );
                  },
                );
              },
            ),
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

class SThemeText extends StatelessWidget {
  final String text;
  final Color color;
  const SThemeText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: color, fontSize: 14));
  }
}