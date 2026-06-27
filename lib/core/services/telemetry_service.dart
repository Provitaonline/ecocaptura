// lib/telemetry_service.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';

/// A unified data container holding perfectly synchronized spatial telemetry
class TelemetryFrame {
  final double heading; // 0.0 to 359.9 degrees
  final double tilt;    // Pitch angle in degrees

  TelemetryFrame({required this.heading, required this.tilt});
}

class TelemetryService {
  // Tracks timestamps to keep tabs on the streaming intervals
  DateTime _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);

  /// Spins up the system-level sensor fusion engine.
  /// Automatically remaps internal math to follow device orientation changes.
  Stream<TelemetryFrame> startTelemetryStream() {
    // 1. Tell the hardware hub to optimize updates for smooth UI frame rates
    RotationSensor.samplingPeriod = SensorInterval.uiInterval;

    // 2. Remap the coordinate system for vertical camera mode.
    RotationSensor.coordinateSystem = CoordinateSystem.transformed(Axis3.X, -Axis3.Z);

    // Reset timestamp on stream startup
    _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);

    // 3. Filter and map the native OS Euler matrix events
    return RotationSensor.orientationStream
        .where((OrientationEvent event) {
          final now = DateTime.now();
          // Adjust 150ms to hit perfect sweet spot (~6-7 frames per second)
          if (now.difference(_lastFrameTime).inMilliseconds >= 150) {
            _lastFrameTime = now;
            return true; 
          }
          return false; 
        })
        .map((OrientationEvent event) {
          final euler = event.eulerAngles;

          double headingDegrees = euler.azimuth * (180.0 / math.pi);
          headingDegrees = (headingDegrees % 360 + 360) % 360;

          double tiltDegrees = euler.pitch * (180.0 / math.pi);

          return TelemetryFrame(
            heading: headingDegrees,
            tilt: tiltDegrees,
          );
        });
  }

  /// RESTORED: Explicit resource disposal hook called when closing the camera screen
  void dispose() {
    _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  }
}