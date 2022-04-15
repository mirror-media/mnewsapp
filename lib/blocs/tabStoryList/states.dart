import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/storyListItem.dart';

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
  final List<StoryListItem>? storyListItemList;
  final AdUnitId? adUnitId;
  final dynamic errorMessages;
  final int? allStoryCount;

  const TabStoryListState._({
    required this.status,
    this.storyListItemList,
    this.adUnitId,
    this.errorMessages,
    this.allStoryCount,
  });

  const TabStoryListState.init() : this._(status: TabStoryListStatus.initial);

  const TabStoryListState.loading()
      : this._(status: TabStoryListStatus.loading);

  const TabStoryListState.loaded({
    required List<StoryListItem> storyListItemList,
    required int allStoryCount,
    AdUnitId? adUnitId,
  }) : this._(
          status: TabStoryListStatus.loaded,
          adUnitId: adUnitId,
          storyListItemList: storyListItemList,
          allStoryCount: allStoryCount,
        );

  const TabStoryListState.error({dynamic errorMessages})
      : this._(
          status: TabStoryListStatus.error,
          errorMessages: errorMessages,
        );

  const TabStoryListState.loadingMore({
    required List<StoryListItem> storyListItemList,
  }) : this._(
          status: TabStoryListStatus.loadingMore,
          storyListItemList: storyListItemList,
        );

  const TabStoryListState.loadingMoreError(
      {required List<StoryListItem> storyListItemList, dynamic errorMessages})
      : this._(
          status: TabStoryListStatus.loadingMoreError,
          storyListItemList: storyListItemList,
          errorMessages: errorMessages,
        );

  @override
  String toString() {
    return 'TabStoryListStatus { status: ${status.toString()} }';
  }
}
