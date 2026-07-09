import 'package:json_annotation/json_annotation.dart';

part 'capture_model.g.dart';

enum CaptureStatus {
  inProgress,
  ready,
  uploaded,
  error,
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
  double? roll;
  double? fov;
  double? zoomLevel;
  RawTelemetry? rawSensors;
  String? gpsCoordinates;
  double? gpsAccuracy;
  double? gpsAltitude;
  DateTime? timestamp;

  PhotoEntry({this.id, this.imagePath, this.description, this.heading, this.tiltY, this.roll, this.fov, this.zoomLevel, this.rawSensors, this.gpsCoordinates, this.gpsAccuracy, this.gpsAltitude, this.timestamp});

  factory PhotoEntry.fromJson(Map<String, dynamic> json) => _$PhotoEntryFromJson(json);
  Map<String, dynamic> toJson() => _$PhotoEntryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CaptureModel {
  bool shouldRetain;
  int? id;
  String? description;
  List<PhotoEntry> photos;

  int? qualityScore; 
  String? qualityReason;

  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  CaptureStatus status;
  
  DateTime? timestamp;

  CaptureModel({
    this.shouldRetain = false,
    this.id, 
    this.description, 
    required this.photos,
    this.qualityScore = 3, // Default
    this.qualityReason,
    required this.status, 
    this.timestamp
  });

  CaptureModel copyWith({
    bool? shouldRetain,
    int? id,
    String? description,
    List<PhotoEntry>? photos,
    CaptureStatus? status,
    int? qualityScore,
    String? qualityReason,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? timestamp,
  }) {
    return CaptureModel(
      shouldRetain: shouldRetain ?? this.shouldRetain,
      id: id ?? this.id,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      qualityScore: qualityScore ?? this.qualityScore,
      qualityReason: (qualityReason == "") ? null : (qualityReason ?? this.qualityReason),
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory CaptureModel.fromJson(Map<String, dynamic> json) => _$CaptureModelFromJson(json);
  Map<String, dynamic> toJson() => _$CaptureModelToJson(this);
}

// Helpers for the JSON converter
DateTime? _dateTimeFromJson(String? date) => date != null ? DateTime.tryParse(date) : null;
String? _dateTimeToJson(DateTime? date) => date?.toIso8601String();

CaptureStatus _statusFromJson(int index) => CaptureStatus.values[index];
int _statusToJson(CaptureStatus status) => status.index;