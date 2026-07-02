// lib/core/services/telemetry_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart' hide SensorInterval;
import '../../features/dashboard/data/models/capture_model.dart';

class TelemetryFrame {
  final double heading;
  final double tilt;
  final RawTelemetry? rawTelemetry;
  final Position? position;

  TelemetryFrame({
    required this.heading, 
    required this.tilt, 
    this.rawTelemetry,
    this.position,
  });
}

class TelemetryService {
  DateTime _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  double _accX = 0, _accY = 0, _accZ = 0;
  double _gyroX = 0, _gyroY = 0, _gyroZ = 0;
  Position? _lastPosition;
  
  StreamSubscription? _accelSub;
  StreamSubscription? _gyroSub;
  StreamSubscription<Position>? _locationSub;

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return; // Handle this case by showing a dialog
    }
  }

  TelemetryService() {
    _checkPermissions();
    
    _accelSub = accelerometerEventStream().listen((e) {
      _accX = e.x; _accY = e.y; _accZ = e.z;
    });
    
    _gyroSub = gyroscopeEventStream().listen((e) {
      _gyroX = e.x; _gyroY = e.y; _gyroZ = e.z;
    });

    // Start location caching
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, 
      ),
    ).listen((position) {
      _lastPosition = position;
    });
  }

  Stream<TelemetryFrame> startTelemetryStream() {
    RotationSensor.samplingPeriod = SensorInterval.uiInterval;
    RotationSensor.coordinateSystem = CoordinateSystem.transformed(Axis3.X, -Axis3.Z);
    _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);

    return RotationSensor.orientationStream
        .where((event) {
          final now = DateTime.now();
          if (now.difference(_lastFrameTime).inMilliseconds >= 150) {
            _lastFrameTime = now;
            return true; 
          }
          return false; 
        })
        .map((event) {
          final euler = event.eulerAngles;

          double headingDegrees = (euler.azimuth * (180.0 / math.pi)) % 360;
          headingDegrees = (headingDegrees + 360) % 360;

          return TelemetryFrame(
            heading: headingDegrees,
            tilt: euler.pitch * (180.0 / math.pi),
            rawTelemetry: RawTelemetry(
              accX: _accX, accY: _accY, accZ: _accZ,
              gyroX: _gyroX, gyroY: _gyroY, gyroZ: _gyroZ,
            ),
            position: _lastPosition, 
          );
        });
  }

  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _locationSub?.cancel();
    _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);
  }
}