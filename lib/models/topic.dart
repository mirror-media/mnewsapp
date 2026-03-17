import 'dart:convert';

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
      try {
        brief = Paragraph.parseResponseBody(json['brief'], isNotApiData: true);
      } catch (_) {}
    }

    String photoUrl = _extractImageUrlFromNode(json['heroImage']) ??
        Environment().config.mirrorNewsDefaultImageUrl;

    return Topic(
      id: json[BaseModel.idKey]?.toString() ?? '',
      name: json[BaseModel.nameKey]?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      photoUrl: photoUrl,
      brief: brief,
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  static String? _extractImageUrlFromNode(dynamic imageNode) {
    if (imageNode == null) return null;
    if (imageNode is! Map) return null;

    final map = imageNode is Map<String, dynamic>
        ? imageNode
        : Map<String, dynamic>.from(imageNode);

    final imageApiData = map['imageApiData'];
    final k6Url = _extractUrlFromImageApiData(imageApiData);
    if (k6Url != null && k6Url.isNotEmpty) {
      return k6Url;
    }

    const directKeys = [
      'url',
      'urlMobileSized',
      'urlOriginal',
      'mobile',
      'w800',
      'w480',
      'w1200',
      'original',
      'src',
    ];

    for (final key in directKeys) {
      final value = map[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
      if (value is Map) {
        final nested = value is Map<String, dynamic>
            ? value
            : Map<String, dynamic>.from(value);

        final nestedUrl = nested['url'];
        if (nestedUrl is String && nestedUrl.isNotEmpty) {
          return nestedUrl;
        }
      }
    }

    return null;
  }

  static String? _extractUrlFromImageApiData(dynamic imageApiData) {
    if (imageApiData == null) return null;

    if (imageApiData is String) {
      final trimmed = imageApiData.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }

      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final decoded = json.decode(trimmed);
          return _extractUrlFromImageApiData(decoded);
        } catch (_) {
          return null;
        }
      }

      return null;
    }

    if (imageApiData is Map) {
      final map = imageApiData is Map<String, dynamic>
          ? imageApiData
          : Map<String, dynamic>.from(imageApiData);

      const possibleKeys = [
        'url',
        'urlMobileSized',
        'urlOriginal',
        'mobile',
        'w800',
        'w1200',
        'w480',
        'original',
        'src',
      ];

      for (final key in possibleKeys) {
        final value = map[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
        if (value is Map) {
          final nested = value is Map<String, dynamic>
              ? value
              : Map<String, dynamic>.from(value);

          final nestedUrl = nested['url'];
          if (nestedUrl is String && nestedUrl.isNotEmpty) {
            return nestedUrl;
          }
        }
      }
    }

    if (imageApiData is List) {
      for (final item in imageApiData) {
        final url = _extractUrlFromImageApiData(item);
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
    BaseModel.idKey: id,
    BaseModel.nameKey: name,
  };
}