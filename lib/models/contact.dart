import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/paragraph.dart';

class Contact {
  final String id;
  final String name;
  final String photoUrl;
  final String slug;

  final bool isAnchorperson;
  final bool isHost;

  final String? twitterUrl;
  final String? facebookUrl;
  final String? instatgramUrl;
  final List<Paragraph>? bio;

  Contact({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.slug,
    required this.isAnchorperson,
    required this.isHost,
    required this.twitterUrl,
    required this.facebookUrl,
    required this.instatgramUrl,
    required this.bio,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;
    if (BaseModel.checkJsonKeys(json, ['anchorImg', 'urlMobileSized'])) {
      photoUrl = json['anchorImg']['urlMobileSized'];
    } else if (BaseModel.checkJsonKeys(
        json, ['showhostImg', 'urlMobileSized'])) {
      photoUrl = json['showhostImg']['urlMobileSized'];
    }
    List<Paragraph>? bioApiData;
    if (BaseModel.hasKey(json, 'bioApiData') && json["bioApiData"] != 'NaN') {
      bioApiData = Paragraph.parseResponseBody(json["bioApiData"]);
    }

    return Contact(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      photoUrl: photoUrl,
      slug: json[BaseModel.slugKey],
      isAnchorperson: json['anchorperson'] ?? false,
      isHost: json['host'] ?? false,
      twitterUrl: json['twitter'],
      facebookUrl: json['facebook'],
      instatgramUrl: json['instatgram'],
      bio: bioApiData,
    );
  }
}
