import 'package:flutter/material.dart';
import '../controllers/capture_controller.dart';
import '../../../../core/l10n/app_localizations.dart';
import 'capture_detail_screen.dart'; // Import your new detail screen

class CapturaList extends StatelessWidget {
  final CaptureController controller;
  final AppLocalizations i18n;

  const CapturaList({super.key, required this.controller, required this.i18n});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.captures.isEmpty) {
          return Text(i18n.noCapturas, style: const TextStyle(fontStyle: FontStyle.italic));
        }
        
        // 1. Create the reversed list here
        final reversedCaptures = controller.captures.reversed.toList();

        return ListView.builder(
          itemCount: reversedCaptures.length,
          itemBuilder: (context, index) {
            // 2. Use the reversed list to grab the item
            final item = reversedCaptures[index];
            
            return Card(
              child: ListTile(
                title: Text(item['description'] ?? i18n.unnamedCapture),
                subtitle: Text(item['timestamp'] ?? ''),
                leading: const Icon(Icons.photo_library),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CapturaDetailScreen(capture: item),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}