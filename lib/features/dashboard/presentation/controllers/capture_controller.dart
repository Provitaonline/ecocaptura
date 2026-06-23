import 'package:flutter/foundation.dart';
import 'package:ecocaptura/features/dashboard/data/models/captura_model.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';

class CaptureController extends ChangeNotifier {
  final StorageManager _storage = StorageManager();
  List<Map<String, dynamic>> _captures = [];

  List<Map<String, dynamic>> get captures => _captures;

  Future<void> loadCaptures() async {
    _captures = await _storage.getIndex();
    notifyListeners(); // This triggers the UI rebuild
  }

  Future<void> addCapture(CapturaModel model) async {
    await _storage.saveCapture(model);
    await _storage.addOrUpdateIndex(model);
    await loadCaptures(); // Refresh the list
  }
}