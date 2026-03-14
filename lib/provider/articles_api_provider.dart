import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tv/core/extensions/string_extension.dart';
import 'package:tv/data/value/query.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tv/helpers/apiBaseHelper.dart';
import 'package:tv/helpers/cacheDurationCache.dart';
import 'package:tv/helpers/environment.dart';
import 'package:tv/models/category.dart';
import 'package:tv/models/graphqlBody.dart';
import 'package:tv/models/podcast_info/podcast_info.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/models/youtube_list_info.dart';

import '../helpers/dataConstants.dart';

class ArticlesApiProvider extends GetConnect {
  ArticlesApiProvider._();

  static final ArticlesApiProvider _instance = ArticlesApiProvider._();

  static ArticlesApiProvider get instance => _instance;
  ValueNotifier<GraphQLClient>? client;

  final ApiBaseHelper _helper = ApiBaseHelper();

  @override
  void onInit() {
    initGraphQLLink();
  }

  void initGraphQLLink() {
    final Link link = HttpLink(Environment().config.graphqlApi);
    client = ValueNotifier(
      GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      ),
    );
  }

  Future<String?> getNewsLiveUrl() async {
    final String queryString =
    QueryCommand.getYoutubeStreamList.format(['mnews-live']);
    final result =
    await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('videos')) return null;
    final videoList = result.data!['videos'] as List<dynamic>;
    if (videoList.isEmpty) return null;
    return videoList[0]['youtubeUrl'];
  }

  Future<List<String>> getLiveCamUrlList() async {
    final String queryString =
    QueryCommand.getYoutubeStreamList.format(['live-cam']);
    final result =
    await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('videos')) return [];
    final videoList = result.data!['videos'] as List<dynamic>;
    return videoList.map((video) => video['youtubeUrl'].toString()).toList();
  }

  Future<List<StoryListItem>> getVideoPostsList(
      {required String slug, int? skip = 0, int? take = 20}) async {
    if (slug == 'popular') {
      if (skip != 0) return [];
      final jsonResponse =
      await _helper.getByUrl(Environment().config.videoPopularListUrl)
      as Map<String, dynamic>;
      if (!jsonResponse.containsKey('report')) return [];
      final postList = jsonResponse['report'] as List<dynamic>;
      return postList.map((e) => StoryListItem.fromJson(e)).toList();
    } else {
      final String queryString =
      QueryCommand.getVideoPostList.format([slug, skip, take]);
      final result =
      await client?.value.query(QueryOptions(document: gql(queryString)));
      if (result == null ||
          result.data == null ||
          !result.data!.containsKey('posts')) return [];
      final postList = result.data!['posts'] as List<dynamic>;
      return postList.map((e) => StoryListItem.fromJson(e)).toList();
    }
  }

  Future<List<Category>> getVideoPageCategoryList() async {
    final jsonResponse = await _helper.getByCacheAndAutoCache(
      Environment().config.categoriesUrl,
      maxAge: categoryCacheDuration,
      headers: {"Accept": "application/json"},
    );

    final List<Category> categoryList = List<Category>.from(
      jsonResponse['allCategories']
          .map((category) => Category.fromJson(category)),
    );

    categoryList.removeWhere((category) => category.slug == 'video');
    categoryList.removeWhere((category) => category.slug == 'home');

    final String jsonFixed = await rootBundle.loadString(videoMenuJson);
    final fixedMenu = json.decode(jsonFixed);
    final List<Category> fixedCategoryList = List<Category>.from(
      fixedMenu.map((category) => Category.fromJson(category)),
    );

    fixedCategoryList.addAll(categoryList);
    fixedCategoryList.removeWhere((element) => element.name == "精選");
    return fixedCategoryList;
  }

  Future<ShowIntro?> getShowIntro({required String slug}) async {
    final String queryString = QueryCommand.getShowBySlug.format([slug]);
    final result =
    await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result?.data == null) return null;
    final resultData = result?.data as Map<String, dynamic>;
    if (!resultData.containsKey('shows')) return null;
    final shows = resultData['shows'] as List<dynamic>;
    if (shows.isEmpty) return null;

    final showIntro = ShowIntro.fromJson(shows[0]);
    return showIntro;
  }

  Future<YoutubeListInfo> getYoutubePlayList(
      {required String playListId,
        int? maxResult = 5,
        String? nextPageToken}) async {
    final url = nextPageToken != null
        ? '${Environment().config.youtubeApi}/playlistItems?part=snippet&playlistId=$playListId&pageToken=$nextPageToken&maxResults=$maxResult'
        : '${Environment().config.youtubeApi}/playlistItems?part=snippet&playlistId=$playListId&maxResults=$maxResult';

    final jsonResponse = await _helper.getByUrl(url);

    return YoutubeListInfo.fromJson(jsonResponse);
  }

  Future<List<PodcastInfo>> getPodcastInfoList() async {
    final response = await _helper.getByUrl(
      Environment().config.podcastAPIUrl,
      needErrorHandler: false,
    );

    final String utf8Json = utf8.decode(response.bodyBytes);
    final responseJson = json.decode(utf8Json) as List<dynamic>;

    if (responseJson.isEmpty) return [];
    return responseJson.map((e) => PodcastInfo.fromJson(e)).toList();
  }

  Future<List<StoryListItem>> fetchEditorChoiceList() async {
    final key = 'fetchEditorChoiceList';

    const String query = """
  query(
    \$where: EditorChoiceWhereInput,
    \$take: Int
  ) {
    editorChoices(
      where: \$where,
      take: \$take,
      orderBy: [{ sortOrder: asc }, { createdAt: desc }]
    ) {
      choice {
        id
        name
        slug
        style
        heroImage {
          imageApiData
        }
        heroVideo {
          coverPhoto {
            imageApiData
          }
        }
      }
    }
  }
  """;

    final Map<String, dynamic> variables = {
      "where": {
        "state": {"equals": "published"},
        "choice": {
          "state": {"equals": "published"}
        }
      },
      "take": 10
    };

    final GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    print('===== fetchEditorChoiceList graphqlApi =====');
    print(Environment().config.graphqlApi);

    print('===== fetchEditorChoiceList request body =====');
    print(jsonEncode(graphqlBody.toJson()));

    final jsonResponse = await _helper.postByCacheAndAutoCache(
      key,
      Environment().config.graphqlApi,
      jsonEncode(graphqlBody.toJson()),
      maxAge: editorChoiceCacheDuration,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );

    print('===== fetchEditorChoiceList response =====');
    print(jsonResponse);

    final List<dynamic> sourceList =
        (jsonResponse['data']?['editorChoices'] as List?) ?? [];

    final List<StoryListItem> editorChoiceList = sourceList
        .map((item) => item['choice'])
        .where((choice) => choice != null)
        .map<StoryListItem>((choice) => StoryListItem.fromJson(choice))
        .toList();

    return editorChoiceList;
  }

  Future<List<StoryListItem>> getLatestArticles(
      {int? skip = 0, int? first = 20}) async {
    final String queryString =
    QueryCommand.getLatestArticles.format([skip, first]);
    final result =
    await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('posts')) return [];
    final allPostsList = result.data!['posts'] as List<dynamic>;
    return allPostsList.map((e) => StoryListItem.fromJson(e)).toList();
  }

  Future<List<StoryListItem>> getSalesArticles() async {
    const String queryString = QueryCommand.getSalesArticles;
    final result =
    await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('sales')) return [];
    final allPostsList = result.data!['sales'] as List<dynamic>;
    return allPostsList.map((e) => StoryListItem.fromJsonSales(e)).toList();
  }
}
