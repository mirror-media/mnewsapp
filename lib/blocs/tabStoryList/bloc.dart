import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/tabStoryListService.dart';

class TabStoryListBloc extends Bloc<TabStoryListEvents, TabStoryListState> {
  final TabStoryListRepos tabStoryListRepos;

  TabStoryListBloc({required this.tabStoryListRepos})
      : super(TabStoryListState.init()) {
    on<TabStoryListEvents>(
      (event, emit) async {
        print(event.toString());
        try {
          if (event is FetchStoryList) {
            emit(TabStoryListState.loading());
            List<StoryListItem> storyListItemList =
                await tabStoryListRepos.fetchStoryList();
            emit(TabStoryListState.loaded(
              storyListItemList: storyListItemList,
              allStoryCount: tabStoryListRepos.allStoryCount,
            ));
          }

          if (event is FetchNextPage) {
            List<StoryListItem> storyListItemList = state.storyListItemList!;
            emit(TabStoryListState.loadingMore(
                storyListItemList: storyListItemList));
            List<StoryListItem> newStoryListItemList =
                await tabStoryListRepos.fetchStoryList(
              skip: storyListItemList.length,
              first: storyListItemList.length + event.loadingMorePage,
            );
            for (var item in storyListItemList) {
              newStoryListItemList
                  .removeWhere((element) => element.id == item.id);
            }
            storyListItemList.addAll(newStoryListItemList);
            emit(TabStoryListState.loaded(
              storyListItemList: storyListItemList,
              allStoryCount: tabStoryListRepos.allStoryCount,
            ));
          }

          if (event is FetchStoryListByCategorySlug) {
            emit(TabStoryListState.loading());
            List<StoryListItem> storyListItemList = await tabStoryListRepos
                .fetchStoryListByCategorySlug(event.slug);
            emit(TabStoryListState.loaded(
              storyListItemList: storyListItemList,
              allStoryCount: tabStoryListRepos.allStoryCount,
            ));
          }

          if (event is FetchNextPageByCategorySlug) {
            List<StoryListItem> storyListItemList = state.storyListItemList!;
            emit(TabStoryListState.loadingMore(
                storyListItemList: storyListItemList));
            List<StoryListItem> newStoryListItemList =
                await tabStoryListRepos.fetchStoryListByCategorySlug(
              event.slug,
              skip: storyListItemList.length,
              first: storyListItemList.length + event.loadingMorePage,
            );
            for (var item in storyListItemList) {
              newStoryListItemList
                  .removeWhere((element) => element.id == item.id);
            }
            storyListItemList.addAll(newStoryListItemList);
            emit(TabStoryListState.loaded(
              storyListItemList: storyListItemList,
              allStoryCount: tabStoryListRepos.allStoryCount,
            ));
          }

          if (event is FetchPopularStoryList) {
            emit(TabStoryListState.loading());
            List<StoryListItem> storyListItemList =
                await tabStoryListRepos.fetchPopularStoryList();
            emit(TabStoryListState.loaded(
              storyListItemList: storyListItemList,
              allStoryCount: tabStoryListRepos.allStoryCount,
            ));
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
            emit(TabStoryListState.loadingMoreError(
              storyListItemList: state.storyListItemList!,
              errorMessages: e.toString(),
            ));
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
            emit(TabStoryListState.loadingMoreError(
              storyListItemList: state.storyListItemList!,
              errorMessages: e.toString(),
            ));
          } else {
            emit(TabStoryListState.error(
              errorMessages: determineException(e),
            ));
          }
        }
      },
    );
  }
}
