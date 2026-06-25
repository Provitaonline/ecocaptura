import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/capture_model.dart';

class StorageManager {
  static const String _indexFileName = 'index.json';

  Future<Directory> _getStorageDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    return docDir;
  }

  // Save or Update a single full capture
  Future<void> saveCapture(CaptureModel model) async {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/capture_${model.id}.json');
    await file.writeAsString(jsonEncode(model.toJson()));
  }

  // Load a specific capture
  Future<CaptureModel?> loadCapture(int id) async {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/capture_$id.json');
    if (!await file.exists()) return null;
    
    final jsonString = await file.readAsString();
    return CaptureModel.fromJson(jsonDecode(jsonString));
  }

// Delete a capture (along with its physical images and index entry)
  Future<void> deleteCapture(int id) async {
    // 1. Load the full model to extract the list of physical photo files
    final model = await loadCapture(id);
    if (model != null) {
      try {
        // Loop through every PhotoEntry attached to this capture
        for (var photo in model.photos) {
          final pathString = photo.imagePath; // Matches your exact property name
          
          if (pathString != null && pathString.isNotEmpty) {
            final imageFile = File(pathString);
            if (await imageFile.exists()) {
              await imageFile.delete();
              debugPrint("Deleted physical photo file: $pathString");
            }
          }
        }
      } catch (e) {
        debugPrint("Failed to clear physical photo files: $e");
      }
    }

    // 2. Delete the individual text-based capture JSON file
    final dir = await _getStorageDir();
    final file = File('${dir.path}/capture_$id.json');
    if (await file.exists()) await file.delete();
    
    // 3. Remove it from the main index file tracking list
    final index = await getIndex();
    index.removeWhere((item) => item['id'] == id);
    await _saveIndex(index);
  }

  // Index Management
  Future<List<Map<String, dynamic>>> getIndex() async {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/$_indexFileName');
    if (!await file.exists()) return [];
    
    final jsonString = await file.readAsString();
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  Future<void> _saveIndex(List<Map<String, dynamic>> index) async {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/$_indexFileName');
    await file.writeAsString(jsonEncode(index));
  }

  Future<void> addOrUpdateIndex(CaptureModel model) async {
    final index = await getIndex();
    final summary = {
      'id': model.id,
      'timestamp': model.timestamp?.toIso8601String(),
      'description': model.description,
      'status': model.status.index,
    };

    // Update if exists, else append
    int existingIndex = index.indexWhere((i) => i['id'] == model.id);
    if (existingIndex != -1) {
      index[existingIndex] = summary;
    } else {
      index.add(summary);
    }
    await _saveIndex(index);
  }
}