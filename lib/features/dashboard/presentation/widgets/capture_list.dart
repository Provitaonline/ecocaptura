import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/capture_controller.dart';
import '../../data/services/storage_manager.dart';
import '../edit_capture_screen.dart';
import '../../../../core/extensions/content_extensions.dart';

class CaptureList extends StatelessWidget {
  final CaptureController controller;

  const CaptureList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.captures.isEmpty) {
          return Text(context.i18n.noCaptures, style: const TextStyle(fontStyle: FontStyle.italic));
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
                  title: Text(item['description'] ?? context.i18n.unnamedCapture),
                  subtitle: Text(item['timestamp'] ?? ''),
                  leading: const Icon(Icons.photo_library),
                  // Inside your list item's onTap
                  onTap: () async {
                    final int id = item['id'];
                    final fullCapture = await StorageManager().loadCapture(id);
                    
                    if (fullCapture != null && context.mounted) {
                      // 3. Open the editor with the full, detailed model
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CaptureEditorScreen(
                            controller: controller,
                            existingCapture: fullCapture,
                          ),
                        ),
                      );
                    }
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