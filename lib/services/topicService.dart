import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/topicList.dart';
import 'package:tv/models/topicStoryList.dart';

class TopicService {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<TopicList> fetchFeaturedTopics() async {
    String key = 'fetchFeaturedTopics';

    Map<String, dynamic> variables = {
      "where": {"state": "published"},
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
      isFeatured
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

  Future<TopicList> fetchTopicList() async {
    String key = 'fetchTopicList';

    Map<String, dynamic> variables = {
      "where": {"state": "published"}
    };

    final String query = """
    query (
    \$where: TopicWhereInput,
  ) {
    allTopics(
      where: \$where,
      sortBy: [sortOrder_ASC, isFeatured_DESC, updatedBy_DESC ]
    ) {
      id
      slug
      name
      brief
      isFeatured
      heroImage{
        urlMobileSized
      }
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
        maxAge: topicListCacheDuration,
        headers: {"Content-Type": "application/json"});

    TopicList topics = TopicList.fromJson(jsonResponse['data']['allTopics']);
    return topics;
  }

  Future<TopicStoryList> fetchTopicStoryList(
    String slug, {
    int skip = 0,
    int first = 8,
    bool withCount = true,
  }) async {
    String key = 'fetchTopicStoryList&slug=$slug&skip=$skip';

    Map<String, dynamic> variables = {
      "where": {"state": "published", "slug": slug},
      "first": first,
      "skip": skip,
      "withCount": withCount
    };

    final String query = """
    query (
    \$where: TopicWhereInput,
    \$first: Int,
    \$skip: Int,
    \$withCount: Boolean!
  ) {
    allTopics(
      where: \$where
    ) {
      leading
      heroImage{
        urlMobileSized
      }
      heroVideo{
				url
			}
      multivideo{
				url
			}
			slideshow{
				id
				name
				slug
				categories{
          name
        }
        heroImage{
          urlMobileSized
        }
			}
      post(
        where: {state: published},
        sortBy: [updatedAt_DESC],
        first: \$first,
        skip: \$skip
      ){
        id
        name
        slug
        categories{
          name
        }
        heroImage{
          urlMobileSized
        }
      }
      _postMeta(
        where: {state: published}
       )@include(if: \$withCount){
        count
      }
    }
  }
    """;

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final jsonResponse;
    if (skip > 16) {
      jsonResponse = await _helper.postByUrl(
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          headers: {"Content-Type": "application/json"});
    } else {
      jsonResponse = await _helper.postByCacheAndAutoCache(key,
          Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
          maxAge: newsTabStoryList,
          headers: {"Content-Type": "application/json"});
    }

    TopicStoryList topicStoryList = TopicStoryList.fromJson(
      jsonResponse['data']['allTopics'][0],
      withCount: withCount,
    );

    return topicStoryList;
  }
}
