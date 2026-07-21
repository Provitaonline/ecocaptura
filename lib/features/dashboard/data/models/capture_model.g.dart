// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RawTelemetry _$RawTelemetryFromJson(Map<String, dynamic> json) => RawTelemetry(
  accX: (json['accX'] as num?)?.toDouble(),
  accY: (json['accY'] as num?)?.toDouble(),
  accZ: (json['accZ'] as num?)?.toDouble(),
  gyroX: (json['gyroX'] as num?)?.toDouble(),
  gyroY: (json['gyroY'] as num?)?.toDouble(),
  gyroZ: (json['gyroZ'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RawTelemetryToJson(RawTelemetry instance) =>
    <String, dynamic>{
      'accX': instance.accX,
      'accY': instance.accY,
      'accZ': instance.accZ,
      'gyroX': instance.gyroX,
      'gyroY': instance.gyroY,
      'gyroZ': instance.gyroZ,
    };

PhotoEntry _$PhotoEntryFromJson(Map<String, dynamic> json) => PhotoEntry(
  id: json['id'] as String?,
  imagePath: json['imagePath'] as String?,
  description: json['description'] as String?,
  heading: (json['heading'] as num?)?.toDouble(),
  tiltY: (json['tiltY'] as num?)?.toDouble(),
  roll: (json['roll'] as num?)?.toDouble(),
  fov: (json['fov'] as num?)?.toDouble(),
  zoomLevel: (json['zoomLevel'] as num?)?.toDouble(),
  rawSensors: json['rawSensors'] == null
      ? null
      : RawTelemetry.fromJson(json['rawSensors'] as Map<String, dynamic>),
  gpsCoordinates: json['gpsCoordinates'] as String?,
  gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble(),
  gpsAltitude: (json['gpsAltitude'] as num?)?.toDouble(),
  timestamp: _dateTimeFromJson(json['timestamp']),
);

Map<String, dynamic> _$PhotoEntryToJson(PhotoEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'description': instance.description,
      'heading': instance.heading,
      'tiltY': instance.tiltY,
      'roll': instance.roll,
      'fov': instance.fov,
      'zoomLevel': instance.zoomLevel,
      'rawSensors': instance.rawSensors?.toJson(),
      'gpsCoordinates': instance.gpsCoordinates,
      'gpsAccuracy': instance.gpsAccuracy,
      'gpsAltitude': instance.gpsAltitude,
      'timestamp': _dateTimeToJson(instance.timestamp),
    };

CaptureModel _$CaptureModelFromJson(Map<String, dynamic> json) => CaptureModel(
  shouldRetain: json['shouldRetain'] as bool? ?? false,
  id: json['id'] as String?,
  description: json['description'] as String?,
  photos: (json['photos'] as List<dynamic>)
      .map((e) => PhotoEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  qualityScore: (json['qualityScore'] as num?)?.toInt() ?? 3,
  qualityReason: json['qualityReason'] as String?,
  status: _statusFromJson((json['status'] as num).toInt()),
  timestamp: _dateTimeFromJson(json['timestamp']),
);

Map<String, dynamic> _$CaptureModelToJson(CaptureModel instance) =>
    <String, dynamic>{
      'shouldRetain': instance.shouldRetain,
      'id': instance.id,
      'description': instance.description,
      'photos': instance.photos.map((e) => e.toJson()).toList(),
      'qualityScore': instance.qualityScore,
      'qualityReason': instance.qualityReason,
      'status': _statusToJson(instance.status),
      'timestamp': _dateTimeToJson(instance.timestamp),
    };
