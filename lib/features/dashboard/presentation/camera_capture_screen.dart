// lib/camera_capture_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/telemetry_service.dart';
import '../../../utils/geo_utils.dart';
import '../data/models/capture_model.dart'; 

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

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

  bool _isPressed = false;

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

  Widget _buildGpsStatus(double? accuracy) {
    if (accuracy == null) {
      return const Icon(Icons.gps_off, color: Colors.grey, size: 16);
    }

    Color statusColor;
    if (accuracy < 10) {
      statusColor = Colors.greenAccent;
    } else if (accuracy < 50) {
      statusColor = Colors.amber;
    } else {
      statusColor = Colors.redAccent;
    }
    
    // Just the icon, no text!
    return Icon(Icons.gps_fixed, color: statusColor, size: 16);
  }

  Widget _buildBubbleLevel(double tilt) {
    final double normalizedTilt = tilt.clamp(-30.0, 30.0);
    final double verticalOffset = normalizedTilt * 1.0;
    final bool isLevel = tilt.abs() < 1.0;

    return Container(
      width: 20,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.center, // This is key for horizontal centering
        children: [
          const Divider(color: Colors.white24, thickness: 1, indent: 4, endIndent: 4),
          Positioned(
            top: 35 + verticalOffset,
            // Remove 'left' or 'right' constraints, let Alignment.center handle it
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLevel ? Colors.white : Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
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
          if (snapshot.connectionState != ConnectionState.done || _controller == null) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              final isLandscape = orientation == Orientation.landscape;

              return Stack(
                children: [
                  // 1. Full-Screen Viewfinder with Pinch Zoom
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
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),

                  // 2. The HUD (Top-Right, Adaptive Padding)
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        // Push HUD left in landscape to clear the 120px shutter bar
                        padding: EdgeInsets.only(
                          top: 16.0,
                          right: isLandscape ? 136.0 : 16.0,
                          bottom: 16.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildTelemetryHeading(),
                            const SizedBox(height: 12),
                            _buildGpsStatusWidget(),
                            const SizedBox(height: 12),
                            _buildBubbleLevelWidget(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. The "Sticky" Control Bar
                  Align(
                    alignment: isLandscape ? Alignment.centerRight : Alignment.bottomCenter,
                    child: Container(
                      width: isLandscape ? 120 : double.infinity,
                      height: isLandscape ? double.infinity : 120,
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: _buildShutterButton(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // --- Shutter Button Helper ---
  Widget _buildShutterButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _takePicture();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 6)],
          ),
        ),
      ),
    );
  }

  // --- Telemetry Helper Widgets ---
  Widget _buildTelemetryHeading() {
    return ValueListenableBuilder<TelemetryFrame>(
      valueListenable: _telemetryNotifier,
      builder: (context, frame, child) {
        final locs = AppLocalizations.of(context);
        final List<String> dirs = locs?.cardinalDirections.split(',') ?? [];
        final String cardinal = frame.heading.toCardinalDirection(dirs);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(8)),
          child: Text(cardinal, style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  Widget _buildGpsStatusWidget() {
    return ValueListenableBuilder<TelemetryFrame>(
      valueListenable: _telemetryNotifier,
      builder: (context, frame, child) => SizedBox(width: 20, child: Center(child: _buildGpsStatus(frame.position?.accuracy))),
    );
  }

  Widget _buildBubbleLevelWidget() {
    return ValueListenableBuilder<TelemetryFrame>(
      valueListenable: _telemetryNotifier,
      builder: (context, frame, child) => _buildBubbleLevel(frame.tilt),
    );
  }
}