import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/topicStoryList.dart';
import 'package:tv/services/topicService.dart';

part 'events.dart';
part 'states.dart';

class TopicStoryListBloc
    extends Bloc<TopicStoryListEvents, TopicStoryListState> {
  final TopicService topicService = TopicService();
  late String topicSlug;

  TopicStoryListBloc() : super(const TopicStoryListState.initial());

  Stream<TopicStoryListState> mapEventToState(
      TopicStoryListEvents event) async* {
    print(event.toString());
    try {
      if (event is FetchTopicStoryList) {
        yield const TopicStoryListState.loading();
        topicSlug = event.slug;
        TopicStoryList topicStoryList =
            await topicService.fetchTopicStoryList(topicSlug);
        yield TopicStoryListState.loaded(
          topicStoryList: topicStoryList,
        );
      } else if (event is FetchTopicStoryListMore) {
        TopicStoryList topicStoryList = state.topicStoryList!;
        TopicStoryList newTopicStoryList =
            await topicService.fetchTopicStoryList(
          topicSlug,
          skip: topicStoryList.storyListItemList!.length,
          first: event.loadingMoreAmount,
          withCount: false,
        );

        if (newTopicStoryList.storyListItemList != null) {
          for (var item in topicStoryList.storyListItemList!) {
            newTopicStoryList.storyListItemList!
                .removeWhere((element) => element.id == item.id);
          }
          topicStoryList.storyListItemList!
              .addAll(newTopicStoryList.storyListItemList!);
        }
        yield TopicStoryListState.loaded(
          topicStoryList: topicStoryList,
        );
      }
    } catch (e) {
      if (event is FetchTopicStoryListMore) {
        Fluttertoast.showToast(
            msg: "加載失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        await Future.delayed(Duration(seconds: 5));
        yield TopicStoryListState.loadingMoreFail();
      } else if (e is SocketException) {
        yield TopicStoryListState.error(
          error: NoInternetException('No Internet'),
        );
      } else if (e is HttpException) {
        yield TopicStoryListState.error(
          error: NoServiceFoundException('No Service Found'),
        );
      } else if (e is FormatException) {
        yield TopicStoryListState.error(
          error: InvalidFormatException('Invalid Response format'),
        );
      } else if (e is FetchDataException) {
        yield TopicStoryListState.error(
          error: NoInternetException('Error During Communication'),
        );
      } else if (e is BadRequestException ||
          e is UnauthorisedException ||
          e is InvalidInputException) {
        yield TopicStoryListState.error(
          error: Error400Exception('Unauthorised'),
        );
      } else if (e is InternalServerErrorException) {
        yield TopicStoryListState.error(
          error: Error500Exception('Internal Server Error'),
        );
      } else {
        yield TopicStoryListState.error(
          error: UnknownException(e.toString()),
        );
      }
    }
  }
}
