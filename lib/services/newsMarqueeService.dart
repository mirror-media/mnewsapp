import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/apiConstants.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class NewsMarqueeRepos {
  Future<StoryListItemList> fetchNewsList();
}

class NewsMarqueeServices implements NewsMarqueeRepos{
  ApiBaseHelper _helper = ApiBaseHelper();

  @override
  Future<StoryListItemList> fetchNewsList() async {
    String query = 
    """
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

    final jsonResponse = await _helper.postByUrl(
      graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      headers: {
        "Content-Type": "application/json"
      }
    );

    StoryListItemList newsList = StoryListItemList.fromJson(jsonResponse['data']['allPosts']);    
    return newsList;
  }
}
