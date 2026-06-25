import 'package:json_annotation/json_annotation.dart';

part 'capture_model.g.dart';

enum CaptureStatus {
  inProgress,
  ready,
  uploaded,
}

@JsonSerializable(explicitToJson: true)
class RawTelemetry {
  double? accX;
  double? accY;
  double? accZ;
  double? gyroX;
  double? gyroY;
  double? gyroZ;

  RawTelemetry({this.accX, this.accY, this.accZ, this.gyroX, this.gyroY, this.gyroZ});

  factory RawTelemetry.fromJson(Map<String, dynamic> json) => _$RawTelemetryFromJson(json);
  Map<String, dynamic> toJson() => _$RawTelemetryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PhotoEntry {
  String? id;
  String? imagePath;
  String? description;
  double? heading;
  double? tiltY;
  RawTelemetry? rawSensors;
  String? gpsCoordinates;
  double? gpsAccuracy;
  DateTime? timestamp;

  PhotoEntry({this.id, this.imagePath, this.description, this.heading, this.tiltY, this.rawSensors, this.gpsCoordinates, this.gpsAccuracy, this.timestamp});

  factory PhotoEntry.fromJson(Map<String, dynamic> json) => _$PhotoEntryFromJson(json);
  Map<String, dynamic> toJson() => _$PhotoEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CaptureModel {
  int? id;
  String? remoteId;
  String? description;
  List<PhotoEntry> photos;

  // Custom converter for the enum
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  CaptureStatus status;
  
  DateTime? timestamp;

  CaptureModel({this.id, this.remoteId, this.description, required this.photos, required this.status, this.timestamp});

  factory CaptureModel.fromJson(Map<String, dynamic> json) => _$CaptureModelFromJson(json);
  Map<String, dynamic> toJson() => _$CaptureModelToJson(this);
}

// Helpers for the JSON converter
CaptureStatus _statusFromJson(int index) => CaptureStatus.values[index];
int _statusToJson(CaptureStatus status) => status.index;