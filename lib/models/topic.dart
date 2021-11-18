import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/paragrpahList.dart';

class Topic {
  final String id;
  final String name;
  final String? slug;
  final String? photoUrl;
  final ParagraphList? brief;

  Topic({
    required this.id,
    required this.name,
    this.slug,
    this.photoUrl,
    this.brief,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    ParagraphList brief = ParagraphList();
    if (BaseModel.hasKey(json, 'briefApiData') &&
        json["briefApiData"] != 'NaN') {
      brief = ParagraphList.parseResponseBody(json['briefApiData']);
    }

    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['heroImage', 'mobile'])) {
      photoUrl = json['heroImage']['mobile'];
    }

    return Topic(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json['slug'],
      photoUrl: photoUrl,
      brief: brief,
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
      };
}
