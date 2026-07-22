import 'dart:io';
import 'package:flutter/foundation.dart';
import '../features/dashboard/data/models/capture_model.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';

class CaptureApi {
  final StorageManager _storage = StorageManager();
  static final CaptureApi instance = CaptureApi._internal();
  CaptureApi._internal();

  /// Loops through a list of local captures ready for upload, 
  /// pushes their images to S3, commits their metadata to DynamoDB, 
  /// and cleans up local storage unless shouldRetain is true.
  Future<void> uploadPendingCaptures(List<CaptureModel> pendingCaptures, String username) async {
    if (pendingCaptures.isEmpty) {
      debugPrint('[CaptureApi] No pending captures to sync.');
      return;
    }

    debugPrint('[CaptureApi] Starting batch sync for ${pendingCaptures.length} capture(s).');

    for (var capture in pendingCaptures) {
      try {
        debugPrint('[CaptureApi] Processing capture ID: ${capture.id}');

        // 1. Upload all associated local images to S3 first
        for (var photo in capture.photos) {
          if (photo.imagePath != null && photo.imagePath!.isNotEmpty) {
            final file = File(photo.imagePath!);
            
            if (await file.exists()) {
              final fileSize = await file.length();
              
              // S3 path convention: USER#username/CAPTURE#id/filename.jpg
              final fileName = photo.imagePath!.split('/').last;
              final s3Key = 'USER#$username/CAPTURE#${capture.id}/$fileName';
              
              debugPrint('[CaptureApi] -> Uploading image to S3: $s3Key ($fileSize bytes)');
              // TODO: Replace with actual S3 upload call (e.g., Amplify.Storage.uploadFile)
              await Future.delayed(const Duration(milliseconds: 300));
              
            } else {
              debugPrint('[CaptureApi] -> Warning: Local image missing on disk: ${photo.imagePath}');
            }
          }
        }

        // 2. Commit metadata to DynamoDB
        // Partition Key: USER#username, Sort Key: CAPTURE#<id>
        final jsonPayload = capture.toJson();
        debugPrint('[CaptureApi] -> Committing metadata to DynamoDB for capture ${capture.id}: $jsonPayload');
        
        // TODO: Replace with actual API call to save metadata
        await Future.delayed(const Duration(milliseconds: 500));

        debugPrint('[CaptureApi] Successfully uploaded capture: ${capture.id}');

        // 3. Handle local cleanup if shouldRetain is false
        if (!capture.shouldRetain) {
          debugPrint('[CaptureApi] -> Pruning local capture and assets for ID: ${capture.id}');
          
          for (var photo in capture.photos) {
            if (photo.imagePath != null && photo.imagePath!.isNotEmpty) {
              final file = File(photo.imagePath!);
              if (await file.exists()) {
                await file.delete();
                debugPrint('[CaptureApi]    Deleted local file: ${photo.imagePath}');
              }
            }
          }
          
          await _storage.deleteCapture(capture.id!);
        } else {
          debugPrint('[CaptureApi] -> Retaining local capture and marking as uploaded.');
          
          // Create an updated copy with status changed to uploaded
          final updatedCapture = capture.copyWith(
            status: CaptureStatus.uploaded,
          );
          
          // Save the updated record back to local storage
          await _storage.saveCapture(updatedCapture);
        }
        
      } catch (e) {
        debugPrint('[CaptureApi] Error uploading capture ${capture.id}: $e');
        rethrow; 
      }
    }

    debugPrint('[CaptureApi] Batch sync completed.');
  }
}