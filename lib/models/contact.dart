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
    final String photoUrl = _parsePhotoUrl(json);

    List<Paragraph>? bioApiData;
    if (BaseModel.hasKey(json, 'bioApiData') && json['bioApiData'] != 'NaN') {
      bioApiData = Paragraph.parseResponseBody(json['bioApiData']);
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
      instatgramUrl: json['instagram'],
      bio: bioApiData,
    );
  }

  static String _parsePhotoUrl(Map<String, dynamic> json) {
    const imageFields = ['anchorImg', 'showhostImg'];

    for (final field in imageFields) {
      final imageNode = json[field];
      if (imageNode is! Map<String, dynamic>) continue;

      // K6: imageApiData
      final imageApiData = imageNode['imageApiData'];
      final k6Url = _extractUrlFromImageApiData(imageApiData);
      if (k6Url != null && k6Url.isNotEmpty) {
        return k6Url;
      }

      // fallback: 舊版欄位
      final legacyUrl = imageNode['urlMobileSized'];
      if (legacyUrl is String && legacyUrl.isNotEmpty) {
        return legacyUrl;
      }
    }

    return Environment().config.mirrorNewsDefaultImageUrl;
  }

  static String? _extractUrlFromImageApiData(dynamic imageApiData) {
    if (imageApiData == null) return null;

    if (imageApiData is String && imageApiData.isNotEmpty) {
      return imageApiData;
    }

    if (imageApiData is Map<String, dynamic>) {
      final possibleKeys = ['url', 'original', 'src'];
      for (final key in possibleKeys) {
        final value = imageApiData[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }
}