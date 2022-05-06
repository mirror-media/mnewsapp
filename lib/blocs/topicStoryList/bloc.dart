import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/topicStoryList.dart';
import 'package:tv/services/topicService.dart';

part 'events.dart';
part 'states.dart';

class TopicStoryListBloc
    extends Bloc<TopicStoryListEvents, TopicStoryListState> {
  final TopicService topicService = TopicService();
  late String topicSlug;

  TopicStoryListBloc() : super(const TopicStoryListState.initial()) {
    on<TopicStoryListEvents>((event, emit) async {
      print(event.toString());
      try {
        if (event is FetchTopicStoryList) {
          emit(const TopicStoryListState.loading());
          topicSlug = event.slug;
          TopicStoryList topicStoryList =
              await topicService.fetchTopicStoryList(topicSlug);
          emit(TopicStoryListState.loaded(
            topicStoryList: topicStoryList,
          ));
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
          emit(TopicStoryListState.loaded(
            topicStoryList: topicStoryList,
          ));
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
          emit(TopicStoryListState.loadingMoreFail());
        } else {
          emit(TopicStoryListState.error(
            error: determineException(e),
          ));
        }
      }
    });
  }
}
