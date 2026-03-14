import 'package:tv/helpers/environment.dart';
import 'package:tv/models/baseModel.dart';
import 'package:tv/models/category.dart';
import 'dart:convert';

enum StoryLinkType { story, external }

class ParsedStoryLink {
  final StoryLinkType type;
  final String slug;
  ParsedStoryLink({required this.type, required this.slug});
}

ParsedStoryLink? parseStoryLinkFromUrl(String? url) {
  if (url == null || url.trim().isEmpty) return null;

  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;

  final segments = uri.pathSegments.where((s) => s.trim().isNotEmpty).toList();
  if (segments.length < 2) return null;

  final head = segments[0].trim(); // story / external
  final last = segments.last.trim(); // slug

  StoryLinkType? type;
  if (head == 'story') type = StoryLinkType.story;
  if (head == 'external') type = StoryLinkType.external;
  if (type == null) return null;

  if (last.isEmpty) return null;

  return ParsedStoryLink(type: type, slug: last);
}

class StoryListItem {
  String? id;
  String? name;
  String? slug;
  String? url;
  String? style;
  StoryLinkType? linkType;
  String photoUrl;
  List<Category>? categoryList;
  bool? isSales = false;
  String? displayCategory;

  String? source;
  String? subtitle;
  String? heroCaption;
  String? brief;
  String? content;
  String? briefOriginal;
  String? contentOriginal;
  String? publishTime;
  String? updatedAt;
  String? partnerName;

  StoryListItem({
    this.id,
    this.name,
    this.slug,
    this.url,
    this.style,
    this.linkType,
    required this.photoUrl,
    this.categoryList,
    this.isSales,
    this.displayCategory,
    this.source,
    this.subtitle,
    this.heroCaption,
    this.brief,
    this.content,
    this.briefOriginal,
    this.contentOriginal,
    this.publishTime,
    this.updatedAt,
    this.partnerName,
  });

  factory StoryListItem.fromJsonSales(Map<String, dynamic> json) {
    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;

    if (json['adPost'] is Map<String, dynamic>) {
      final adPost = json['adPost'] as Map<String, dynamic>;

      photoUrl = _extractImageUrlFromNode(adPost['heroImage']) ??
          Environment().config.mirrorNewsDefaultImageUrl;
    }

    String? displayCategory;
    List<Category>? allPostsCategory;
    if (json['adPost']?['categories'] != null) {
      allPostsCategory = List<Category>.from(
        json['adPost']['categories'].map((category) => Category.fromJson(category)),
      );
      if (allPostsCategory.isNotEmpty) {
        displayCategory = allPostsCategory.first.name;
      }
      for (var postsCategory in allPostsCategory) {
        if (postsCategory.slug == 'ombuds') {
          displayCategory = "公評人";
          break;
        }
      }
    }

    return StoryListItem(
      id: json['adPost'][BaseModel.idKey],
      name: json['adPost'][BaseModel.nameKey],
      slug: json['adPost'][BaseModel.slugKey],
      style: json['adPost']['style'],
      photoUrl: photoUrl,
      isSales: true,
      categoryList: allPostsCategory,
      displayCategory: displayCategory,
    );
  }

  factory StoryListItem.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('product_id') && json.containsKey('url')) {
      final cover = json['cover_image']?.toString();
      final url = json['url']?.toString();
      final parsed = parseStoryLinkFromUrl(url);
      return StoryListItem(
        id: json['product_id']?.toString(),
        name: json['title']?.toString(),
        url: url,
        slug: parsed?.slug,
        linkType: parsed?.type,
        photoUrl: (cover != null && cover.isNotEmpty)
            ? cover
            : Environment().config.mirrorNewsDefaultImageUrl,
        displayCategory: json['custom_attributes'] is Map
            ? (json['custom_attributes']['article:section']?.toString() ?? '')
            : '',
      );
    }

    if (BaseModel.hasKey(json, '_source')) {
      json = json['_source'];
    }

    // External
    if (json.containsKey('partner') || json.containsKey('brief_original')) {
      return StoryListItem(
        id: json[BaseModel.idKey]?.toString(),
        name: json[BaseModel.nameKey],
        slug: json[BaseModel.slugKey],
        subtitle: json['subtitle'],
        url: json['url']?.toString(),
        photoUrl: (json['thumbnail']?.toString().isNotEmpty ?? false)
            ? json['thumbnail'].toString()
            : Environment().config.mirrorNewsDefaultImageUrl,
        heroCaption: json['heroCaption'],
        brief: json['brief'],
        content: json['content'],
        briefOriginal: json['brief_original'],
        contentOriginal: json['content_original'],
        publishTime: json['publishTime'],
        updatedAt: json['updatedAt'],
        source: json['source'],
        partnerName: json['partner']?['name'],
        categoryList: json['categories'] != null
            ? List<Category>.from(json['categories'].map((c) => Category.fromJson(c)))
            : [],
        displayCategory: (json['categories'] != null && (json['categories'] as List).isNotEmpty)
            ? json['categories'][0]['name']
            : "鏡報",
      );
    }

    String photoUrl = Environment().config.mirrorNewsDefaultImageUrl;

    // K6 優先：heroImage.imageApiData
    photoUrl = _extractImageUrlFromNode(json['heroImage']) ??
        _extractImageUrlFromNode(json['heroVideo']?['coverPhoto']) ??
        Environment().config.mirrorNewsDefaultImageUrl;

    String? displayCategory;
    List<Category>? allPostsCategory;
    if (json['categories'] != null) {
      allPostsCategory = List<Category>.from(
        json['categories'].map((category) => Category.fromJson(category)),
      );
      if (allPostsCategory.isNotEmpty) {
        displayCategory = allPostsCategory.first.name;
      }
      for (var postsCategory in allPostsCategory) {
        if (postsCategory.slug == 'ombuds') {
          displayCategory = "公評人";
          break;
        }
      }
    }

    String? style;
    if (BaseModel.checkJsonKeys(json, ['style'])) {
      style = json['style'];
    }

    return StoryListItem(
      id: json[BaseModel.idKey],
      name: json[BaseModel.nameKey],
      slug: json[BaseModel.slugKey],
      url: json['url']?.toString(),
      style: style,
      photoUrl: photoUrl,
      isSales: false,
      categoryList: allPostsCategory,
      displayCategory: displayCategory,
    );
  }

  static String? _extractImageUrlFromNode(dynamic imageNode) {
    if (imageNode == null) return null;

    if (imageNode is Map<String, dynamic>) {
      final imageApiData = imageNode['imageApiData'];
      final k6Url = _extractUrlFromImageApiData(imageApiData);
      if (k6Url != null && k6Url.isNotEmpty) {
        return k6Url;
      }

      final legacyUrl = imageNode['urlMobileSized'];
      if (legacyUrl is String && legacyUrl.isNotEmpty) {
        return legacyUrl;
      }

      final mobile = imageNode['mobile'];
      if (mobile is String && mobile.isNotEmpty) {
        return mobile;
      }
    }

    if (imageNode is Map) {
      return _extractImageUrlFromNode(Map<String, dynamic>.from(imageNode));
    }

    return null;
  }

  static String? _extractUrlFromImageApiData(dynamic imageApiData) {
    if (imageApiData == null) return null;

    if (imageApiData is String) {
      final trimmed = imageApiData.trim();
      if (trimmed.isEmpty) return null;

      // 直接就是網址
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }

      // JSON 字串
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

    if (imageApiData is Map<String, dynamic>) {
      final directUrl = imageApiData['url'];
      if (directUrl is String && directUrl.isNotEmpty) {
        return directUrl;
      }

      final possibleKeys = [
        'w800',
        'w1200',
        'w480',
        'original',
        'src',
        'mobile',
        'urlMobileSized',
      ];

      for (final key in possibleKeys) {
        final value = imageApiData[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
        if (value is Map<String, dynamic>) {
          final nestedUrl = value['url'];
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
    BaseModel.slugKey: slug,
    'url': url,
    'style': style,
    'photoUrl': photoUrl,
    'source': source,
    'briefOriginal': briefOriginal,
    'contentOriginal': contentOriginal,
    'linkType': linkType?.name,
  };

  @override
  int get hashCode => (slug ?? url ?? id ?? '').hashCode;

  @override
  bool operator ==(covariant StoryListItem other) =>
      (slug ?? url ?? id) == (other.slug ?? other.url ?? other.id);
}