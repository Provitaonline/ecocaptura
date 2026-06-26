// lib/camera_capture_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/telemetry_service.dart';
import '../../../utils/geo_utils.dart';

class CameraCaptureScreen extends StatefulWidget {
  // No required arguments here anymore, making it completely plug-and-play
  const CameraCaptureScreen({Key? key}) : super(key: key);

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  
  final TelemetryService _telemetryService = TelemetryService();
  StreamSubscription<TelemetryFrame>? _telemetrySubscription;

  double _currentTilt = 0.0;
  double _currentHeading = 0.0;
  String _cardinalText = '';

  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Asynchronously queries hardware devices and binds the primary rear camera
  void _initializeCamera() async {
    try {
      // 1. Fetch available physical cameras directly within the screen lifecycle
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No physical cameras detected on this device.");
        return;
      }

      // 2. Default to the primary rear-facing lens array
      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // 3. Setup the camera controller preview parameter block
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      // 4. Expose the initialization future for the UI FutureBuilder
      setState(() {
        _initializeControllerFuture = _controller!.initialize();
      });

      await _initializeControllerFuture;

      if (!mounted) return;
      
      // 5. Fire up the system-level sensor fusion telemetry engine
      _initializeTelemetry();
      
    } catch (e) {
      debugPrint('Camera or Hardware subsystem internal init error: $e');
    }
  }

  void _initializeTelemetry() {
    // Listen to the unified sensor fusion data stream
    _telemetrySubscription = _telemetryService.startTelemetryStream().listen((frame) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
        
        setState(() {
          _currentTilt = frame.tilt;
          _currentHeading = frame.heading;
          
          if (localizations != null) {
            // Parses localized bundle string (e.g., "N,NE,E,SE,S,SW,W,NW")
            final List<String> localizedList = localizations.cardinalDirections.split(',');
            _cardinalText = frame.heading.toCardinalDirection(localizedList);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up active telemetry stream handles and release native camera hooks
    _telemetrySubscription?.cancel();
    _controller?.dispose();
    _telemetryService.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      // Captures the photo and saves it to a temporary directory automatically
      final XFile photoFile = await _controller!.takePicture();
      
      // Pass the local disk path back to the New Capture screen
      if (mounted) {
        Navigator.pop(context, photoFile.path);
      }
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          // Verify that the future exists and has finished loading the pipeline
          if (_initializeControllerFuture != null &&
              snapshot.connectionState == ConnectionState.done && 
              _controller != null) {
            return Stack(
              children: [
                // 1. Hardware View Finder Layer
                Positioned.fill(
                  child: GestureDetector(
                    onScaleStart: (details) {
                      _baseZoomLevel = _currentZoomLevel;
                    },
                    onScaleUpdate: (details) async {
                      if (_controller == null) return;
                      
                      final minZoom = await _controller!.getMinZoomLevel();
                      final maxZoom = await _controller!.getMaxZoomLevel();
                      
                      double newZoom = (_baseZoomLevel * details.scale).clamp(minZoom, maxZoom);
                      
                      // RESTORED: Only bridge to the native camera channel if the change is significant
                      if ((newZoom - _currentZoomLevel).abs() > 0.05) {
                        setState(() {
                          _currentZoomLevel = newZoom;
                        });
                        await _controller!.setZoomLevel(newZoom);
                      }
                    },
                    child: CameraPreview(_controller!),
                  ),
                ),

                // 2. Head-Up Telemetry Display Overlay
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_currentHeading.toStringAsFixed(1)}° $_cardinalText',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tilt: ${_currentTilt.toStringAsFixed(1)}°',
                              style: TextStyle(
                                color: _currentTilt.abs() < 5 ? Colors.greenAccent : Colors.white70,
                                fontSize: 14,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Camera Capture Shutter Button Action Row
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: _takePicture, // Direct execution block
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Display loading indicator while waiting for hardware hooks to lock in
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}