import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

class TelemetryService {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  /// Listens to raw sensors and streams processed, calibrated tilt data frames
  Stream<double> startTiltStream() {
    final controller = StreamController<double>();

    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        final double x = event.x;
        final double y = event.y;
        final double z = event.z;
        double calculatedTilt = 0.0;

        // Your calibrated coordinate matrix preserved exactly
        if (y.abs() >= x.abs()) {
          if (y >= 0) {
            calculatedTilt = -math.atan2(z, y) * (180.0 / math.pi);
          } else {
            calculatedTilt = -math.atan2(z, -y) * (180.0 / math.pi);
          }
        } else {
          if (x < 0) {
            calculatedTilt = -math.atan2(z, -x) * (180.0 / math.pi);
          } else {
            calculatedTilt = -math.atan2(z, x) * (180.0 / math.pi);
          }
        }

        controller.add(calculatedTilt);
      },
      onError: (error) => controller.addError(error),
      onDone: () => controller.close(),
    );

    return controller.stream;
  }

  /// Cleanly shuts down active hardware threads
  void stopTiltStream() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }
}