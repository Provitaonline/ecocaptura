import 'dart:developer' as developer;

extension CompassHeading on double {
  /// Converts this heading degree value into a localized 16-point cardinal string.
  /// Expects a list of exactly 16 localized labels starting from 'N'.
  String toCardinalDirection(List<String> localizedDirections) {
    // Guard rail: fall back to a safe placeholder if the passed list is malformed
    if (localizedDirections.length != 16) {
      return '??';
    }
    
    // Shift by 11.25° to center windows, divide by 22.5° slices, clamp 0-15
    int index = ((this + 11.25) / 22.5).floor() % 16;

    developer.log('DEGREE: $this -> INDEX: $index', name: 'COMPASS');

    return localizedDirections[index];
  }
}