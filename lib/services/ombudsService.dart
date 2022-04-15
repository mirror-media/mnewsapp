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
    String key = 'fetchStoryListByOmbuds&skip=$skip&first=$first';

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "categories_some": {"slug": 'ombuds'},
        "slug_not_in": [
          'biography',
          'law',
          'standards',
          'faq',
          'reports',
          'complaint'
        ]
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
    if (withCount) {
      allStoryCount = jsonResponse['data']['_allPostsMeta']['count'];
    }
    return List<StoryListItem>.from(jsonResponse['data']['allPosts']
        .map((item) => StoryListItem.fromJson(item)));
  }
}
