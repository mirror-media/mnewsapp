import 'package:tv/models/storyListItemList.dart';

abstract class TabStoryListState {}

class TabStoryListInitState extends TabStoryListState {}

class TabStoryListLoading extends TabStoryListState {}

class TabStoryListLoadingMore extends TabStoryListState {
  final StoryListItemList storyListItemList;
  TabStoryListLoadingMore({this.storyListItemList});
}

class TabStoryListLoaded extends TabStoryListState {
  final StoryListItemList storyListItemList;
  TabStoryListLoaded({this.storyListItemList});
}

class TabStoryListError extends TabStoryListState {
  final error;
  TabStoryListError({this.error});
}
