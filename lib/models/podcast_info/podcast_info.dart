import 'package:json_annotation/json_annotation.dart';
import 'package:tv/core/extensions/string_extension.dart';
import 'package:tv/models/podcast_info/enclosures.dart';


part 'podcast_info.g.dart';

@JsonSerializable()
class PodcastInfo {
  String? published;
  String? author;
  String? description;
  String? heroImage;
  List<Enclosures>? enclosures;
  String? link;
  String? guid;
  String? title;
  String? duration;
  int? imageHeight;

  PodcastInfo(
      {this.published,
      this.author,
      this.description,
      this.heroImage,
      this.enclosures,
      this.link,
      this.guid,
      this.title,
      this.duration});
  String? get timeFormat => (published ?? '').convertToCustomFormat();

  factory PodcastInfo.fromJson(Map<String, dynamic> json) =>
      _$PodcastInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PodcastInfoToJson(this);

  @override
  bool operator ==(Object other) =>
      other is PodcastInfo && other.title == title;

  @override
  int get hashCode => hashCode;
}
