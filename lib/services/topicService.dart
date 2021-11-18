import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/topicList.dart';

class TopicService {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<TopicList> fetchFeaturedTopics() async {
    String key = 'fetchFeaturedTopics';

    Map<String, dynamic> variables = {
      "where": {"state": "published", "isFeatured": true},
      "first": 5
    };

    final String query = """
    query (
    \$where: TopicWhereInput,
    \$first: Int,
    ) {
    allTopics(
      where: \$where, 
      first: \$first, 
      sortBy: [ sortOrder_ASC, updatedBy_DESC ]
    ) {
      id
      slug
      name
      }
    }
    """;

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final jsonResponse;
    jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: featuredTopicCacheDuration,
        headers: {"Content-Type": "application/json"});

    TopicList topics = TopicList.fromJson(jsonResponse['data']['allTopics']);

    return topics;
  }
}
