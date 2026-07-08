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

  Future<CaptureModel?> loadCapture(int id) async {
    final list = await getIndex();
    final item = list.firstWhere((i) => i['id'] == id, orElse: () => {});
    
    if (item.isEmpty) return null;
    
    return CaptureModel.fromJson(item); 
  }

  Future<void> saveCapture(CaptureModel model) async {
    await addOrUpdateIndex(model);
  }

  Future<List<Map<String, dynamic>>> getIndex() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    final jsonString = await file.readAsString();
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  Future<void> addOrUpdateIndex(CaptureModel model) async {
    final list = await getIndex();
    final summary = {
      'id': model.id,
      'timestamp': model.timestamp?.toIso8601String(),
      'description': model.description,
      'qualityScore': model.qualityScore,
      'qualityReason': model.qualityReason,
      'status': model.status.index,
      'photos': model.photos.map((p) => p.toJson()).toList(),
    };

    int index = list.indexWhere((i) => i['id'] == model.id);
    if (index != -1) {
      list[index] = summary;
    } else {
      list.add(summary);
    }
    await _saveAll(list);
  }

  Future<void> deleteCapture(int id) async {
    final list = await getIndex();
    final item = list.firstWhere((i) => i['id'] == id, orElse: () => {});
    
    if (item.isNotEmpty && item.containsKey('photos')) {
      for (var photo in item['photos']) {
        final imageFile = File(photo['imagePath']);
        if (await imageFile.exists()) await imageFile.delete();
      }
    }
    list.removeWhere((i) => i['id'] == id);
    await _saveAll(list);
  }

  Future<void> _saveAll(List<Map<String, dynamic>> list) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(list));
  }
}