import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/tabStoryListService.dart';

abstract class TabStoryListEvents {
  StoryListItemList storyListItemList = StoryListItemList();
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos);
}

class FetchStoryList extends TabStoryListEvents {
  @override
  String toString() => 'FetchStoryList';

  final bool isVideo;

  FetchStoryList({this.isVideo = false});

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async* {
    print(this.toString());
    try {
      yield TabStoryListLoading();
      storyListItemList = await tabStoryListRepos.fetchStoryList();
      String jsonFixed = await rootBundle.loadString(adUnitIdJson);
      final fixedAdUnitId = json.decode(jsonFixed);
      AdUnitId adUnitId =
          AdUnitId.fromJson(fixedAdUnitId, isVideo ? 'video' : 'news');
      yield TabStoryListLoaded(
          storyListItemList: storyListItemList, adUnitId: adUnitId);
    } on SocketException {
      yield TabStoryListError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield TabStoryListError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield TabStoryListError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield TabStoryListError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield TabStoryListError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield TabStoryListError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield TabStoryListError(
        error: UnknownException(e.toString()),
      );
    }
  }
}

class FetchNextPage extends TabStoryListEvents {
  final int loadingMorePage;

  FetchNextPage({this.loadingMorePage = 20});

  @override
  String toString() => 'FetchNextPage { loadingMorePage: $loadingMorePage }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async* {
    print(this.toString());
    try {
      yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
      StoryListItemList newStoryListItemList = await tabStoryListRepos
          .fetchNextPage(loadingMorePage: loadingMorePage);
      storyListItemList.addAll(newStoryListItemList);
      yield TabStoryListLoaded(storyListItemList: storyListItemList);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "加載失敗",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      await Future.delayed(Duration(seconds: 5));
      tabStoryListRepos.reduceSkip(loadingMorePage);
      yield TabStoryListLoadingMoreFail(storyListItemList: storyListItemList);
    }
  }
}

class FetchStoryListByCategorySlug extends TabStoryListEvents {
  final String slug;
  final bool isVideo;

  FetchStoryListByCategorySlug(this.slug, {this.isVideo = false});

  @override
  String toString() => 'FetchStoryListByCategorySlug { slug: $slug }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async* {
    print(this.toString());
    try {
      yield TabStoryListLoading();
      storyListItemList =
          await tabStoryListRepos.fetchStoryListByCategorySlug(slug);
      String jsonFixed = await rootBundle.loadString(adUnitIdJson);
      final fixedAdUnitId = json.decode(jsonFixed);
      AdUnitId adUnitId;
      if (isVideo) {
        adUnitId = AdUnitId.fromJson(fixedAdUnitId, 'video');
      } else {
        adUnitId = AdUnitId.fromJson(fixedAdUnitId, slug);
      }
      yield TabStoryListLoaded(
          storyListItemList: storyListItemList, adUnitId: adUnitId);
    } on SocketException {
      yield TabStoryListError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield TabStoryListError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield TabStoryListError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield TabStoryListError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield TabStoryListError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield TabStoryListError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield TabStoryListError(
        error: UnknownException(e.toString()),
      );
    }
  }
}

class FetchNextPageByCategorySlug extends TabStoryListEvents {
  final String slug;
  final int loadingMorePage;

  FetchNextPageByCategorySlug(this.slug, {this.loadingMorePage = 20});

  @override
  String toString() =>
      'FetchNextPageByCategorySlug { slug: $slug, loadingMorePage: $loadingMorePage }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async* {
    print(this.toString());
    try {
      yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
      StoryListItemList newStoryListItemList = await tabStoryListRepos
          .fetchNextPageByCategorySlug(slug, loadingMorePage: loadingMorePage);
      storyListItemList.addAll(newStoryListItemList);
      yield TabStoryListLoaded(storyListItemList: storyListItemList);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "加載失敗",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      await Future.delayed(Duration(seconds: 5));
      tabStoryListRepos.reduceSkip(loadingMorePage);
      yield TabStoryListLoadingMoreFail(storyListItemList: storyListItemList);
    }
  }
}

class FetchPopularStoryList extends TabStoryListEvents {
  bool isVideo;
  FetchPopularStoryList({this.isVideo = false});

  @override
  String toString() => 'FetchPopularStoryList';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async* {
    print(this.toString());
    try {
      yield TabStoryListLoading();
      storyListItemList = await tabStoryListRepos.fetchPopularStoryList();
      String jsonFixed = await rootBundle.loadString(adUnitIdJson);
      final fixedAdUnitId = json.decode(jsonFixed);
      AdUnitId adUnitId =
          AdUnitId.fromJson(fixedAdUnitId, isVideo ? 'video' : 'news');
      yield TabStoryListLoaded(
          storyListItemList: storyListItemList, adUnitId: adUnitId);
    } on SocketException {
      yield TabStoryListError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield TabStoryListError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield TabStoryListError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield TabStoryListError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield TabStoryListError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield TabStoryListError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield TabStoryListError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
