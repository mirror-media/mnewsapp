import 'dart:convert';

import 'package:tv/helpers/environment.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItem.dart';

abstract class NewsMarqueeRepos {
  Future<List<StoryListItem>> fetchNewsList();
}

class NewsMarqueeServices implements NewsMarqueeRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<List<StoryListItem>> fetchNewsList() async {
    final key = 'fetchNewsMarqueeList';

    const String query = """
    query (
      \$where: PostWhereInput,
      \$take: Int
    ) {
      posts(
        where: \$where,
        take: \$take,
        orderBy: [{ publishTime: desc }]
      ) {
        slug
        name
      }
    }
    """;

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "style": {
          "notIn": ["wide", "projects", "script", "campaign", "readr"]
        },
        "slug": {
          "notIn": filteredSlug
        },
        "categories": {
          "every": {
            "slug": {
              "notIn": ["ombuds"]
            }
          }
        },
        // TODO: need to be confirmed
        // "categories": {
        //   "some": {
        //     "slug": {
        //       "in": []
        //     }
        //   }
        // }
      },
      "take": 10
    };

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: newsMarqueeCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    final List<StoryListItem> newsList = List<StoryListItem>.from(
      jsonResponse['data']['posts'].map((post) => StoryListItem.fromJson(post)),
    );

    return newsList;
  }
}