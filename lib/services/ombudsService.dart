import 'dart:convert';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItem.dart';

abstract class OmbudsServiceRepos {
  Future<List<StoryListItem>> fetchLatestNews({
    int skip = 0,
    int first = 10,
    bool withCount = true,
  });
  int allStoryCount = 0;
}

class OmbudsService implements OmbudsServiceRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  int allStoryCount = 0;

  @override
  Future<List<StoryListItem>> fetchLatestNews({
    int skip = 0,
    int first = 10,
    bool withCount = true,
  }) async {
    const String query = """
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

      postsCount(where: \$where) @include(if: \$withCount)
    }
    """;

    final String key = 'fetchStoryListByOmbuds&skip=$skip&first=$first';

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "categories": {
          "some": {
            "slug": {"equals": "ombuds"}
          }
        },
        "slug": {
          "notIn": [
            'biography',
            'law',
            'standards',
            'faq',
            'reports',
            'complaint'
          ]
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

    if (withCount) {
      allStoryCount = jsonResponse['data']['postsCount'];
    }

    return List<StoryListItem>.from(
      jsonResponse['data']['posts'].map((item) => StoryListItem.fromJson(item)),
    );
  }
}