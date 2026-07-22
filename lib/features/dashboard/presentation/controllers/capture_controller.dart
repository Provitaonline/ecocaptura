import 'package:flutter/foundation.dart';
import 'package:ecocaptura/features/dashboard/data/models/capture_model.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';
import 'package:ecocaptura/backend/capture_api.dart';

class CaptureController extends ChangeNotifier {
  final StorageManager _storage = StorageManager();
  List<CaptureModel> _captures = []; 
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

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

  /// Fetches pending captures and handles the batch sync workflow with the backend.
  Future<void> syncPendingCaptures() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // 1. Fetch pending captures from local storage
      final pendingCaptures = await _storage.getPendingCaptures();

      if (pendingCaptures.isEmpty) {
        debugPrint("No pending captures to sync.");
        return;
      }

      // 2. Trigger batch upload via CaptureApi (assuming it handles current session username internally)
      await CaptureApi.instance.uploadPendingCaptures(pendingCaptures, 'testuser');

      // 3. Refresh local capture list to reflect any status updates or cleanups
      await loadCaptures();
    } catch (e) {
      debugPrint("Error syncing pending captures: $e");
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}