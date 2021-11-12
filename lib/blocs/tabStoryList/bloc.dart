import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/tabStoryListService.dart';

class TabStoryListBloc extends Bloc<TabStoryListEvents, TabStoryListState> {
  final TabStoryListRepos tabStoryListRepos;
  StoryListItemList storyListItemList = StoryListItemList();

  TabStoryListBloc({required this.tabStoryListRepos})
      : super(TabStoryListInitState());

  // TODO: https://github.com/dart-lang/sdk/issues/42466
  @override
  Stream<TabStoryListState> mapEventToState(TabStoryListEvents event) async* {
    print(event.toString());
    try {
      yield TabStoryListLoading();
      if (event is FetchStoryList) {
        storyListItemList = await tabStoryListRepos.fetchStoryList();
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId =
            AdUnitId.fromJson(fixedAdUnitId, event.isVideo ? 'video' : 'news');
        yield TabStoryListLoaded(
            storyListItemList: storyListItemList, adUnitId: adUnitId);
      } else if (event is FetchNextPage) {
        yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList = await tabStoryListRepos
            .fetchStoryList(
              skip: storyListItemList.length,
              first: storyListItemList.length + event.loadingMorePage,
            );
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if (event is FetchStoryListByCategorySlug) {
        storyListItemList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(event.slug);
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId;
        if (event.isVideo) {
          adUnitId = AdUnitId.fromJson(fixedAdUnitId, 'video');
        } else {
          adUnitId = AdUnitId.fromJson(fixedAdUnitId, event.slug);
        }
        yield TabStoryListLoaded(
            storyListItemList: storyListItemList, adUnitId: adUnitId);
      } else if (event is FetchNextPageByCategorySlug) {
        yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(
              event.slug,
              skip: storyListItemList.length,
              first: storyListItemList.length + event.loadingMorePage,
            );
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if (event is FetchPopularStoryList) {
        storyListItemList = await tabStoryListRepos.fetchPopularStoryList();
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId =
            AdUnitId.fromJson(fixedAdUnitId, event.isVideo ? 'video' : 'news');
        yield TabStoryListLoaded(
            storyListItemList: storyListItemList, adUnitId: adUnitId);
      }
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
      if (event is FetchNextPage) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(Duration(seconds: 5));
        yield TabStoryListLoadingMoreFail(storyListItemList: storyListItemList);
      } else if (event is FetchNextPageByCategorySlug) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(Duration(seconds: 5));
        yield TabStoryListLoadingMoreFail(storyListItemList: storyListItemList);
      } else {
        yield TabStoryListError(
          error: UnknownException(e.toString()),
        );
      }
    }
  }
}
