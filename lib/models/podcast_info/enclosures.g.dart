// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosures.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enclosures _$EnclosuresFromJson(Map<String, dynamic> json) => Enclosures(
      url: json['url'] as String?,
      fileSize: json['fileSize'] as int?,
      mimeType: json['mimeType'] as String?,
    );

Map<String, dynamic> _$EnclosuresToJson(Enclosures instance) =>
    <String, dynamic>{
      'url': instance.url,
      'fileSize': instance.fileSize,
      'mimeType': instance.mimeType,
    };
