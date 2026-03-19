import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItem.dart';

abstract class TagStoryListRepos {
  Future<List<StoryListItem>> fetchStoryListByTagSlug(
      String slug, {
        int skip = 0,
        int first = 10,
        bool withCount = true,
      });

  int allStoryCount = 0;
}

class TagStoryListServices implements TagStoryListRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  int allStoryCount = 0;

  final String query = """
  query (
    \$where: PostWhereInput,
    \$skip: Int,
    \$take: Int,
    \$withCount: Boolean!
  ) {
    posts(
      where: \$where,
      skip: \$skip,
      take: \$take,
      orderBy: [{ publishTime: desc }]
    ) {
      id
      slug
      name
      style

      heroImage {
        imageApiData
      }

      heroVideo {
        coverPhoto {
          imageApiData
        }
      }

      categories {
        id
        slug
        name
      }
    }

    postsCount(
      where: \$where
    ) @include(if: \$withCount)
  }
  """;

  @override
  Future<List<StoryListItem>> fetchStoryListByTagSlug(
      String slug, {
        int skip = 0,
        int first = 10,
        bool withCount = true,
      }) async {
    print('===== fetchStoryListByTagSlug start =====');
    print('incoming slug = $slug');

    // ---------- 第一段：用 slug 查 ----------
    List<StoryListItem> result = await _fetch(
      slug,
      isUseId: false,
      skip: skip,
      first: first,
      withCount: withCount,
    );

    // ---------- fallback：如果查不到 → 改用 id ----------
    if (result.isEmpty) {
      print('⚠️ slug 查不到，改用 id 再查一次');

      result = await _fetch(
        slug,
        isUseId: true,
        skip: skip,
        first: first,
        withCount: withCount,
      );
    }

    print('===== fetchStoryListByTagSlug end =====');
    return result;
  }

  Future<List<StoryListItem>> _fetch(
      String value, {
        required bool isUseId,
        required int skip,
        required int first,
        required bool withCount,
      }) async {
    final key =
        'fetchTag?value=$value&type=${isUseId ? "id" : "slug"}&skip=$skip&first=$first';

    print('---- _fetch start ----');
    print('use ${isUseId ? "id" : "slug"} = $value');

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "tags": {
          "some": isUseId
              ? {
            "id": {"equals": value}
          }
              : {
            "slug": {"equals": value}
          }
        }
      },
      "skip": skip,
      "take": first,
      "withCount": withCount,
    };

    print('variables = ${jsonEncode(variables)}');

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    print('request = ${jsonEncode(graphqlBody.toJson())}');

    try {
      final jsonResponse = await _helper.postByCacheAndAutoCache(
        key,
        Environment().config.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        maxAge: newsTabStoryList,
        headers: {"Content-Type": "application/json"},
      );

      print('response = $jsonResponse');

      final List<dynamic> posts =
          (jsonResponse['data']?['posts'] as List?) ?? [];

      print('posts length = ${posts.length}');

      final List<StoryListItem> list = List<StoryListItem>.from(
        posts.map((post) => StoryListItem.fromJson(post)),
      );

      if (withCount) {
        allStoryCount = jsonResponse['data']?['postsCount'] ?? 0;
      }

      print('postsCount = $allStoryCount');
      print('---- _fetch end ----');

      return list;
    } catch (e) {
      print('❌ _fetch error = $e');
      rethrow;
    }
  }
}