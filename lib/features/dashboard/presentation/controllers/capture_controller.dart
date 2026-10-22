import 'package:flutter/foundation.dart';
import 'package:ecocaptura/features/dashboard/data/models/capture_model.dart';
import 'package:ecocaptura/features/dashboard/data/services/storage_manager.dart';
import 'package:ecocaptura/backend/capture_api.dart';
import 'package:ecocaptura/core/services/auth_service.dart';

class CaptureController extends ChangeNotifier {
  final StorageManager _storage = StorageManager();
  List<CaptureModel> _captures = []; 
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  // Sync progress tracking variables
  int _syncTotal = 0;
  int _syncCurrent = 0;

  double get syncProgress => _syncTotal == 0 ? 0.0 : _syncCurrent / _syncTotal;
  String get syncProgressText => '$_syncCurrent/$_syncTotal';

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
    _captures.remove(capture);
    notifyListeners();

    try {
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

  // Fetches pending captures and handles the batch sync workflow with the backend.
  Future<void> syncPendingCaptures() async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncCurrent = 0;
    _syncTotal = 0;
    notifyListeners();

    try {
      // Fetch pending captures from local storage
      final pendingCaptures = await _storage.getPendingCaptures();

      if (pendingCaptures.isEmpty) {
        debugPrint("No pending captures to sync.");
        return;
      }

      _syncTotal = pendingCaptures.length;
      notifyListeners();

      // Retrieve the stored username and access token dynamically
      final String? username = await AuthService.instance.getStoredUsername();

      if (username == null || username.isEmpty) {
        throw Exception("No authenticated username found for sync.");
      }

      // Trigger batch upload via CaptureApi
      try {
        await CaptureApi.instance.uploadPendingCaptures(
          pendingCaptures, 
          username,
          onProgress: (completed, total) {
            _syncCurrent = completed;
            _syncTotal = total;
            notifyListeners();
          },
        );
        _syncCurrent = _syncTotal;
        notifyListeners();
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('401') || 
            errorStr.contains('Unauthorized') || 
            errorStr.contains('RefreshTokenExpired')) {
          
          debugPrint('[Sync] Refresh token expired. Forcing user logout.');
          await AuthService.instance.logout();
          
          throw Exception('Session expired. Please log in again.');
        } else {
          rethrow;
        }
      }

      // Refresh local capture list
      await loadCaptures();
    } catch (e) {
      debugPrint("Error syncing pending captures: $e");
      rethrow;
    } finally {
      _isSyncing = false;
      _syncCurrent = 0;
      _syncTotal = 0;
      notifyListeners();
    }
  }
}