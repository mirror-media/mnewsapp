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
      heroImage {
        imageApiData
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
    final String key =
        'fetchStoryListByTagSlug?tagSlug=$slug&skip=$skip&first=$first';

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "tags": {
          "some": {
            "slug": {"equals": slug}
          }
        }
      },
      "skip": skip,
      "take": first,
      "withCount": withCount,
    };

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (skip > 20) {
      jsonResponse = await _helper.postByUrl(
        Environment().config.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        headers: {"Content-Type": "application/json"},
      );
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(
        key,
        Environment().config.graphqlApi,
        jsonEncode(graphqlBody.toJson()),
        maxAge: newsTabStoryList,
        headers: {"Content-Type": "application/json"},
      );
    }

    final List<StoryListItem> newsList = List<StoryListItem>.from(
      jsonResponse['data']['posts'].map((post) => StoryListItem.fromJson(post)),
    );

    if (withCount) {
      allStoryCount = jsonResponse['data']['postsCount'];
    }

    return newsList;
  }
}