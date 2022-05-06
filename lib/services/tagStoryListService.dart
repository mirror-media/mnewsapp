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
    \$first: Int,
    \$withCount: Boolean!,
  ) {
    allPosts(
      where: \$where, 
      skip: \$skip, 
      first: \$first, 
      sortBy: [ publishTime_DESC ]
    ) {
      id
      slug
      name
      heroImage {
        urlMobileSized
      }
    }
    _allPostsMeta(
      where: \$where,
    ) @include(if: \$withCount) {
      count
    }
  }
  """;

  @override
  Future<List<StoryListItem>> fetchStoryListByTagSlug(
    String slug, {
    int skip = 0,
    int first = 10,
    bool withCount = true,
  }) async {
    String key =
        'fetchStoryListByTagSlug?tagSlug=$slug&skip=$skip&first=$first';

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "tags_some": {"slug": slug}
      },
      "skip": skip,
      "first": first,
      "withCount": withCount
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (skip > 20) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(key,
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    List<StoryListItem> newsList = List<StoryListItem>.from(jsonResponse['data']
            ['allPosts']
        .map((post) => StoryListItem.fromJson(post)));

    if (withCount) {
      allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }

    return newsList;
  }
}
