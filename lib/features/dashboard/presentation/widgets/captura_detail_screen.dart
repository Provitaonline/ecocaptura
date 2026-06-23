import 'package:flutter/material.dart';

class CapturaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> captura;

  const CapturaDetailScreen({super.key, required this.captura});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(captura['description'] ?? 'Capture Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Timestamp: ${captura['timestamp']}", 
                 style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            // Add more detail fields here as your model expands
            Text("Full Data Payload:", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(captura.toString(), style: const TextStyle(fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}