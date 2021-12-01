part of 'bloc.dart';

enum TopicStoryListStatus {
  initial,
  loading,
  loadingMoreFail,
  loaded,
  error,
}

class TopicStoryListState {
  final TopicStoryListStatus status;
  final TopicStoryList? topicStoryList;
  final dynamic error;
  const TopicStoryListState._({
    required this.status,
    this.topicStoryList,
    this.error,
  });

  const TopicStoryListState.initial()
      : this._(status: TopicStoryListStatus.initial);

  const TopicStoryListState.loading()
      : this._(status: TopicStoryListStatus.loading);

  const TopicStoryListState.loaded({
    required TopicStoryList topicStoryList,
  }) : this._(
          status: TopicStoryListStatus.loaded,
          topicStoryList: topicStoryList,
        );

  const TopicStoryListState.loadingMoreFail()
      : this._(status: TopicStoryListStatus.loadingMoreFail);

  const TopicStoryListState.error({required dynamic error})
      : this._(status: TopicStoryListStatus.error, error: error);
}
