import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/capture_model.dart';

class StorageManager {
  static const String _indexFileName = 'index.json';

  Future<File> _getFile() async {
    final docDir = await getApplicationDocumentsDirectory();
    return File('${docDir.path}/$_indexFileName');
  }

  // Fetch all as Objects
  Future<List<CaptureModel>> loadAllCaptures() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    
    // Map directly to objects
    return jsonList.map((json) => CaptureModel.fromJson(json)).toList();
  }

  // Save/Update Object
  Future<void> saveCapture(CaptureModel model) async {
    final allCaptures = await loadAllCaptures();
    
    final index = allCaptures.indexWhere((c) => c.id == model.id);
    if (index != -1) {
      allCaptures[index] = model;
    } else {
      allCaptures.add(model);
    }
    
    await _saveAll(allCaptures);
  }

  // Delete Object
  Future<void> deleteCapture(String id) async {
    final allCaptures = await loadAllCaptures();
    
    // Find the target safely
    final target = allCaptures.where((c) => c.id == id).firstOrNull;
    if (target == null) return; // Exit early if it doesn't exist
    
    // Physical file cleanup for associated photos
    for (var photo in target.photos) {
      if (photo.imagePath != null && photo.imagePath!.isNotEmpty) {
        final imageFile = File(photo.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
    }
    
    // Remove from list and persist
    allCaptures.removeWhere((c) => c.id == id);
    await _saveAll(allCaptures);
  }

  Future<void> _saveAll(List<CaptureModel> captures) async {
    final file = await _getFile();
    // Serialize the list of objects
    final jsonString = jsonEncode(captures.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  // Retrieve single object
  Future<CaptureModel?> loadCapture(String id) async {
    final all = await loadAllCaptures();
    
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null; // catches StateError if not found
    }
  }
}