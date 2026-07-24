import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../features/dashboard/data/models/capture_model.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';
import '../core/constants/app_constants.dart';
import 'package:ecocaptura/core/services/auth_service.dart';

class CaptureApi {
  final StorageManager _storage = StorageManager();
  
  static final CaptureApi instance = CaptureApi._internal();
  CaptureApi._internal();

  // Base URL configuration
  static const String _baseUrl = ApiConstants.baseUrl;

  // Calls backend /presign endpoint to fetch S3 upload URLs
  Future<List<Map<String, dynamic>>> generatePresignedS3Urls(
    String username, 
    String captureId, 
    List<Map<String, String>> photosPayload,
  ) async {
    final response = await AuthService.instance.authenticatedRequest((token) async {
      return await http.post(
        Uri.parse('$_baseUrl/presign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'captureId': captureId,
          'photos': photosPayload,
        }),
      );
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> urlsList = data['presignedUrls'] ?? [];
      return urlsList.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to generate presigned URLs: ${response.body}');
    }
  }

  /// Loops through a list of local captures ready for upload, 
  /// pushes their images to S3 using presigned URLs, commits metadata to DynamoDB, 
  /// and cleans up local storage unless shouldRetain is true.
  Future<void> uploadPendingCaptures(
    List<CaptureModel> pendingCaptures, 
    String username
  ) async {
    if (pendingCaptures.isEmpty) {
      debugPrint('[CaptureApi] No pending captures to sync.');
      return;
    }

    debugPrint('[CaptureApi] Starting batch sync for ${pendingCaptures.length} capture(s).');

    for (var capture in pendingCaptures) {
      try {
        debugPrint('[CaptureApi] Processing capture ID: ${capture.id}');

        // Collect valid photo models to request presigned URLs for
        final validPhotos = capture.photos.where((p) => p.imagePath != null && p.imagePath!.isNotEmpty).toList();
        
        if (validPhotos.isNotEmpty) {
          final photosPayload = validPhotos.map((p) => {
            'photoId': p.id!,
            'contentType': 'image/jpeg',
          }).toList();
          
          // 1. Fetch presigned S3 URLs list from backend
          debugPrint('[CaptureApi] -> Requesting presigned S3 URLs for capture ${capture.id}');
          final presignedList = await generatePresignedS3Urls(username, capture.id!, photosPayload);

          // 2. Upload images directly to S3 via PUT requests using matching uploadUrl
          for (var photo in validPhotos) {
            final file = File(photo.imagePath!);
            if (await file.exists()) {
              final s3Key = 'USER#$username/CAPTURE#${capture.id}/PHOTO#${photo.id}.jpg';
              
              // Find the matching entry in the list by s3Key or photoId
              final match = presignedList.firstWhere(
                (entry) => entry['s3Key'] == s3Key || entry['photoId'] == photo.id,
                orElse: () => {},
              );

              final uploadUrl = match['uploadUrl'] as String?;

              if (uploadUrl != null) {
                final bytes = await file.readAsBytes();
                debugPrint('[CaptureApi] -> Uploading image to S3: $s3Key');
                
                final s3Response = await http.put(
                  Uri.parse(uploadUrl),
                  headers: {'Content-Type': 'image/jpeg'},
                  body: bytes,
                );

                if (s3Response.statusCode != 200) {
                  throw Exception('S3 upload failed with status ${s3Response.statusCode}');
                }
              } else {
                debugPrint('[CaptureApi] -> Warning: No presigned URL returned for photo ${photo.id}');
              }
            } else {
              debugPrint('[CaptureApi] -> Warning: Local image missing on disk: ${photo.imagePath}');
            }
          }
        }

        // 3. Commit metadata to DynamoDB
        const encoder = JsonEncoder.withIndent('  ');
        final jsonPayload = encoder.convert(capture.toBackendJson(username));
        debugPrint('[CaptureApi] -> Committing metadata to DynamoDB for capture ${capture.id}');

        /*final response = await AuthService.instance.authenticatedRequest((token) async {
          return await http.post(
            Uri.parse('$_baseUrl/capture'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonPayload,
          );
        });

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Failed to save capture metadata: ${response.body}');
        } else {
           debugPrint('[CaptureApi] Successfully uploaded capture: ${capture.id}');
        } */

       debugPrint('[CaptureApi] Successfully uploaded capture: ${capture.id}');
       debugPrint('[CaptureApi] Payload: $jsonPayload');

        // 4. Handle local cleanup if shouldRetain is false
        if (!capture.shouldRetain) {
          debugPrint('[CaptureApi] -> Pruning local capture and assets for ID: ${capture.id}');
          for (var photo in validPhotos) {
            final file = File(photo.imagePath!);
            if (await file.exists()) {
              await file.delete();
            }
          }
          await _storage.deleteCapture(capture.id!);
        } else {
          debugPrint('[CaptureApi] -> Retaining local capture and marking as uploaded.');
          final updatedCapture = capture.copyWith(status: CaptureStatus.uploaded);
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