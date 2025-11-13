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

    // 1) 先試站內
    try {
      final Story? internal = await _fetchInternal(slug);
      if (internal != null) {
        print('[StoryService] internal hit: $slug');
        return internal;
      } else {
        print('[StoryService] internal miss: $slug → try external');
      }
    } catch (e) {
      print('[StoryService] internal fetch error: $e → try external');
    }

    // 2) external（鏡報等）
    final Story external = await _fetchExternalAndNormalize(slug);
    return external;
  }

  Future<Story?> _fetchInternal(String slug) async {
    final String key = 'fetchPublishedStoryBySlug?slug=$slug';

    const String internalQuery = """
    query (\$where: PostWhereInput) {
      allPosts(where: \$where) {
        style
        name
        briefApiData
        contentApiData
        publishTime
        updatedAt
        heroImage { mobile: urlMobileSized, desktop: urlDesktopSized }
        heroVideo {
          coverPhoto {
            tiny: urlTinySized
            mobile: urlMobileSized
            tablet: urlTabletSized
            desktop: urlDesktopSized
            original: urlOriginal
          }
          file { publicUrl }
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
        relatedPosts { slug name heroImage { urlMobileSized } }
        download { name url }
      }
    }
    """;

    final variables = {
      "where": {"state": "published", "slug": slug}
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
      headers: {"Content-Type": "application/json"},
    );

    final list = jsonResponse?['data']?['allPosts'];
    if (list is List && list.isNotEmpty) {
      try {
        final story = Story.fromJson(list[0]);
        return story;
      } catch (e) {
        print('[StoryService] internal parse error: $e');
        return null;
      }
    }
    return null;
  }

  Future<Story> _fetchExternalAndNormalize(String slug) async {
    const String externalQuery = """
    query GetExternalBySlug(\$slug: String!) {
      allExternals(
        where: { state: published, slug: \$slug }
      ) {
        _label_
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

    final jsonResponse = await _helper.postByUrl(
      Environment().config.graphqlApi,
      jsonEncode(body.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    final list = jsonResponse?['data']?['allExternals'];
    if (list is! List || list.isEmpty) {
      throw FormatException('External not found for slug=$slug');
    }

    final Map<String, dynamic> ext = Map<String, dynamic>.from(list[0] as Map);

    // 先嘗試取 draft.html，缺少時用 *_original
    final String? briefHtmlRaw   = _extractHtml(ext['brief'])   ?? (ext['brief_original'] as String?);
    final String? contentHtmlRaw = _extractHtml(ext['content']) ?? (ext['content_original'] as String?);

    final String briefHtmlClean   = _sanitizeHtml(briefHtmlRaw ?? '');
    final String contentHtmlClean = _sanitizeHtml(contentHtmlRaw ?? '');

    // 若 external 自己就有 apiData，沿用；否則給空陣列，讓頁面優先 fallback HTML
    final List<dynamic> briefApiData   = _buildApiDataFromSection(ext['brief']);
    final List<dynamic> contentApiData = _buildApiDataFromSection(ext['content']);

    print('[StoryService] external hit: $slug '
        '| briefHtml.len=${briefHtmlClean.length}, contentHtml.len=${contentHtmlClean.length} '
        '| briefApiData.len=${briefApiData.length}, contentApiData.len=${contentApiData.length}');

    String _wrapApiDataString(List<dynamic> l) => jsonEncode({'apiData': l});

    // 組 patched，讓 Story.fromJson 能吃，且攜帶 external*Html 給頁面 fallback 使用
    final Map<String, dynamic> patched = {
      'style': 'external',
      'name': ext['name'],
      'publishTime': ext['publishTime'],
      'updatedAt': ext['updatedAt'],
      'heroCaption': ext['heroCaption'],
      'otherbyline': ext['byline'],
      'heroImage': {
        'mobile': ext['thumbnail'] ?? Environment().config.mirrorNewsDefaultImageUrl,
        'desktop': ext['thumbnail'] ?? Environment().config.mirrorNewsDefaultImageUrl,
      },
      'categories': ext['categories'] ?? const [],
      'tags': ext['tags'] ?? const [],

      // external 若真的帶了 apiData 就沿用；沒有則給空（由頁面 fallback HTML）
      'briefApiData': _wrapApiDataString(briefApiData),
      'contentApiData': _wrapApiDataString(contentApiData),

      // 乾淨 HTML（頁面 _buildBrief/_buildContent 直接 fallback 用）
      'externalBriefHtml': briefHtmlClean,
      'externalContentHtml': contentHtmlClean,

      // 避免 NPE
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
      final story = Story.fromJson(patched);
      print('[StoryService] Story.fromJson ok: '
          'brief.paragraphs=${story.brief?.length ?? -1}, '
          'content.paragraphs=${story.contentApiData?.length ?? -1}');
      return story;
    } catch (e) {
      print('[StoryService] external normalize parse error: $e');
      throw FormatException('External normalize failed: $e');
    }
  }

  /// 嘗試把 section（可能是 JSON 字串）解成物件後，拿出其中的 html 欄位。
  String? _extractHtml(dynamic section) {
    final obj = _coerceObj(section);
    if (obj == null) return null;
    final html = obj['html'];
    if (html is String && html.trim().isNotEmpty) {
      return html;
    }
    return null;
  }

  /// 把 HTML 做些微清理以提升相容性：
  /// - 將 <figure> 改為 <div>，避免某些 renderer 對 figure 支援不佳
  /// - 若仍有跳脫殘留（\\"、\\/），做一次反跳脫
  String _sanitizeHtml(String html) {
    var s = html;

    // 反跳脫（保險）
    s = s
        .replaceAll(r'\"', '"')
        .replaceAll(r"\'", "'")
        .replaceAll(r'\/', '/')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\t', '\t');

    // figure → div
    s = s
    // <figure ...> -> <div ...>
        .replaceAll(RegExp(r'<\s*figure\b', caseSensitive: false), '<div')
    // </figure> -> </div>
        .replaceAll(RegExp(r'</\s*figure\s*>', caseSensitive: false), '</div>');

    return s;
  }

  /// 取出 apiData；若沒有就回空陣列，讓頁面改用 fallback HTML。
  List<dynamic> _buildApiDataFromSection(dynamic section) {
    final obj = _coerceObj(section);
    final maybeApi = obj?['apiData'];
    if (maybeApi is List && maybeApi.isNotEmpty) {
      final ok = maybeApi.whereType<Map>().every((e) => e.containsKey('type'));
      if (ok) return maybeApi;
    }
    return const [];
  }

  /// 字串 → 嘗試 json.decode；維持 Map 型別；否則回 null
  Map<String, dynamic>? _coerceObj(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is String) {
      try {
        final decoded = json.decode(v);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        // 不是 JSON 字串就略過
      }
    }
    return null;
  }
}
