// lib/camera_capture_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/telemetry_service.dart';
import '../../../utils/geo_utils.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({Key? key}) : super(key: key);

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  
  final TelemetryService _telemetryService = TelemetryService();
  StreamSubscription<TelemetryFrame>? _telemetrySubscription;
  
  final ValueNotifier<TelemetryFrame> _telemetryNotifier = ValueNotifier(
    TelemetryFrame(heading: 0.0, tilt: 0.0),
  );

  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      setState(() {
        _initializeControllerFuture = _controller!.initialize();
      });

      await _initializeControllerFuture;
      if (!mounted) return;
      
      _initializeTelemetry();
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  void _initializeTelemetry() {
    _telemetrySubscription = _telemetryService.startTelemetryStream().listen((frame) {
      // Direct assignment bypasses setState, stopping entire-screen rebuilds
      _telemetryNotifier.value = frame;
    });
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _controller?.dispose();
    _telemetryService.dispose();
    _telemetryNotifier.dispose(); // Added: Clean up the notifier
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile photoFile = await _controller!.takePicture();
      if (mounted) Navigator.pop(context, photoFile.path);
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
          if (_initializeControllerFuture != null &&
              snapshot.connectionState == ConnectionState.done && 
              _controller != null) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onScaleStart: (details) => _baseZoomLevel = _currentZoomLevel,
                    onScaleUpdate: (details) async {
                      if (_controller == null) return;
                      
                      final minZoom = await _controller!.getMinZoomLevel();
                      final maxZoom = await _controller!.getMaxZoomLevel();
                      double newZoom = (_baseZoomLevel * details.scale).clamp(minZoom, maxZoom);
                      
                      // Update the level and communicate with native bridge
                      if ((newZoom - _currentZoomLevel).abs() > 0.05) {
                        _currentZoomLevel = newZoom;
                        await _controller!.setZoomLevel(newZoom);
                      }
                    },
                    child: CameraPreview(_controller!),
                  ),
                ),

                // NEW: Targeted UI rebuilds via ValueListenableBuilder
                SafeArea(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ValueListenableBuilder<TelemetryFrame>(
                        valueListenable: _telemetryNotifier,
                        builder: (context, frame, child) {
                          final locs = AppLocalizations.of(context);
                          final List<String> dirs = locs?.cardinalDirections.split(',') ?? [];
                          final String cardinal = frame.heading.toCardinalDirection(dirs);

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${frame.heading.toStringAsFixed(1)}° $cardinal', 
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
                                Text('Tilt: ${frame.tilt.toStringAsFixed(1)}°', 
                                  style: TextStyle(color: frame.tilt.abs() < 5 ? Colors.greenAccent : Colors.white70, fontSize: 14, fontFamily: 'Courier')),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: _takePicture,
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 28),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        },
      ),
    );
  }
}