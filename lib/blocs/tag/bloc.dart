import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/tagStoryListService.dart';

part 'events.dart';
part 'states.dart';

class TagStoryListBloc extends Bloc<TagStoryListEvents, TagStoryListState> {
  final TagStoryListRepos tagStoryListRepos = TagStoryListServices();
  List<StoryListItem> tagStoryList = [];

  TagStoryListBloc() : super(const TagStoryListState.initial()) {
    on<TagStoryListEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          if (event is FetchStoryListByTagSlug) {
            emit(const TagStoryListState.loading());
            tagStoryList =
                await tagStoryListRepos.fetchStoryListByTagSlug(event.slug);

            emit(TagStoryListState.loaded(
              tagStoryList: tagStoryList,
              allStoryCount: tagStoryListRepos.allStoryCount,
            ));
          }

          if (event is FetchNextPageByTagSlug) {
            emit(TagStoryListState.loadingMore(
              tagStoryList: tagStoryList,
            ));

            List<StoryListItem> newStoryListItemList =
                await tagStoryListRepos.fetchStoryListByTagSlug(
              event.slug,
              skip: tagStoryList.length,
              withCount: false,
            );
            for (var item in tagStoryList) {
              newStoryListItemList
                  .removeWhere((element) => element.id == item.id);
            }
            tagStoryList.addAll(newStoryListItemList);
            emit(TagStoryListState.loaded(
              tagStoryList: tagStoryList,
              allStoryCount: tagStoryListRepos.allStoryCount,
            ));
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
            emit(TagStoryListState.loadingMoreFail(
              tagStoryList: tagStoryList,
            ));
          } else {
            emit(TagStoryListState.error(
              error: determineException(e),
            ));
          }
        }
      },
    );
  }
}
