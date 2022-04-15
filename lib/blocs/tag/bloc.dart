import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/tagStoryListService.dart';

part 'events.dart';
part 'states.dart';

class TagStoryListBloc extends Bloc<TagStoryListEvents, TagStoryListState> {
  final TagStoryListRepos tagStoryListRepos = TagStoryListServices();
  List<StoryListItem> tagStoryList = [];

  TagStoryListBloc() : super(const TagStoryListState.initial());

  @override
  Stream<TagStoryListState> mapEventToState(TagStoryListEvents event) async* {
    print(event.toString());
    try {
      if (event is FetchStoryListByTagSlug) {
        yield const TagStoryListState.loading();
        tagStoryList =
            await tagStoryListRepos.fetchStoryListByTagSlug(event.slug);

        yield TagStoryListState.loaded(
          tagStoryList: tagStoryList,
          allStoryCount: tagStoryListRepos.allStoryCount,
        );
      }

      if (event is FetchNextPageByTagSlug) {
        yield TagStoryListState.loadingMore(
          tagStoryList: tagStoryList,
        );

        List<StoryListItem> newStoryListItemList =
            await tagStoryListRepos.fetchStoryListByTagSlug(
          event.slug,
          skip: tagStoryList.length,
          withCount: false,
        );
        for (var item in tagStoryList) {
          newStoryListItemList.removeWhere((element) => element.id == item.id);
        }
        tagStoryList.addAll(newStoryListItemList);
        yield TagStoryListState.loaded(
          tagStoryList: tagStoryList,
          allStoryCount: tagStoryListRepos.allStoryCount,
        );
      }
    } catch (e) {
      if (event is FetchNextPageByTagSlug) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(const Duration(seconds: 5));
        yield TagStoryListState.loadingMoreFail(
          tagStoryList: tagStoryList,
        );
      } else if (e is SocketException) {
        yield TagStoryListState.error(
          error: NoInternetException('No Internet'),
        );
      } else if (e is HttpException) {
        yield TagStoryListState.error(
          error: NoServiceFoundException('No Service Found'),
        );
      } else if (e is FormatException) {
        yield TagStoryListState.error(
          error: InvalidFormatException('Invalid Response format'),
        );
      } else if (e is FetchDataException) {
        yield TagStoryListState.error(
          error: NoInternetException('Error During Communication'),
        );
      } else if (e is BadRequestException ||
          e is UnauthorisedException ||
          e is InvalidInputException) {
        yield TagStoryListState.error(
          error: Error400Exception('Unauthorised'),
        );
      } else if (e is InternalServerErrorException) {
        yield TagStoryListState.error(
          error: Error500Exception('Internal Server Error'),
        );
      } else {
        yield TagStoryListState.error(
          error: UnknownException(e.toString()),
        );
      }
    }
  }
}
