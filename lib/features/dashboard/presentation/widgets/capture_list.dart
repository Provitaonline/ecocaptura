import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/capture_controller.dart';
import '../../data/services/storage_manager.dart';
import '../../data/models/capture_model.dart';
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
              key: Key(item.id?.toString() ?? index.toString()),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (context) {
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
              // Full-card tap interaction
              child: InkWell(
                onTap: item.status == CaptureStatus.inProgress
                      ? () async {
                          final int id = item.id!;
                          final fullCapture = await StorageManager().loadCapture(id);
                          
                          if (fullCapture != null && context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CaptureEditorScreen(
                                  controller: controller,
                                  existingCapture: fullCapture,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail Section
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.photos.isNotEmpty
                              ? Image.file(
                                  File(item.photos.first.imagePath as String),
                                  fit: BoxFit.cover,
                                  width: 85,
                                  height: 85,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 85),
                                )
                              : Container(
                                  width: 85,
                                  height: 85,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Details Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.description ?? context.i18n.unnamedCapture,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(item.timestamp!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(3, (index) {
                                  return Icon(
                                    index < (item.qualityScore ?? 0) ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        // Status Toggle
                        IconButton(
                          icon: _getStatusIcon(item.status),
                          // Enabled for everything EXCEPT 'uploaded'
                          onPressed: item.status == CaptureStatus.uploaded 
                              ? null 
                              : () async {
                                  final newStatus = (item.status == CaptureStatus.ready) 
                                      ? CaptureStatus.inProgress 
                                      : CaptureStatus.ready;
                                      
                                  await controller.updateCapture(item.copyWith(status: newStatus));
                                },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Widget _getStatusIcon(CaptureStatus status) {
  return Icon(
    switch (status) {
      CaptureStatus.inProgress => Icons.circle_outlined,
      CaptureStatus.ready      => Icons.check_circle,
      CaptureStatus.uploaded   => Icons.cloud_done,
      CaptureStatus.error      => Icons.error,
    },
    color: switch (status) {
      CaptureStatus.inProgress => Colors.grey,
      CaptureStatus.ready      => Colors.teal,
      CaptureStatus.uploaded   => Colors.blue,
      CaptureStatus.error      => Colors.red,
    },
  );
}