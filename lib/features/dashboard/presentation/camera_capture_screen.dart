// lib/camera_capture_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/telemetry_service.dart';
import '../../../utils/geo_utils.dart';
import '../data/models/capture_model.dart'; 

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
  
  RawTelemetry? _lastRawTelemetry;
  
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
        imageFormatGroup: ImageFormatGroup.yuv420,
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
      _telemetryNotifier.value = frame;
      _lastRawTelemetry = frame.rawTelemetry; 
    });
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _controller?.dispose();
    _telemetryService.dispose();
    _telemetryNotifier.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    try {
      final XFile photoFile = await _controller!.takePicture();

      final frame = _telemetryNotifier.value;
      final pos = frame.position; 
      
      final entry = PhotoEntry(
        imagePath: photoFile.path,
        heading: frame.heading,
        tiltY: frame.tilt,
        rawSensors: _lastRawTelemetry,
        gpsCoordinates: pos != null 
          ? "${pos.latitude},${pos.longitude}" 
          : null,
        gpsAccuracy: pos?.accuracy, 
        timestamp: DateTime.now(),
      );
      
      if (mounted) Navigator.pop(context, entry);
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
                      
                      if ((newZoom - _currentZoomLevel).abs() > 0.05) {
                        _currentZoomLevel = newZoom;
                        await _controller!.setZoomLevel(newZoom);
                      }
                    },
                    child: CameraPreview(_controller!),
                  ),
                ),

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
                                  style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontFamily: 'Courier')),
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