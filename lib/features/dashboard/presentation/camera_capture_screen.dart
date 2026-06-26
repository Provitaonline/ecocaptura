import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  double _minZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _currentZoomLevel = 1.0;
  double _baseZoomLevel = 1.0;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Using the primary rear camera
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.medium, // Medium is great for fast file sizes/processing
          enableAudio: false,     // Keeps permissions simple
        );

        await _controller!.initialize();
        _minZoomLevel = await _controller!.getMinZoomLevel();
        _maxZoomLevel = await _controller!.getMaxZoomLevel();
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text("Camera not available. Check permissions.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 1. The Full Camera Preview (Now with Pinch-to-Zoom)
            Center(
              child: GestureDetector(
                onScaleStart: (details) {
                  _baseZoomLevel = _currentZoomLevel;
                },
                onScaleUpdate: (details) async {
                  double newZoom = _baseZoomLevel * details.scale;
                  if (newZoom < _minZoomLevel) newZoom = _minZoomLevel;
                  if (newZoom > _maxZoomLevel) newZoom = _maxZoomLevel;

                  // Only talk to the native camera if the zoom changed by more than 0.05
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

            // FUTURE INCREMENT: This is exactly where your semi-transparent 
            // overlay widget will sit, right on top of the preview!

            // 2. Control Layout (Abort and Shutter)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // Shutter Button
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Container(
                              height: 54,
                              width: 54,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Empty spacer to balance the close button layout
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}