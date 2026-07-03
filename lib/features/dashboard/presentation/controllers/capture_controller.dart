import 'package:flutter/foundation.dart';
import 'package:ecocaptura/features/dashboard/data/models/capture_model.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';

class CaptureController extends ChangeNotifier {
  final StorageManager _storage = StorageManager();
  List<Map<String, dynamic>> _captures = [];

  List<Map<String, dynamic>> get captures => _captures;

  Future<void> loadCaptures() async {
    _captures = await _storage.getIndex();
    notifyListeners(); 
  }

  Future<void> addCapture(CaptureModel model) async {
    await _storage.saveCapture(model);
    await _storage.addOrUpdateIndex(model);
    await loadCaptures(); 
  }

  Future<void> deleteCapture(Map<String, dynamic> capture) async {
    final rawId = capture['id'];
    if (rawId == null) return;
    
    // Safely parse the ID to an int
    final int id = rawId is int ? rawId : int.parse(rawId.toString());

    // 1. Immediate UI update
    _captures.remove(capture);
    notifyListeners();

    try {
      // 2. Offload all file and index deletion to the manager
      await _storage.deleteCapture(id);

      // 3. Re-sync to confirm everything matches the disk state
      await loadCaptures();
    } catch (e) {
      debugPrint("Error updating state after deletion: $e");
      await loadCaptures();
    }
  }

  // Updates an existing capture by overwriting the file and the index.
  Future<void> updateCapture(CaptureModel model) async {
    try {
      // 1. Persist the updated model to disk (StorageManager should handle file write)
      await _storage.saveCapture(model);

      // 2. Update the index record
      await _storage.addOrUpdateIndex(model);

      // 3. Refresh state to propagate changes to the UI
      await loadCaptures();
    } catch (e) {
      debugPrint("Error updating capture: $e");
      rethrow; 
    }
  }
}