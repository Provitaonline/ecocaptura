import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/capture_controller.dart';
import '../../../../core/l10n/app_localizations.dart';
import './capture_detail_screen.dart'; 

class CaptureList extends StatelessWidget {
  final CaptureController controller;
  final AppLocalizations i18n;

  const CaptureList({super.key, required this.controller, required this.i18n});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.captures.isEmpty) {
          return Text(i18n.noCaptures, style: const TextStyle(fontStyle: FontStyle.italic));
        }
        
        // Create the reversed list so the most recent items appear at index 0
        final reversedCaptures = controller.captures.reversed.toList();

        return ListView.builder(
          itemCount: reversedCaptures.length,
          itemBuilder: (context, index) {
            final item = reversedCaptures[index];
            
            return Slidable(
              // Unique key ensures Flutter tracks the correct item when animating or deleting
              key: Key(item['id']?.toString() ?? index.toString()),

              // Configures the slider panel to slide out from the right side (end to start)
              endActionPane: ActionPane(
                motion: const ScrollMotion(), // Elegant, natural slide-in effect
                extentRatio: 0.25, // Stops the slide precisely 25% across the screen
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      // Triggers the deletion logic instantly in your controller
                      controller.deleteCapture(item);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Capture deleted")),
                      );
                    },
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),

              // The main card item that the user interacts with
              child: Card(
                child: ListTile(
                  title: Text(item['description'] ?? i18n.unnamedCapture),
                  subtitle: Text(item['timestamp'] ?? ''),
                  leading: const Icon(Icons.photo_library),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CaptureDetailScreen(capture: item),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}