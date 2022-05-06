part of 'bloc.dart';

enum TagStoryListStatus {
  initial,
  loading,
  loadingMore,
  loadingMoreFail,
  loaded,
  error,
}

class TagStoryListState {
  final TagStoryListStatus status;
  final List<StoryListItem>? tagStoryList;
  final dynamic error;
  final int? allStoryCount;
  const TagStoryListState._({
    required this.status,
    this.tagStoryList,
    this.error,
    this.allStoryCount,
  });

  const TagStoryListState.initial()
      : this._(status: TagStoryListStatus.initial);

  const TagStoryListState.loading()
      : this._(status: TagStoryListStatus.loading);

  const TagStoryListState.loaded({
    required List<StoryListItem> tagStoryList,
    required int allStoryCount,
  }) : this._(
          status: TagStoryListStatus.loaded,
          tagStoryList: tagStoryList,
          allStoryCount: allStoryCount,
        );

  const TagStoryListState.loadingMore({
    required List<StoryListItem> tagStoryList,
  }) : this._(
          status: TagStoryListStatus.loadingMore,
          tagStoryList: tagStoryList,
        );

  const TagStoryListState.loadingMoreFail({
    required List<StoryListItem> tagStoryList,
  }) : this._(
          status: TagStoryListStatus.loadingMoreFail,
          tagStoryList: tagStoryList,
        );

  const TagStoryListState.error({required dynamic error})
      : this._(status: TagStoryListStatus.error, error: error);
}
