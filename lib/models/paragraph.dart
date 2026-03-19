import 'dart:convert';

import 'package:tv/models/content.dart';

class Paragraph {
  String? styles;
  String? type;
  List<Content>? contents;

  Paragraph({
    this.styles,
    this.type,
    this.contents,
  });

  factory Paragraph.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Paragraph();
    }

    final String? rawType = json['type']?.toString();
    final String normalizedType = _normalizeType(rawType);
    final dynamic rawContent = json['content'];
    final dynamic rawData = json['data'];

    print('[Paragraph.fromJson] rawType = $rawType');
    print('[Paragraph.fromJson] normalizedType = $normalizedType');

    List<Content> contents = [];

    // 1. 先吃 V2 block
    if (rawData is Map) {
      final dataMap = Map<String, dynamic>.from(rawData);

      if (normalizedType == 'slideshow') {
        final images = dataMap['images'];
        if (images is List) {
          contents = images.map((e) => Content.fromJson(e)).toList();
        }
      } else if (normalizedType == 'audio') {
        if (dataMap['audio'] != null) {
          contents = [Content.fromJson({'audio': dataMap['audio']})];
        }
      } else if (normalizedType == 'video') {
        contents = [
          Content.fromJson({
            'desc': dataMap['desc'],
            'video': dataMap['video'],
          })
        ];
      }
    }

    // 2. 如果 V2 沒解出來，再走舊 / 攤平 content 格式
    if (contents.isEmpty && rawContent is List) {
      if (normalizedType == 'slideshow') {
        for (final item in rawContent) {
          if (item is Map) {
            final itemMap = Map<String, dynamic>.from(item);

            if (itemMap['images'] is List) {
              final images = itemMap['images'] as List;
              for (final image in images) {
                contents.add(Content.fromJson(image));
              }
            } else {
              contents.add(Content.fromJson(itemMap));
            }
          } else {
            contents.add(Content.fromJson(item));
          }
        }
      } else {
        contents = List<Content>.from(
          rawContent.map((content) => Content.fromJson(content)),
        );
      }
    }

    print('[Paragraph.fromJson] final type = $normalizedType, contents.length = ${contents.length}');

    return Paragraph(
      type: normalizedType,
      contents: contents,
    );
  }

  static String _normalizeType(String? type) {
    if (type == null || type.isEmpty) return '';

    switch (type.toLowerCase()) {
      case 'slideshow-v2':
        return 'slideshow';
      case 'audio-v2':
        return 'audio';
      case 'video-v2':
        return 'video';
      default:
        return type;
    }
  }

  static List<Paragraph> parseResponseBody(String body, {bool isNotApiData = false}) {
    try {
      final jsonData = json.decode(body);

      if (isNotApiData) {
        return List<Paragraph>.from(
          jsonData['apiData'].map((paragraph) => Paragraph.fromJson(paragraph)),
        );
      }

      if (jsonData == "" || jsonData == null) {
        return [];
      }

      return List<Paragraph>.from(
        jsonData.map((paragraph) => Paragraph.fromJson(paragraph)),
      );
    } catch (e) {
      print('[Paragraph.parseResponseBody] error: $e');
      return [];
    }
  }
}