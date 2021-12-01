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

  TabStoryListBloc({required this.tabStoryListRepos})
      : super(TabStoryListState.init());

  // TODO: https://github.com/dart-lang/sdk/issues/42466
  @override
  Stream<TabStoryListState> mapEventToState(TabStoryListEvents event) async* {
    print(event.toString());
    try {
      if (event is FetchStoryList) {
        yield TabStoryListState.loading();
        StoryListItemList storyListItemList = await tabStoryListRepos.fetchStoryList();
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId =
            AdUnitId.fromJson(fixedAdUnitId, event.isVideo ? 'video' : 'news');
        yield TabStoryListState.loaded(
            storyListItemList: storyListItemList, adUnitId: adUnitId);
      } else if (event is FetchNextPage) {
        StoryListItemList storyListItemList = state.storyListItemList!;
        yield TabStoryListState.loadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList = await tabStoryListRepos
            .fetchStoryList(
              skip: storyListItemList.length,
              first: storyListItemList.length + event.loadingMorePage,
            );
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListState.loaded(storyListItemList: storyListItemList);
      } else if (event is FetchStoryListByCategorySlug) {
        yield TabStoryListState.loading();
        StoryListItemList storyListItemList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(event.slug);
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId;
        if (event.isVideo) {
          adUnitId = AdUnitId.fromJson(fixedAdUnitId, 'video');
        } else {
          adUnitId = AdUnitId.fromJson(fixedAdUnitId, event.slug);
        }
        yield TabStoryListState.loaded(
            storyListItemList: storyListItemList, adUnitId: adUnitId);
      } else if (event is FetchNextPageByCategorySlug) {
        StoryListItemList storyListItemList = state.storyListItemList!;
        yield TabStoryListState.loadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList =
            await tabStoryListRepos.fetchStoryListByCategorySlug(
              event.slug,
              skip: storyListItemList.length,
              first: storyListItemList.length + event.loadingMorePage,
            );
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListState.loaded(storyListItemList: storyListItemList);
      } else if (event is FetchPopularStoryList) {
        yield TabStoryListState.loading();
        StoryListItemList storyListItemList = await tabStoryListRepos.fetchPopularStoryList();
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId =
            AdUnitId.fromJson(fixedAdUnitId, event.isVideo ? 'video' : 'news');
        yield TabStoryListState.loaded(
            storyListItemList: storyListItemList, adUnitId: adUnitId);
      }
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
        yield TabStoryListState.loadingMoreError(
          storyListItemList: state.storyListItemList!,
          errorMessages: e.toString(),
        );
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
        yield TabStoryListState.loadingMoreError(
          storyListItemList: state.storyListItemList!,
          errorMessages: e.toString(),
        );
      } else if(e is SocketException) {
        yield TabStoryListState.error(
          errorMessages: NoInternetException('No Internet'),
        );
      } else if(e is HttpException) {
        yield TabStoryListState.error(
          errorMessages: NoServiceFoundException('No Service Found'),
        );
      } else if(e is FormatException) {
        yield TabStoryListState.error(
          errorMessages: InvalidFormatException('Invalid Response format'),
        );
      } else if(e is FetchDataException) {
        yield TabStoryListState.error(
          errorMessages: NoInternetException('Error During Communication'),
        );
      } else if(e is BadRequestException) {
        yield TabStoryListState.error(
          errorMessages: Error400Exception('Invalid Request'),
        );
      } else if(e is UnauthorisedException) {
        yield TabStoryListState.error(
          errorMessages: Error400Exception('Unauthorised'),
        );
      } else if(e is InvalidInputException) {
        yield TabStoryListState.error(
          errorMessages: Error400Exception('Invalid Input'),
        );
      } else if(e is InternalServerErrorException) {
        yield TabStoryListState.error(
          errorMessages: Error500Exception('Internal Server Error'),
        );
      } else {
        yield TabStoryListState.error(
          errorMessages: UnknownException(e.toString()),
        );
      }
    }
  }
}
