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

  ApiBaseHelper _helper = ApiBaseHelper();

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
    String queryString =
        QueryCommand.getYoutubeStreamList.format(['mnews-live']);
    final result =
        await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('allVideos')) return null;
    final videoList = result.data!['allVideos'] as List<dynamic>;
    if (videoList.isEmpty) return null;
    return videoList[0]['youtubeUrl'];
  }

  Future<List<String>> getLiveCamUrlList() async {
    String queryString = QueryCommand.getYoutubeStreamList.format(['live-cam']);
    final result =
        await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('allVideos')) return [];
    final videoList = result.data!['allVideos'] as List<dynamic>;
    return videoList.map((video) => video!['youtubeUrl'].toString()).toList();
  }

  Future<List<StoryListItem>> getVideoPostsList(
      {required String slug, int? skip = 0, int? take = 20}) async {
    ///熱門頁面 透過Json file更新 並且沒有第二頁的機制因此回傳空陣列
    if (slug == 'popular') {
      if (skip != 0) return [];
      final jsonResponse =
          await _helper.getByUrl(Environment().config.videoPopularListUrl)
              as Map<String, dynamic>;
      if (!jsonResponse.containsKey('report')) return [];
      final postList = jsonResponse['report'] as List<dynamic>;
      return postList.map((e) => StoryListItem.fromJson(e)).toList();
    } else {
      String queryString =
          QueryCommand.getVideoPostList.format([slug, skip, take]);
      final result =
          await client?.value.query(QueryOptions(document: gql(queryString)));
      if (result == null ||
          result.data == null ||
          !result.data!.containsKey('allPosts')) return [];
      final postList = result.data!['allPosts'] as List<dynamic>;
      return postList.map((e) => StoryListItem.fromJson(e)).toList();
    }
  }

  Future<List<Category>> getVideoPageCategoryList() async {
    final jsonResponse = await _helper.getByCacheAndAutoCache(
        Environment().config.categoriesUrl,
        maxAge: categoryCacheDuration,
        headers: {"Accept": "application/json"});

    List<Category> categoryList = List<Category>.from(
        jsonResponse['allCategories']
            .map((category) => Category.fromJson(category)));

    /// cuz video page is in the home drawer sections
    categoryList.removeWhere((category) => category.slug == 'video');

    /// do not display home slug in app
    categoryList.removeWhere((category) => category.slug == 'home');

    String jsonFixed = await rootBundle.loadString(videoMenuJson);
    final fixedMenu = json.decode(jsonFixed);
    List<Category> fixedCategoryList = List<Category>.from(
        fixedMenu.map((category) => Category.fromJson(category)));

    fixedCategoryList.addAll(categoryList);
    fixedCategoryList.removeWhere((element) => element.name == "精選");
    return fixedCategoryList;
  }

  Future<ShowIntro?> getShowIntro({required String slug}) async {
    String queryString = QueryCommand.getShowBySlug.format([slug]);
    final result =
        await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result?.data == null) return null;
    final resultData = result?.data as Map<String, dynamic>;
    if (!resultData.containsKey('allShows')) return null;

    final showIntro = ShowIntro.fromJson(resultData['allShows'][0]);
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
    final response = await _helper.getByUrl(Environment().config.podcastAPIUrl,
        needErrorHandler: false);

    String utf8Json = utf8.decode(response.bodyBytes);
    final responseJson = json.decode(utf8Json) as List<dynamic>;

    if (responseJson.isEmpty) return [];
    return responseJson.map((e) => PodcastInfo.fromJson(e)).toList();
  }

  Future<List<StoryListItem>> fetchEditorChoiceList() async {
    final key = 'fetchEditorChoiceList';

    String query = """
    query(
      \$where: EditorChoiceWhereInput, 
      \$first: Int){
      allEditorChoices(
        where: \$where, 
        first: \$first, 
        sortBy: [sortOrder_ASC, createdAt_DESC]
      ) {
        choice {
          id
          name
          slug
          style
          heroImage {
            urlMobileSized
          }
          heroVideo {
            coverPhoto {
              urlMobileSized
            }
          }
        }
      }
    }
    """;

    Map<String, dynamic> variables = {
      "where": {
        "state": "published",
        "choice": {"state": "published"}
      },
      "first": 10
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    final jsonResponse = await _helper.postByCacheAndAutoCache(
        key, Environment().config.graphqlApi, jsonEncode(graphqlBody.toJson()),
        maxAge: editorChoiceCacheDuration,
        headers: {"Content-Type": "application/json"});

    List<dynamic> parsedJson = List.empty(growable: true);
    for (int i = 0; i < jsonResponse['data']['allEditorChoices'].length; i++) {
      parsedJson.add(jsonResponse['data']['allEditorChoices'][i]['choice']);
    }
    List<StoryListItem> editorChoiceList = List<StoryListItem>.from(
        parsedJson.map((editorChoice) => StoryListItem.fromJson(editorChoice)));
    return editorChoiceList;
  }

  Future<List<StoryListItem>> getLatestArticles(
      {int? skip = 0, int? first = 20}) async {
    String queryString = QueryCommand.getLatestArticles.format([skip, first]);
    final result =
        await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('allPosts')) return [];
    final allPostsList = result.data!['allPosts'] as List<dynamic>;
    return allPostsList.map((e) => StoryListItem.fromJson(e)).toList();
  }

  Future<List<StoryListItem>> getSalesArticles() async {
    String queryString = QueryCommand.getSalesArticles;
    final result =
        await client?.value.query(QueryOptions(document: gql(queryString)));
    if (result == null ||
        result.data == null ||
        !result.data!.containsKey('allSales')) return [];
    final allPostsList = result.data!['allSales'] as List<dynamic>;
    return allPostsList.map((e) => StoryListItem.fromJsonSales(e)).toList();
  }
}
