import 'dart:convert';

import 'package:tv/baseConfig.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class NewsMarqueeRepos {
  Future<StoryListItemList> fetchNewsList();
}

class NewsMarqueeServices implements NewsMarqueeRepos {
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<StoryListItemList> fetchNewsList() async {
    final key = 'fetchNewsMarqueeList';

    String query = """
    query (
      \$where: PostWhereInput,
      \$first: Int,
    ) {
      allPosts(
        where: \$where, 
        first: \$first, 
        sortBy: [ publishTime_DESC ]
      ) {
        slug
        name
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "style_not_in": ["wide", "projects", "script", "campaign", "readr"],
        "slug_not_in": filteredSlug,
        "categories_every": {"slug_not_in": "ombuds"},
        // TODO: need to be confirmed
        // "categories_some": {
        //   "slug_in": [],
        // }
      },
      "first": 10
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, baseConfig!.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: newsMarqueeCacheDuration,
        headers: {"Content-Type": "application/json"});

    StoryListItemList newsList =
        StoryListItemList.fromJson(jsonResponse['data']['allPosts']);
    return newsList;
  }
}
