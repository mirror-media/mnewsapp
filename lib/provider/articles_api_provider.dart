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
import 'package:tv/models/storyListItem.dart';

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
    fixedCategoryList
        .removeWhere((element) => element.name == "精選" || element.name == "熱門");
    return fixedCategoryList;
  }
}
