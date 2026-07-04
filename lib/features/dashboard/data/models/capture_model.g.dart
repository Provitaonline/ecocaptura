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
  rawSensors: json['rawSensors'] == null
      ? null
      : RawTelemetry.fromJson(json['rawSensors'] as Map<String, dynamic>),
  gpsCoordinates: json['gpsCoordinates'] as String?,
  gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble(),
  gpsAltitude: (json['gpsAltitude'] as num?)?.toDouble(),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$PhotoEntryToJson(PhotoEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'description': instance.description,
      'heading': instance.heading,
      'tiltY': instance.tiltY,
      'rawSensors': instance.rawSensors?.toJson(),
      'gpsCoordinates': instance.gpsCoordinates,
      'gpsAccuracy': instance.gpsAccuracy,
      'gpsAltitude': instance.gpsAltitude,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

CaptureModel _$CaptureModelFromJson(Map<String, dynamic> json) => CaptureModel(
  id: (json['id'] as num?)?.toInt(),
  remoteId: json['remoteId'] as String?,
  description: json['description'] as String?,
  photos: (json['photos'] as List<dynamic>)
      .map((e) => PhotoEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  qualityScore: (json['qualityScore'] as num?)?.toInt() ?? 3,
  qualityReason: json['qualityReason'] as String?,
  status: _statusFromJson((json['status'] as num).toInt()),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$CaptureModelToJson(CaptureModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'remoteId': instance.remoteId,
      'description': instance.description,
      'photos': instance.photos.map((e) => e.toJson()).toList(),
      'qualityScore': instance.qualityScore,
      'qualityReason': instance.qualityReason,
      'status': _statusToJson(instance.status),
      'timestamp': instance.timestamp?.toIso8601String(),
    };
