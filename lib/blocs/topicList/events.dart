part of 'bloc.dart';

abstract class TopicListEvents {}

class FetchTopicList extends TopicListEvents {
  @override
  String toString() => 'FetchTopicList';
}
