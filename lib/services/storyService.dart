import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/story.dart';

abstract class StoryRepos {
  Future<Story> fetchPublishedStoryBySlug(String slug);
}

class StoryServices implements StoryRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<Story> fetchPublishedStoryBySlug(String slug) async {
    print('[StoryService] fetchPublishedStoryBySlug("$slug")');

    try {
      final Story? internal = await _fetchInternal(slug);
      if (internal != null) {
        print('[StoryService] internal hit: $slug');
        return internal;
      } else {
        print('[StoryService] internal miss: $slug -> try external');
      }
    } catch (e) {
      print('[StoryService] internal fetch error: $e -> try external');
    }

    print('[StoryService] >>> try external: $slug');
    final Story external = await _fetchExternalAndNormalize(slug);
    print('[StoryService] >>> external success: $slug (style=${external.style})');
    return external;
  }

  Future<Story?> _fetchInternal(String slug) async {
    final String key = 'fetchPublishedStoryBySlug_internal?slug=$slug';

    const String internalQuery = """
    query (\$where: PostWhereInput) {
      posts(where: \$where) {
        style
        name
        briefApiData
        contentApiData
        publishTime
        updatedAt
        heroImage {
          imageApiData
        }
        heroVideo {
          coverPhoto {
            imageApiData
          }
          file {
            url
          }
          url
        }
        heroCaption
        categories { slug name }
        writers { name slug }
        photographers { name slug }
        cameraOperators { name slug }
        designers { name slug }
        engineers { name slug }
        vocals { name slug }
        otherbyline
        tags { id name slug }
        relatedPosts {
          slug
          name
          heroImage {
            imageApiData
          }
        }
        download { name url }
      }
    }
    """;

    final variables = {
      "where": {
        "state": {"equals": "published"},
        "slug": {"equals": slug},
      }
    };

    final GraphqlBody body = GraphqlBody(
      operationName: null,
      query: internalQuery,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(body.toJson()),
      maxAge: newsStoryCacheDuration,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    final list = _extractDataList(jsonResponse, 'posts');
    if (list.isEmpty) {
      print('[StoryService] internal empty posts for slug=$slug');
      return null;
    }

    try {
      final raw = Map<String, dynamic>.from(list.first as Map);
      final normalized = _normalizeInternalStory(raw);

      print('[StoryService] internal normalized json = ${jsonEncode(normalized)}');

      return Story.fromJson(normalized);
    } catch (e) {
      try {
        print('[StoryService] internal parse error: $e');
        print('[StoryService] internal raw json = ${jsonEncode(list.first)}');
      } catch (_) {
        print('[StoryService] internal parse error: $e');
      }
      return null;
    }
  }

  Future<Story> _fetchExternalAndNormalize(String slug) async {
    final String key = 'fetchPublishedStoryBySlug_external?slug=$slug';

    print('[ExternalTest] query slug=$slug');

    const String externalQuery = """
    query GetExternalBySlug(\$slug: String!) {
      externals(
        where: {
          state: { equals: "published" }
          slug: { equals: \$slug }
        }
      ) {
        id
        slug
        name
        subtitle
        state
        partner { id name slug }
        publishTime
        byline
        thumbnail
        heroCaption
        brief_original
        content_original
        brief
        content
        tags { id name slug }
        categories { id name slug }
        source
        updatedAt
        createdAt
      }
    }
    """;

    final GraphqlBody body = GraphqlBody(
      operationName: 'GetExternalBySlug',
      query: externalQuery,
      variables: {"slug": slug},
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(body.toJson()),
      maxAge: newsStoryCacheDuration,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    final list = _extractDataList(jsonResponse, 'externals');
    if (list.isEmpty) {
      throw FormatException('External not found for slug=$slug');
    }

    final Map<String, dynamic> ext = Map<String, dynamic>.from(list.first as Map);

    final String? briefHtmlRaw =
        _extractHtml(ext['brief']) ?? _asString(ext['brief_original']);
    final String? contentHtmlRaw =
        _extractHtml(ext['content']) ?? _asString(ext['content_original']);

    final String briefHtmlClean = _sanitizeHtml(briefHtmlRaw ?? '');
    final String contentHtmlClean = _sanitizeHtml(contentHtmlRaw ?? '');

    final List<dynamic> briefApiData = _normalizeApiDataBlocks(ext['brief']);
    final List<dynamic> contentApiData = _normalizeApiDataBlocks(ext['content']);

    String wrapApiDataString(List<dynamic> l) => jsonEncode({'apiData': l});

    final Map<String, dynamic> patched = {
      'style': 'external',
      'name': ext['name'],
      'publishTime': ext['publishTime'],
      'updatedAt': ext['updatedAt'],
      'heroCaption': ext['heroCaption'],
      'otherbyline': ext['byline'],
      'heroImage': {
        'imageApiData':
        ext['thumbnail'] ?? Environment().config.mirrorNewsDefaultImageUrl,
      },
      'categories': _ensureList(ext['categories']),
      'tags': _ensureList(ext['tags']),
      'briefApiData': wrapApiDataString(briefApiData),
      'contentApiData': wrapApiDataString(contentApiData),
      'externalBriefHtml': briefHtmlClean,
      'externalContentHtml': contentHtmlClean,
      'writers': const [],
      'photographers': const [],
      'cameraOperators': const [],
      'designers': const [],
      'engineers': const [],
      'vocals': const [],
      'relatedPosts': const [],
      'download': const [],
    };

    try {
      return Story.fromJson(patched);
    } catch (e) {
      print('[StoryService] external normalize parse error: $e');
      print('[StoryService] external patched json = ${jsonEncode(patched)}');
      throw FormatException('External normalize failed: $e');
    }
  }

  List<dynamic> _extractDataList(dynamic jsonResponse, String fieldName) {
    if (jsonResponse is! Map<String, dynamic>) return const [];

    final data = jsonResponse['data'];
    if (data is! Map<String, dynamic>) return const [];

    final list = data[fieldName];
    if (list is List) return list;

    return const [];
  }

  List<dynamic> _ensureList(dynamic value) {
    if (value is List) return value;
    return const [];
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> _normalizeInternalStory(Map<String, dynamic> raw) {
    final Map<String, dynamic> patched = Map<String, dynamic>.from(raw);

    patched['briefApiData'] = _wrapApiDataLikeStoryModel(raw['briefApiData']);
    patched['contentApiData'] =
        _wrapApiDataLikeStoryModel(raw['contentApiData']);

    final heroImage = _asMap(raw['heroImage']);
    if (heroImage != null) {
      patched['heroImage'] = {
        ...heroImage,
        'imageApiData':
        _normalizePossiblyComplexStringField(heroImage['imageApiData']),
      };
    } else {
      patched['heroImage'] = {
        'imageApiData': Environment().config.mirrorNewsDefaultImageUrl,
      };
    }

    final heroVideo = _asMap(raw['heroVideo']);
    if (heroVideo != null) {
      final coverPhoto = _asMap(heroVideo['coverPhoto']);
      patched['heroVideo'] = {
        ...heroVideo,
        if (coverPhoto != null)
          'coverPhoto': {
            ...coverPhoto,
            'imageApiData': _normalizePossiblyComplexStringField(
              coverPhoto['imageApiData'],
            ),
          },
      };
    }

    if (raw['relatedPosts'] is List) {
      patched['relatedPosts'] = (raw['relatedPosts'] as List).map((e) {
        final item = _asMap(e);
        if (item == null) return e;

        final relatedHeroImage = _asMap(item['heroImage']);
        return {
          ...item,
          if (relatedHeroImage != null)
            'heroImage': {
              ...relatedHeroImage,
              'imageApiData': _normalizePossiblyComplexStringField(
                relatedHeroImage['imageApiData'],
              ),
            },
        };
      }).toList();
    }

    patched['categories'] = _ensureList(raw['categories']);
    patched['writers'] = _ensureList(raw['writers']);
    patched['photographers'] = _ensureList(raw['photographers']);
    patched['cameraOperators'] = _ensureList(raw['cameraOperators']);
    patched['designers'] = _ensureList(raw['designers']);
    patched['engineers'] = _ensureList(raw['engineers']);
    patched['vocals'] = _ensureList(raw['vocals']);
    patched['tags'] = _ensureList(raw['tags']);
    patched['relatedPosts'] = _ensureList(patched['relatedPosts']);
    patched['download'] = _ensureList(raw['download']);

    return patched;
  }

  String _wrapApiDataLikeStoryModel(dynamic value) {
    if (value == null) {
      return jsonEncode({'apiData': []});
    }

    if (value is String) {
      try {
        final decoded = json.decode(value);
        if (decoded is Map<String, dynamic> && decoded['apiData'] is List) {
          return value;
        }
      } catch (_) {}

      return jsonEncode({
        'apiData': _normalizeApiDataBlocks(value),
      });
    }

    if (value is List) {
      return jsonEncode({'apiData': _normalizeApiDataBlocks(value)});
    }

    if (value is Map<String, dynamic>) {
      if (value.containsKey('apiData')) {
        return jsonEncode({
          ...value,
          'apiData': _normalizeApiDataBlocks(value),
        });
      }
      return jsonEncode({'apiData': []});
    }

    return jsonEncode({'apiData': []});
  }

  dynamic _normalizePossiblyComplexStringField(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List || value is Map) return jsonEncode(value);
    return value.toString();
  }

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return Map<String, dynamic>.from(v);
    }
    return null;
  }

  String? _extractHtml(dynamic section) {
    final obj = _coerceObj(section);
    if (obj == null) return null;

    final html = obj['html'];
    if (html is String && html.trim().isNotEmpty) {
      return html;
    }

    return null;
  }

  String _sanitizeHtml(String html) {
    var s = html;

    s = s
        .replaceAll(r'\"', '"')
        .replaceAll(r"\'", "'")
        .replaceAll(r'\/', '/')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\t', '\t');

    s = s
        .replaceAll(RegExp(r'<\s*figure\b', caseSensitive: false), '<div')
        .replaceAll(RegExp(r'</\s*figure\s*>', caseSensitive: false), '</div>');

    return s;
  }

  Map<String, dynamic>? _coerceObj(dynamic v) {
    if (v == null) return null;

    if (v is Map<String, dynamic>) return v;

    if (v is Map) {
      return Map<String, dynamic>.from(v);
    }

    if (v is String) {
      try {
        final decoded = json.decode(v);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }

    return null;
  }

  List<dynamic> _normalizeApiDataBlocks(dynamic value) {
    List<dynamic> blocks = [];

    if (value == null) return blocks;

    if (value is List) {
      blocks = value;
    } else if (value is Map<String, dynamic>) {
      final apiData = value['apiData'];
      if (apiData is List) {
        blocks = apiData;
      }
    } else if (value is Map) {
      final mapValue = Map<String, dynamic>.from(value);
      final apiData = mapValue['apiData'];
      if (apiData is List) {
        blocks = apiData;
      }
    } else if (value is String) {
      try {
        final decoded = json.decode(value);
        if (decoded is Map<String, dynamic> && decoded['apiData'] is List) {
          blocks = decoded['apiData'] as List<dynamic>;
        } else if (decoded is List) {
          blocks = decoded;
        }
      } catch (_) {}
    }

    return blocks.map((block) {
      if (block is! Map) return block;

      final map = Map<String, dynamic>.from(block);
      final rawContent = map['content'];

      if (rawContent is List) {
        map['content'] = rawContent.map((e) => e.toString()).join('\n');
      } else if (rawContent == null) {
        map['content'] = '';
      } else if (rawContent is! String) {
        map['content'] = rawContent.toString();
      }

      return map;
    }).toList();
  }
}