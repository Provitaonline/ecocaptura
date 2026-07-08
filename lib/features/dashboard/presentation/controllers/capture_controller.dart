import 'package:flutter/foundation.dart';
import 'package:ecocaptura/features/dashboard/data/models/capture_model.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';

class CaptureController extends ChangeNotifier {
  final StorageManager _storage = StorageManager();
  List<CaptureModel> _captures = []; // Now stores Objects, not Maps

  List<CaptureModel> get captures => _captures;

  Future<void> loadCaptures() async {
    _captures = await _storage.loadAllCaptures();
    notifyListeners(); 
  }

  Future<void> addCapture(CaptureModel model) async {
    await _storage.saveCapture(model);
    await loadCaptures(); 
  }

  Future<void> deleteCapture(CaptureModel capture) async {
    // 1. Immediate UI update
    _captures.remove(capture);
    notifyListeners();

    try {
      // 2. Simply pass the object ID
      await _storage.deleteCapture(capture.id!);
      await loadCaptures();
    } catch (e) {
      debugPrint("Error deleting: $e");
      await loadCaptures();
    }
  }

  Future<void> updateCapture(CaptureModel model) async {
    try {
      await _storage.saveCapture(model);
      await loadCaptures();
    } catch (e) {
      debugPrint("Error updating: $e");
      rethrow; 
    }
  }
}