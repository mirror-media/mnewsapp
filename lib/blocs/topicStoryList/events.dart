part of 'bloc.dart';

abstract class TopicStoryListEvents {}

class FetchTopicStoryList extends TopicStoryListEvents {
  final String slug;
  FetchTopicStoryList(this.slug);
  @override
  String toString() => 'FetchTopicStoryList';
}

class FetchTopicStoryListMore extends TopicStoryListEvents {
  final int loadingMoreAmount;
  FetchTopicStoryListMore({this.loadingMoreAmount = 8});

  @override
  String toString() => 'FetchTopicStoryListMore amount:$loadingMoreAmount';
}
