
import 'package:json_annotation/json_annotation.dart';

part 'enclosures.g.dart';
@JsonSerializable()

class Enclosures {
  String? url;
  int? fileSize;
  String? mimeType;

  Enclosures({this.url, this.fileSize, this.mimeType});

  factory Enclosures.fromJson(Map<String, dynamic> json) => _$EnclosuresFromJson(json);

  Map<String, dynamic> toJson() => _$EnclosuresToJson(this);
}