import 'dart:io';

/// Represents a single photographic entry within a field logging transaction.
class PhotoEntry {
  final String id;
  final File imageFile;
  final String description;
  final double heading;
  final double tiltY;
  final String gpsCoordinates; 
  final double gpsAccuracy;
  final DateTime timestamp;

  PhotoEntry({
    required this.id,
    required this.imageFile,
    this.description = '',
    required this.heading,
    required this.tiltY,
    required this.gpsCoordinates,
    required this.gpsAccuracy,
    required this.timestamp,
  });
}