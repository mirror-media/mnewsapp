import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/storyListItemList.dart';

enum TabStoryListStatus { 
  initial, 
  loading, 
  loaded, 
  error, 
  loadingMore, 
  loadingMoreError 
}

class TabStoryListState {
  final TabStoryListStatus status;
  final StoryListItemList? storyListItemList;
  final AdUnitId? adUnitId;
  final dynamic errorMessages;

  const TabStoryListState._({
    required this.status,
    this.storyListItemList,
    this.adUnitId,
    this.errorMessages,
  });

  const TabStoryListState.init()
      : this._(status: TabStoryListStatus.initial);

  const TabStoryListState.loading()
      : this._(status: TabStoryListStatus.loading);

  const TabStoryListState.loaded({
    required StoryListItemList storyListItemList,
    AdUnitId? adUnitId,
  })  : this._(
        status: TabStoryListStatus.loaded,
        adUnitId: adUnitId,
        storyListItemList: storyListItemList,
      );

  const TabStoryListState.error({
    dynamic errorMessages
  })  : this._(
        status: TabStoryListStatus.error,
        errorMessages: errorMessages,
      );

  const TabStoryListState.loadingMore({
    required StoryListItemList storyListItemList,
  })  : this._(
        status: TabStoryListStatus.loadingMore,
        storyListItemList: storyListItemList,
      );

  const TabStoryListState.loadingMoreError({
    required StoryListItemList storyListItemList,
    dynamic errorMessages
  })  : this._(
        status: TabStoryListStatus.loadingMoreError,
        storyListItemList: storyListItemList,
        errorMessages: errorMessages,
      );

  @override
  String toString() {
    return 'TabStoryListStatus { status: ${status.toString()} }';
  }
}