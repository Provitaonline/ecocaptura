import 'package:flutter/material.dart';
import 'dart:async';
// 1. Point directly to your physical file path
import '../../../core/l10n/app_localizations.dart';
import '../../../../core/services/telemetry_service.dart';
import '../../../core/l10n/locale_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TelemetryService _telemetryService = TelemetryService();
  StreamSubscription<double>? _tiltSubscription;

  // Preserved telemetry metrics
  double _tiltY = 0.0;
  final double _heading = 0.0;
  final String _gpsInfo = "Waiting for GNSS satellite lock...";
  final String _cameraInfo = "Camera pipeline closed (Idle)";

@override
void initState() {
  super.initState();
  
  // Wait until the initial layout frame is cleanly drawn, then bind the sensor
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _tiltSubscription = _telemetryService.startTiltStream().listen((tilt) {
        setState(() {
          _tiltY = tilt;
        });
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
    // 2. Initialize the translation mapping hook
    final i18n = AppLocalizations.of(context)!;

    return Scaffold(
      // 1. Top Navbar Config
      appBar: AppBar(
        titleSpacing: 0, // Tightens space between logo and edge
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              // Placeholder for your brand icon asset later
              Icon(Icons.eco, color: Colors.teal.shade300, size: 28),
              const SizedBox(width: 8),
              Text(
                i18n.appTitle, // Localized
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        // Flutter automatically displays the hamburger menu button on the right 
        // if actions are clear or if the drawer is configured on the end side.
      ),

      // 2. Slide-out Hamburger Menu (End side displays on the right edge)
      endDrawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal.shade800,
              ),
              child: Column( // Removed const to allow dynamic lookups
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    i18n.drawerHeader, // Localized
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SThemeText(text: i18n.drawerSubtitle, color: Colors.white70), // Localized
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: Text(i18n.menuPairDevice), // Localized
              subtitle: Text(i18n.menuPairSubtitle), // Localized
              onTap: () {
                Navigator.pop(context); // Close drawer execution window
                // TODO: Route to QR scanning pipeline
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              // 1. Dynamic title text depending on active language context
              title: Text(i18n.menuLanguage), 
              
              // 2. Check current locale to show what language the user can switch *to*
              subtitle: Text(
                Localizations.localeOf(context).languageCode == 'es'
                    ? 'English'
                    : 'Español',
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer execution window
                
                // 3. Toggle language logic execution
                final currentLanguage = Localizations.localeOf(context).languageCode;
                if (currentLanguage == 'es') {
                  LocaleController.instance.setLocale(const Locale('en'));
                } else {
                  LocaleController.instance.setLocale(const Locale('es'));
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(i18n.menuAbout), // Localized
              onTap: () {
                Navigator.pop(context);
                // TODO: Show application credits dialog window
              },
            ),
          ],
        ),
      ),

      // 3. Main Body Container Shell
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

      // 4. Persistent Add Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Trigger workflow context step 1 layout initialization
        },
        label: Text(i18n.btnNewCaptura), // Localized
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

/// Simple sub-widget helper to keep layout trees clean of messy style nests
class SThemeText extends StatelessWidget {
  final String text;
  final Color color;
  const SThemeText({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: color, fontSize: 14));
  }
}