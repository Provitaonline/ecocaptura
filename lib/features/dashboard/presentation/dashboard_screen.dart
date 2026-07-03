import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import 'controllers/capture_controller.dart';
import 'edit_capture_screen.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/capture_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CaptureController _captureController = CaptureController();

  @override
  void initState() {
    super.initState();
    _captureController.loadCaptures();
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
      endDrawer: DashboardDrawer(i18n: i18n),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(i18n.recentCaptures, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Expanded(
              child: CaptureList(controller: _captureController, i18n: i18n),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CaptureEditorScreen(
                controller: _captureController,
                existingCapture: null,
              ),
            ),
          );
        },
        label: Text(i18n.btnNewCapture),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.black,
      ),
    );
  }
}