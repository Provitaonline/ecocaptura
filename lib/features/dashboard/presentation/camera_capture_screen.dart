// lib/camera_capture_screen.dart
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:ecocaptura/core/constants/app_spacing.dart';
import 'package:ecocaptura/core/l10n/app_localizations.dart';
import 'package:ecocaptura/core/services/telemetry_service.dart';
import 'package:ecocaptura/utils/geo_utils.dart';
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
    TelemetryFrame(heading: 0.0, tilt: 0.0, roll: 0.0),
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
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // 1. Assign the future BEFORE awaiting it
      final initFuture = _controller!.initialize();
      setState(() {
        _initializeControllerFuture = initFuture;
      });

      // 2. Await the same future you assigned to the state
      await initFuture;
      
      if (!mounted) return;
      
      // 3. Trigger telemetry separately
      _initializeTelemetry();
      
    } catch (e) {
      debugPrint('Camera/Telemetry init error: $e');
    }
  }

  Future<void> _initializeTelemetry() async {
    try {
      await _telemetryService.init();

      _telemetrySubscription = _telemetryService.startTelemetryStream().listen((frame) {
        if (mounted) {
          _telemetryNotifier.value = frame;
          _lastRawTelemetry = frame.rawTelemetry; 
        }
      });
    } catch (e) {
      debugPrint("Telemetry initialization failed: $e");
    }
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
        alignment: Alignment.center,
        children: [
          const Divider(color: Colors.white24, thickness: 1, indent: 4, endIndent: 4),
          Positioned(
            top: 35 + verticalOffset,
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
      final currentFrame = _telemetryNotifier.value;
      final double zoomLevel = _currentZoomLevel;
      final XFile photoFile = await _controller!.takePicture();
      final double fov = 75.0 / zoomLevel;

      // 3. Use the captured data
      final entry = PhotoEntry(
        imagePath: photoFile.path,
        heading: currentFrame.heading,
        tiltY: currentFrame.tilt,
        roll: currentFrame.roll,
        fov: fov,
        zoomLevel: zoomLevel,
        rawSensors: _lastRawTelemetry,
        gpsCoordinates: currentFrame.position != null 
          ? "${currentFrame.position!.latitude},${currentFrame.position!.longitude}" 
          : null,
        gpsAccuracy: currentFrame.position?.accuracy,
        gpsAltitude: currentFrame.position?.altitude,
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
              final size = MediaQuery.of(context).size;
              
              // Keep dimensions responsive and consistent
              final double controlBarSize = isLandscape
                  ? (size.width * 0.15).clamp(80.0, 160.0)
                  : (size.height * 0.12).clamp(80.0, 160.0);
              final double buttonSize = (controlBarSize * 0.6).clamp(56.0, 96.0);
              final double iconSize = buttonSize * 0.5;

              return Stack(
                children: [
                  // 1. Full-Screen Viewfinder
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

                  // 2. Top-Left Exit Button (Symmetrical to Shutter)  
                  if (Platform.isIOS)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: buttonSize * 0.7, // Slightly smaller than shutter
                              height: buttonSize * 0.7,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close, color: Colors.white, size: iconSize * 0.7),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 3. The HUD (Top-Right, Adaptive Padding)  
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: AppSpacing.lg,
                          right: isLandscape ? (controlBarSize + AppSpacing.lg) : AppSpacing.lg,
                          bottom: AppSpacing.lg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildTelemetryHeading(),
                            const SizedBox(height: AppSpacing.md),
                            _buildGpsStatusWidget(),
                            const SizedBox(height: AppSpacing.md),
                            _buildBubbleLevelWidget(),
                          ],  
                        ),
                      ),
                    ),
                  ),

                  // 4. The "Sticky" Control Bar
                  Align(
                    alignment: isLandscape ? Alignment.centerRight : Alignment.bottomCenter,
                    child: Container(
                      width: isLandscape ? controlBarSize : double.infinity,
                      height: isLandscape ? double.infinity : controlBarSize,
                      color: Colors.black,
                      alignment: Alignment.center,
                      child: _buildShutterButton(buttonSize),
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
  Widget _buildShutterButton(double size) {
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
          width: size,
          height: size,
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