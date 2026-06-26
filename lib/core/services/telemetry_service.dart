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
  /// Spins up the system-level sensor fusion engine.
  /// Automatically remaps internal math to follow device orientation changes.
  Stream<TelemetryFrame> startTelemetryStream() {
    // 1. Tell the hardware hub to optimize updates for smooth UI frame rates
    RotationSensor.samplingPeriod = SensorInterval.uiInterval;

    // 2. The New Magic Trick: Remap the coordinate system for vertical camera mode.
    // The new X-axis stays the same, but the new Y-axis tracks the old negative Z-axis
    // (pointing straight out through the back of the phone's camera lens).
    RotationSensor.coordinateSystem = CoordinateSystem.transformed(Axis3.X, -Axis3.Z);

    // 3. Map the native OS Euler matrix events into simple, actionable degrees
    return RotationSensor.orientationStream.map((OrientationEvent event) {
      final euler = event.eulerAngles;

      // Azimuth maps native radians: 0 = North, π/2 = East, π = South, -π/2 = West
      double headingDegrees = euler.azimuth * (180.0 / math.pi);
      // Cleanly wrap negative angles into a strict 0.0 - 359.9 circular path
      headingDegrees = (headingDegrees % 360 + 360) % 360;

      // Pitch maps phone tilt (forward/backward nodding) directly into degrees
      double tiltDegrees = euler.pitch * (180.0 / math.pi);

      return TelemetryFrame(
        heading: headingDegrees,
        tilt: tiltDegrees,
      );
    });
  }

  // Individual stop triggers are no longer needed; 
  // Flutter's stream subscription handle naturally manages the hardware thread closure.
  void dispose() {}
}