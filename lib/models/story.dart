import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/downloadFile.dart';
import 'package:tv/models/paragraph.dart';
import 'package:tv/models/people.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/tag.dart';

class Story {
  final String? style;
  final String? name;
  final List<Paragraph>? brief;
  final List<Paragraph>? contentApiData;
  final String? publishTime;
  final String? updatedAt;

  final String? heroImage;
  final String? heroVideo;
  final String? heroCaption;

  final List<Category>? categoryList;

  final List<People>? writers;
  final List<People>? photographers;
  final List<People>? cameraOperators;
  final List<People>? designers;
  final List<People>? engineers;
  final List<People>? vocals;
  final String? otherbyline;

  final List<Tag>? tags;
  final List<StoryListItem>? relatedStories;
  final List<String>? imageUrlList;
  final List<DownloadFile>? downloadFileList;

  final String? externalBriefHtml;
  final String? externalContentHtml;

  Story({
    this.style,
    this.name,
    this.brief,
    this.contentApiData,
    this.publishTime,
    this.updatedAt,
    this.heroImage,
    this.heroVideo,
    this.heroCaption,
    this.categoryList,
    this.writers,
    this.photographers,
    this.cameraOperators,
    this.designers,
    this.engineers,
    this.vocals,
    this.otherbyline,
    this.tags,
    this.relatedStories,
    this.imageUrlList,
    this.downloadFileList,
    this.externalBriefHtml,
    this.externalContentHtml,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    // ---- brief ----
    List<Paragraph>? brief;
    final rawBrief = json['briefApiData'];
    if (rawBrief != null && rawBrief != 'NaN') {
      brief = _parseParagraphs(rawBrief);
    }

    // ---- contentApiData + imageUrlList ----
    List<Paragraph>? contentApiData;
    final List<String> imageUrlList = [];

    final rawContent = json['contentApiData'];
    if (rawContent != null && rawContent != 'NaN') {
      contentApiData = _parseParagraphs(rawContent);

      if (contentApiData.isNotEmpty) {
        for (final paragraph in contentApiData) {
          final contents = paragraph.contents;
          if (contents != null && contents.isNotEmpty) {
            if (paragraph.type == 'image') {
              final data = contents[0].data;
              if (data.isNotEmpty) {
                imageUrlList.add(data);
              }
            } else if (paragraph.type == 'slideshow') {
              for (final content in contents) {
                if (content.data.isNotEmpty) {
                  imageUrlList.add(content.data);
                }
              }
            }
          }
        }
      }
    }

    // ---- heroImage ----
    String? heroImage = Environment().config.mirrorNewsDefaultImageUrl;
    final heroImageJson = json['heroImage'];
    final parsedHeroImage = _extractImageUrlFromNode(heroImageJson) ??
        _extractImageUrlFromNode(json['heroVideo']?['coverPhoto']);

    if (parsedHeroImage != null && parsedHeroImage.isNotEmpty) {
      heroImage = parsedHeroImage;
      if (!imageUrlList.contains(heroImage)) {
        imageUrlList.insert(0, heroImage);
      }
    }

    // ---- heroVideo ----
    String? heroVideo;
    final heroVideoJson = json['heroVideo'];
    if (heroVideoJson is Map<String, dynamic>) {
      if (heroVideoJson['url'] is String &&
          (heroVideoJson['url'] as String).isNotEmpty) {
        heroVideo = heroVideoJson['url'] as String;
      } else if (heroVideoJson['file'] is Map<String, dynamic>) {
        final fileUrl = heroVideoJson['file']['url'];
        if (fileUrl is String && fileUrl.isNotEmpty) {
          heroVideo = fileUrl;
        }
      }
    } else if (heroVideoJson is Map) {
      final map = Map<String, dynamic>.from(heroVideoJson);
      if (map['url'] is String && (map['url'] as String).isNotEmpty) {
        heroVideo = map['url'] as String;
      } else if (map['file'] is Map) {
        final fileMap = Map<String, dynamic>.from(map['file']);
        final fileUrl = fileMap['url'];
        if (fileUrl is String && fileUrl.isNotEmpty) {
          heroVideo = fileUrl;
        }
      }
    }

    // ---- categoryList ----
    List<Category>? categoryList;
    final rawCategories = json['categories'];
    if (rawCategories is List) {
      categoryList = rawCategories
          .map((c) => Category.fromJson(c))
          .toList(growable: false);
    }

    // ---- download files ----
    List<DownloadFile>? downloadFileList;
    final rawDownload = json['download'];
    if (rawDownload is List) {
      downloadFileList = rawDownload
          .map((d) => DownloadFile.fromJson(d))
          .toList(growable: false);
    }

    // ---- writers ----
    List<People>? writers;
    final rawWriters = json['writers'];
    if (rawWriters is List) {
      writers = rawWriters
          .map((w) => People.fromJson(w))
          .toList(growable: false);
    }

    // ---- photographers ----
    List<People>? photographers;
    final rawPhotographers = json['photographers'];
    if (rawPhotographers is List) {
      photographers = rawPhotographers
          .map((p) => People.fromJson(p))
          .toList(growable: false);
    }

    // ---- cameraOperators ----
    List<People>? cameraOperators;
    final rawCameraOps = json['cameraOperators'];
    if (rawCameraOps is List) {
      cameraOperators = rawCameraOps
          .map((c) => People.fromJson(c))
          .toList(growable: false);
    }

    // ---- designers ----
    List<People>? designers;
    final rawDesigners = json['designers'];
    if (rawDesigners is List) {
      designers = rawDesigners
          .map((d) => People.fromJson(d))
          .toList(growable: false);
    }

    // ---- engineers ----
    List<People>? engineers;
    final rawEngineers = json['engineers'];
    if (rawEngineers is List) {
      engineers = rawEngineers
          .map((e) => People.fromJson(e))
          .toList(growable: false);
    }

    // ---- vocals ----
    List<People>? vocals;
    final rawVocals = json['vocals'];
    if (rawVocals is List) {
      vocals = rawVocals
          .map((v) => People.fromJson(v))
          .toList(growable: false);
    }

    // ---- tags ----
    List<Tag>? tags;
    final rawTags = json['tags'];
    if (rawTags is List) {
      tags = rawTags
          .map((t) => Tag.fromJson(t))
          .toList(growable: false);
    }

    // ---- related stories ----
    List<StoryListItem>? relatedStories;
    final rawRelated = json['relatedPosts'];
    if (rawRelated is List) {
      relatedStories = rawRelated
          .map((r) => StoryListItem.fromJson(r))
          .toList(growable: false);
    }

    // ---- external html ----
    final externalBriefHtml = json['externalBriefHtml'] as String?;
    final externalContentHtml = json['externalContentHtml'] as String?;

    return Story(
      style: json['style'] as String?,
      name: json[BaseModel.nameKey] as String?,
      brief: brief ?? const [],
      contentApiData: contentApiData ?? const [],
      publishTime: json['publishTime'] as String?,
      updatedAt: json['updatedAt'] as String?,
      heroImage: heroImage,
      heroVideo: heroVideo,
      heroCaption: json['heroCaption'] as String?,
      categoryList: categoryList,
      writers: writers,
      photographers: photographers,
      cameraOperators: cameraOperators,
      designers: designers,
      engineers: engineers,
      vocals: vocals,
      otherbyline: json['otherbyline'] as String?,
      tags: tags,
      relatedStories: relatedStories,
      imageUrlList: imageUrlList,
      downloadFileList: downloadFileList,
      externalBriefHtml: externalBriefHtml,
      externalContentHtml: externalContentHtml,
    );
  }

  static List<Paragraph> _parseParagraphs(dynamic raw) {
    try {
      dynamic source = raw;

      if (source == null || source == 'NaN') {
        return [];
      }

      if (source is String) {
        final trimmed = source.trim();
        if (trimmed.isEmpty) return [];

        try {
          source = json.decode(trimmed);
        } catch (_) {
          final parsed = Paragraph.parseResponseBody(source);
          return parsed ?? [];
        }
      }

      if (source is Map<String, dynamic>) {
        final apiData = source['apiData'];
        if (apiData is List) {
          return _mapParagraphList(apiData);
        }
        return [];
      }

      if (source is List) {
        return _mapParagraphList(source);
      }

      final parsed = Paragraph.parseResponseBody(raw);
      return parsed ?? [];
    } catch (e) {
      print('[Story] _parseParagraphs error: $e');
      return [];
    }
  }

  static List<Paragraph> _mapParagraphList(List list) {
    final List<Paragraph> result = [];

    for (final item in list) {
      Map<String, dynamic>? map;

      if (item is Map<String, dynamic>) {
        map = Map<String, dynamic>.from(item);
      } else if (item is Map) {
        map = Map<String, dynamic>.from(item);
      }

      if (map == null) continue;

      final normalized = _normalizeParagraphJson(map);

      try {
        result.add(Paragraph.fromJson(normalized));
      } catch (e) {
        print('[Story] Paragraph.fromJson error: $e');
        print('[Story] paragraph raw = $map');
        print('[Story] paragraph normalized = $normalized');
      }
    }

    return result;
  }

  static Map<String, dynamic> _normalizeParagraphJson(Map<String, dynamic> raw) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);

    final dynamic rawContent = map['content'];

    if (rawContent is String) {
      map['content'] = [rawContent];
    } else if (rawContent is List) {
      map['content'] = rawContent.map((e) {
        if (e is Map<String, dynamic>) return e;
        if (e is Map) return Map<String, dynamic>.from(e);
        return {'data': e.toString()};
      }).toList();
    } else if (rawContent == null) {
      map['content'] = [];
    }

    return map;
  }

  static String? _extractImageUrlFromNode(dynamic imageNode) {
    if (imageNode == null) return null;
    if (imageNode is! Map) return null;

    final map = imageNode is Map<String, dynamic>
        ? imageNode
        : Map<String, dynamic>.from(imageNode);

    // 1. resized 直接就是字串 URL
    final resizedUrl = _extractFromStringMap(
      map['resized'],
      priority: const ['w800', 'w480', 'w1600', 'w2400', 'original', 'w1200'],
    );
    if (resizedUrl != null && resizedUrl.isNotEmpty) {
      return resizedUrl;
    }

    // 2. resizedWebp
    final resizedWebpUrl = _extractFromStringMap(
      map['resizedWebp'],
      priority: const ['w800', 'w480', 'w1600', 'w2400', 'original', 'w1200'],
    );
    if (resizedWebpUrl != null && resizedWebpUrl.isNotEmpty) {
      return resizedWebpUrl;
    }

    // 3. imageApiData
    final imageApiData = map['imageApiData'];
    final k6Url = _extractUrlFromImageApiData(imageApiData);
    if (k6Url != null && k6Url.isNotEmpty) {
      return k6Url;
    }

    // 4. file.url
    final file = map['file'];
    if (file is Map) {
      final fileMap = file is Map<String, dynamic>
          ? file
          : Map<String, dynamic>.from(file);
      final fileUrl = fileMap['url'];
      if (fileUrl is String &&
          fileUrl.isNotEmpty &&
          (fileUrl.startsWith('http://') || fileUrl.startsWith('https://'))) {
        return fileUrl;
      }
    }

    // 5. 舊扁平欄位 fallback
    const directKeys = [
      'url',
      'urlMobileSized',
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

  static String? _extractFromStringMap(
      dynamic value, {
        required List<String> priority,
      }) {
    if (value is! Map) return null;

    final map = value is Map<String, dynamic>
        ? value
        : Map<String, dynamic>.from(value);

    for (final key in priority) {
      final v = map[key];
      if (v is String && v.isNotEmpty) {
        return v;
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

      final directUrl = map['url'];
      if (directUrl is String && directUrl.isNotEmpty) {
        return directUrl;
      }

      const possibleKeys = [
        'w800',
        'w480',
        'w1600',
        'w2400',
        'original',
        'w1200',
        'src',
        'mobile',
        'urlMobileSized',
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

  factory Story.empty() {
    return Story();
  }
}