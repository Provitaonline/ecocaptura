import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../controllers/capture_controller.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';
import 'package:ecocaptura/features/dashboard/data/models/capture_model.dart';
import '../edit_capture_screen.dart';
import 'package:ecocaptura/core/extensions/content_extensions.dart';
import 'dart:convert';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:ecocaptura/core/l10n/app_localizations.dart';

class CaptureList extends StatelessWidget {
  final CaptureController controller;

  const CaptureList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.captures.isEmpty) {
          return Center(
            child: Text(
              context.i18n.noCaptures, 
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          );
        }
        
        // Create the reversed list so the most recent items appear at index 0
        final reversedCaptures = controller.captures.reversed.toList();
        
        // Filter items that can be selected for upload (exclude already uploaded)
        final eligibleCaptures = reversedCaptures.where((c) => c.status != CaptureStatus.uploaded).toList();
        final bool allEligibleReady = eligibleCaptures.isNotEmpty && 
            eligibleCaptures.every((c) => c.status == CaptureStatus.ready);

        return Column(
          children: [
            // Select All Header Bar
            if (eligibleCaptures.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 28,
                child: Row(
                  children: [
                    // Empty space mirroring the 85px thumbnail + 12px gap
                    const SizedBox(width: 97),
                    // Title text filling the details column width
                    Expanded(
                      child: Text(
                        context.i18n.selectAll,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Master toggle aligned with Card IconButton
                    SizedBox(
                      width: 48, // Standard IconButton width
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          allEligibleReady ? Icons.check_circle : Icons.circle_outlined,
                          color: allEligibleReady ? Colors.teal : Colors.grey,
                          size: 24,
                        ),
                        onPressed: () async {
                          final targetStatus = allEligibleReady
                              ? CaptureStatus.inProgress
                              : CaptureStatus.ready;
                          for (var item in eligibleCaptures) {
                            if (item.status != targetStatus) {
                              await controller.updateCapture(item.copyWith(status: targetStatus));
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            
            // Capture List View
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 88.0),
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
                              SnackBar(content: Text(context.i18n.captureDeleted)),
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
                      onTap: () async {
                        final String id = item.id!;
                        final fullCapture = await StorageManager().loadCapture(id);
                        
                        if (fullCapture != null && context.mounted) {
                          final bool readOnly = item.status != CaptureStatus.inProgress;
                          
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CaptureEditorScreen(
                                controller: controller,
                                existingCapture: fullCapture,
                                isReadOnly: readOnly, 
                              ),
                            ),
                          );
                        }
                      },
                      onLongPress: () async {
                        HapticFeedback.lightImpact();
                        final String id = item.id!;
                        final fullCapture = await StorageManager().loadCapture(id);

                        if (fullCapture != null) {
                          final (zipPath, count) = await _createZip(fullCapture);

                          if (!context.mounted) return;
                          
                          final l10n = AppLocalizations.of(context)!;
                          final shareText = l10n.exportCaptureMessage(id, count);
                          
                          await SharePlus.instance.share(
                            ShareParams(
                              files: [XFile(zipPath)],
                              text: shareText,
                            ),
                          );

                          await File(zipPath).delete();
                        } else {
                          debugPrint("Error: Could not load capture for export.");
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                        cacheWidth: 170, 
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
                                    Text(
                                      context.i18n.photosCount(item.photos.length), 
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
              ),
            ),
          ],
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

Future<(String zipPath, int filesCount)> _createZip(CaptureModel capture) async {
  final tempDir = await getTemporaryDirectory();
  final zipFilePath = '${tempDir.path}/capture_${capture.id}.zip';
  int filesAdded = 0;
  
  try {
    final Map<String, dynamic> jsonData = capture.toJson();
    
    if (jsonData.containsKey('photos') && jsonData['photos'] is List) {
      for (var photo in jsonData['photos']) {
        if (photo is Map && photo.containsKey('imagePath') && photo['imagePath'] != null) {
          final String fullPath = photo['imagePath'];
          photo['imagePath'] = fullPath.split(Platform.pathSeparator).last;
        }
      }
    }

    const encoderJson = JsonEncoder.withIndent('  ');
    final jsonString = encoderJson.convert(jsonData);
    final jsonBytes = utf8.encode(jsonString);

    final encoder = ZipFileEncoder();
    encoder.create(zipFilePath);

    encoder.addArchiveFile(
      ArchiveFile('metadata.json', jsonBytes.length, jsonBytes),
    );

    for (var photo in capture.photos) {
      if (photo.imagePath == null) continue;
      
      final file = File(photo.imagePath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final fileName = file.uri.pathSegments.last;
        
        encoder.addArchiveFile(
          ArchiveFile(fileName, bytes.length, bytes),
        );
        filesAdded++;
        debugPrint('Added $fileName to archive.');
      }
    }
    
    encoder.close();

    final zipFile = File(zipFilePath);
    if (await zipFile.exists() && await zipFile.length() > 0) {
      debugPrint('Export complete: ${zipFile.path} (${await zipFile.length()} bytes)');
    } 
  } catch (e) {
    debugPrint('Export failed: $e');
  }
  
  return (zipFilePath, filesAdded);
}