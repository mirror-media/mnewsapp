import 'dart:convert';

import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/models/topicStoryList.dart';

class TopicService {
  final ApiBaseHelper _helper = ApiBaseHelper();

  Future<List<Topic>> fetchFeaturedTopics() async {
    const String key = 'fetchFeaturedTopics';

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"}
      },
      "take": 5,
    };

    const String query = """
    query (
      \$where: TopicWhereInput,
      \$take: Int
    ) {
      topics(
        where: \$where,
        take: \$take,
        orderBy: [{ sortOrder: asc }, { updatedAt: desc }]
      ) {
        id
        slug
        name
        isFeatured
      }
    }
    """;

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: featuredTopicCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    final List<Topic> topics = List<Topic>.from(
      jsonResponse['data']['topics'].map((topic) => Topic.fromJson(topic)),
    );

    return topics;
  }

  Future<List<Topic>> fetchTopicList() async {
    const String key = 'fetchTopicList';

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"}
      }
    };

    const String query = """
    query (
      \$where: TopicWhereInput
    ) {
      topics(
        where: \$where,
        orderBy: [{ sortOrder: asc }, { updatedAt: desc }]
      ) {
        id
        slug
        name
        brief
        isFeatured
        heroImage {
          imageApiData
        }
      }
    }
    """;

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: topicListCacheDuration,
      headers: {"Content-Type": "application/json"},
    );

    final List<Topic> topics = List<Topic>.from(
      jsonResponse['data']['topics'].map((topic) => Topic.fromJson(topic)),
    );

    return topics;
  }

  Future<TopicStoryList> fetchTopicStoryList(
      String slug, {
        int skip = 0,
        int first = 8,
        bool withCount = true,
      }) async {
    final String key = 'fetchTopicStoryList&slug=$slug&skip=$skip';

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "slug": {"equals": slug}
      },
      "take": first,
      "skip": skip,
      "withCount": withCount,
    };

    const String query = """
    query (
      \$where: TopicWhereInput,
      \$take: Int,
      \$skip: Int,
      \$withCount: Boolean!
    ) {
      topics(
        where: \$where
      ) {
        leading
        heroImage {
          imageApiData
        }
        heroVideo {
          url
        }
        multivideo {
          url
        }
        slideshow {
          id
          name
          slug
          categories {
            name
          }
          heroImage {
            imageApiData
          }
        }
        post(
          where: {
            state: { equals: "published" }
          }
          orderBy: [{ updatedAt: desc }]
          take: \$take
          skip: \$skip
        ) {
          id
          name
          slug
          categories {
            name
          }
          heroImage {
            imageApiData
          }
        }
        postCount(
          where: {
            state: { equals: "published" }
          }
        ) @include(if: \$withCount)
      }
    }
    """;

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    if (skip > 16) {
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
    print('===== fetchTopicStoryList raw response =====');
    print(jsonResponse);
    final TopicStoryList topicStoryList = TopicStoryList.fromJson(
      jsonResponse['data']['topics'][0],
      withCount: withCount,
    );

    return topicStoryList;
  }
}