import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/captura_model.dart';

class StorageManager {
  static const String _indexFileName = 'index.json';

  Future<Directory> _getStorageDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    return docDir;
  }

  // Save or Update a single full capture
  Future<void> saveCaptura(CapturaModel model) async {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/capture_${model.id}.json');
    await file.writeAsString(jsonEncode(model.toJson()));
  }

  // Load a specific capture
  Future<CapturaModel?> loadCaptura(int id) async {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/capture_$id.json');
    if (!await file.exists()) return null;
    
    final jsonString = await file.readAsString();
    return CapturaModel.fromJson(jsonDecode(jsonString));
  }

  // Delete a capture (and remove from index)
  Future<void> deleteCaptura(int id) async {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/capture_$id.json');
    if (await file.exists()) await file.delete();
    
    // Also remove from index
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

  Future<void> addOrUpdateIndex(CapturaModel model) async {
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