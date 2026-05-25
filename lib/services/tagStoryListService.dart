import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItem.dart';

/// tag 頁一次抓取的結果。
///
/// 內部文章（posts）與外部夥伴文章（externals，例如鏡報 / Mirror Daily）是
/// CMS 內兩個各自獨立的集合，這裡分開回傳，由 controller 各自維護分頁游標、
/// 再依發佈時間合併排序。
class TagStoryListResult {
  final List<StoryListItem> posts;
  final List<StoryListItem> externals;
  final int postsCount;
  final int externalsCount;

  const TagStoryListResult({
    this.posts = const [],
    this.externals = const [],
    this.postsCount = 0,
    this.externalsCount = 0,
  });
}

abstract class TagStoryListRepos {
  Future<TagStoryListResult> fetchStoryListByTagSlug(
    String slug, {
    int postsSkip = 0,
    int externalsSkip = 0,
    int first = 10,
    bool withCount = true,
    bool fetchPosts = true,
    bool fetchExternals = true,
  });
}

class TagStoryListServices implements TagStoryListRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  // 內部文章
  final String _postsQuery = """
  query (\$slug: String, \$skip: Int, \$take: Int, \$withCount: Boolean!) {
    posts(
      where: {
        state: { equals: "published" }
        tags: { some: { slug: { equals: \$slug } } }
      }
      skip: \$skip
      take: \$take
      orderBy: [{ publishTime: desc }]
    ) {
      id
      slug
      name
      style
      publishTime
      heroImage { imageApiData }
      heroVideo { coverPhoto { imageApiData } }
      categories { id slug name }
    }
    postsCount(
      where: {
        state: { equals: "published" }
        tags: { some: { slug: { equals: \$slug } } }
      }
    ) @include(if: \$withCount)
  }
  """;

  // 外部夥伴文章（鏡報 / Mirror Daily 等，存在獨立的 externals 集合）
  final String _externalsQuery = """
  query (\$slug: String, \$skip: Int, \$take: Int, \$withCount: Boolean!) {
    externals(
      where: {
        state: { equals: "published" }
        tags: { some: { slug: { equals: \$slug } } }
      }
      skip: \$skip
      take: \$take
      orderBy: [{ publishTime: desc }]
    ) {
      id
      slug
      name
      subtitle
      publishTime
      updatedAt
      thumbnail
      partner { id name slug }
      categories { id slug name }
    }
    externalsCount(
      where: {
        state: { equals: "published" }
        tags: { some: { slug: { equals: \$slug } } }
      }
    ) @include(if: \$withCount)
  }
  """;

  @override
  Future<TagStoryListResult> fetchStoryListByTagSlug(
    String slug, {
    int postsSkip = 0,
    int externalsSkip = 0,
    int first = 10,
    bool withCount = true,
    bool fetchPosts = true,
    bool fetchExternals = true,
  }) async {
    print('===== fetchStoryListByTagSlug start =====');
    print('slug = $slug, postsSkip = $postsSkip (fetch=$fetchPosts), '
        'externalsSkip = $externalsSkip (fetch=$fetchExternals)');

    // 內外兩來源同時查，互不阻塞
    final results = await Future.wait([
      fetchPosts
          ? _fetchPosts(slug, skip: postsSkip, first: first, withCount: withCount)
          : Future<_Chunk>.value(const _Chunk.empty()),
      fetchExternals
          ? _fetchExternals(slug,
              skip: externalsSkip, first: first, withCount: withCount)
          : Future<_Chunk>.value(const _Chunk.empty()),
    ]);

    final _Chunk postsChunk = results[0];
    final _Chunk externalsChunk = results[1];

    print('posts = ${postsChunk.items.length} / count ${postsChunk.count}');
    print('externals = ${externalsChunk.items.length} / count ${externalsChunk.count}');
    print('===== fetchStoryListByTagSlug end =====');

    return TagStoryListResult(
      posts: postsChunk.items,
      externals: externalsChunk.items,
      postsCount: postsChunk.count,
      externalsCount: externalsChunk.count,
    );
  }

  /// 內部 posts：發生錯誤往外丟，讓 controller 顯示錯誤畫面（例如無網路）。
  Future<_Chunk> _fetchPosts(
    String slug, {
    required int skip,
    required int first,
    required bool withCount,
  }) async {
    try {
      final jsonResponse = await _post(
        key: 'fetchTagPosts?slug=$slug&skip=$skip&first=$first',
        query: _postsQuery,
        slug: slug,
        skip: skip,
        first: first,
        withCount: withCount,
      );
      final List<dynamic> raw =
          (jsonResponse['data']?['posts'] as List?) ?? [];
      return _Chunk(
        items: raw.map((post) => StoryListItem.fromJson(post)).toList(),
        count: (jsonResponse['data']?['postsCount'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      print('❌ _fetchPosts error = $e');
      rethrow;
    }
  }

  /// 外部 externals：屬於附加內容，查詢失敗時不影響內部 posts，回傳空集合即可。
  Future<_Chunk> _fetchExternals(
    String slug, {
    required int skip,
    required int first,
    required bool withCount,
  }) async {
    try {
      final jsonResponse = await _post(
        key: 'fetchTagExternals?slug=$slug&skip=$skip&first=$first',
        query: _externalsQuery,
        slug: slug,
        skip: skip,
        first: first,
        withCount: withCount,
      );
      final List<dynamic> raw =
          (jsonResponse['data']?['externals'] as List?) ?? [];
      return _Chunk(
        items: raw.map((post) => StoryListItem.fromJson(post)).toList(),
        count: (jsonResponse['data']?['externalsCount'] as num?)?.toInt() ?? 0,
      );
    } catch (e) {
      print('❌ _fetchExternals error = $e（tag 頁將只顯示內部文章）');
      return const _Chunk.empty();
    }
  }

  Future<dynamic> _post({
    required String key,
    required String query,
    required String slug,
    required int skip,
    required int first,
    required bool withCount,
  }) async {
    final GraphqlBody body = GraphqlBody(
      operationName: null,
      query: query,
      variables: {
        "slug": slug,
        "skip": skip,
        "take": first,
        "withCount": withCount,
      },
    );

    return _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(body.toJson()),
      maxAge: newsTabStoryList,
      headers: {"Content-Type": "application/json"},
    );
  }
}

/// 單一來源（posts 或 externals）一次抓取的內容。
class _Chunk {
  final List<StoryListItem> items;
  final int count;

  const _Chunk({required this.items, required this.count});

  const _Chunk.empty()
      : items = const [],
        count = 0;
}
