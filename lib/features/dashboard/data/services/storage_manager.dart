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
  Future<void> deleteCapture(int id) async {
    final allCaptures = await loadAllCaptures();
    final target = allCaptures.firstWhere((c) => c.id == id, orElse: () => null as dynamic);
    
    // Physical cleanup
    for (var photo in target.photos) {
      final imageFile = File(photo.imagePath ?? '');
      if (await imageFile.exists()) await imageFile.delete();
    }
    
    allCaptures.removeWhere((c) => c.id == id);
    await _saveAll(allCaptures);
  }

  Future<void> _saveAll(List<CaptureModel> captures) async {
    final file = await _getFile();
    // Serialize the list of objects
    final jsonString = jsonEncode(captures.map((c) => c.toJson()).toList());
    await file.writeAsString(jsonString);
  }


  // --- API BRIDGE: for current UI compatibility ---

  // Replaces the old Map-based getIndex()
  Future<List<Map<String, dynamic>>> getIndex() async {
    final list = await loadAllCaptures();
    return list.map((c) => c.toJson()).toList();
  }

  // Restored: Allows your existing code to keep calling addOrUpdateIndex()
  Future<void> addOrUpdateIndex(CaptureModel model) async {
    await saveCapture(model); // Redirects to your new, clean object-based save
  }

  // Restored: Allows your existing code to keep calling loadCapture()
  Future<CaptureModel?> loadCapture(int id) async {
    final all = await loadAllCaptures();
    return all.firstWhere((c) => c.id == id, orElse: () => null as dynamic);
  }
  
}