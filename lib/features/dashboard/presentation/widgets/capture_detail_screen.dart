import 'package:flutter/material.dart';

class CapturaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> capture;

  const CapturaDetailScreen({super.key, required this.capture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(capture['description'] ?? 'Capture Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Timestamp: ${capture['timestamp']}", 
                 style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            // Add more detail fields here as your model expands
            Text("Full Data Payload:", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(capture.toString(), style: const TextStyle(fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}