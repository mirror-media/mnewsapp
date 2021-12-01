part of 'bloc.dart';

enum TopicListStatus {
  initial,
  loading,
  loaded,
  error,
}

class TopicListState {
  final TopicListStatus status;
  final TopicList? topicList;
  final dynamic error;
  const TopicListState._({
    required this.status,
    this.topicList,
    this.error,
  });

  const TopicListState.initial() : this._(status: TopicListStatus.initial);

  const TopicListState.loading() : this._(status: TopicListStatus.loading);

  const TopicListState.loaded({
    required TopicList topicList,
  }) : this._(
          status: TopicListStatus.loaded,
          topicList: topicList,
        );

  const TopicListState.error({required dynamic error})
      : this._(status: TopicListStatus.error, error: error);
}
