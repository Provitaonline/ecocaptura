import 'package:flutter/material.dart';
import '../../../core/extensions/content_extensions.dart';
import 'controllers/capture_controller.dart';
import 'edit_capture_screen.dart';
import 'widgets/dashboard_drawer.dart';
import 'widgets/capture_list.dart';
import 'widgets/sync_button.dart';

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
  void dispose() {
    _captureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                context.i18n.appTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
      endDrawer: const DashboardDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pass the controller here
            SyncButton(captureController: _captureController),
            const SizedBox(height: 10),
            Expanded(
              child: CaptureList(controller: _captureController),
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
        label: Text(context.i18n.btnNewCapture),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.black,
      ),
    );
  }
}