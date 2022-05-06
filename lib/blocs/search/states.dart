import 'package:tv/models/storyListItem.dart';

abstract class SearchState {}

class SearchInitState extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoadingMore extends SearchState {
  final List<StoryListItem> storyListItemList;
  SearchLoadingMore({required this.storyListItemList});
}

class SearchLoaded extends SearchState {
  final List<StoryListItem> storyListItemList;
  final int allStoryCount;
  SearchLoaded({required this.storyListItemList, required this.allStoryCount});
}

class SearchError extends SearchState {
  final error;
  SearchError({this.error});
}
