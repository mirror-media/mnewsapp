import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/paragraph.dart';

class Topic {
  final String id;
  final String name;
  final String slug;
  final bool isFeatured;
  final String? photoUrl;
  final List<Paragraph>? brief;
  bool isExpanded;

  Topic({
    required this.id,
    required this.name,
    required this.slug,
    required this.isFeatured,
    this.photoUrl,
    this.brief,
    this.isExpanded = false,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    List<Paragraph>? brief;
    if (BaseModel.hasKey(json, 'brief') && json["brief"] != 'NaN') {
      brief = Paragraph.parseResponseBody(json['brief'], isNotApiData: true);
    }

    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'urlMobileSized'])) {
      photoUrl = json['heroImage']['urlMobileSized'];
    }

    return Topic(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json['slug'],
      photoUrl: photoUrl,
      brief: brief,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
      };
}
