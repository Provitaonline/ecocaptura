// lib/core/services/telemetry_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
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
  bool _isInitialized = false;

  TelemetryService();

  /// Must be called before starting the stream to ensure permissions are granted.
  Future<void> init() async {
    if (_isInitialized) return;

    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      debugPrint("TelemetryService: Location permissions denied. Skipping location stream.");
    }

    _accelSub = accelerometerEventStream().listen((e) {
      _accX = e.x; _accY = e.y; _accZ = e.z;
    });
    
    _gyroSub = gyroscopeEventStream().listen((e) {
      _gyroX = e.x; _gyroY = e.y; _gyroZ = e.z;
    });

    if (hasPermission) {
      _locationSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen((position) {
        _lastPosition = position;
      });
    }
    
    _isInitialized = true;
  }

  Future<bool> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
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
    _isInitialized = false;
    _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);
  }
}