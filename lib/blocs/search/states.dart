import 'package:tv/models/storyListItemList.dart';

abstract class SearchState {}

class SearchInitState extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoadingMore extends SearchState {
  final StoryListItemList storyListItemList;
  SearchLoadingMore({required this.storyListItemList});
}

class SearchLoaded extends SearchState {
  final StoryListItemList storyListItemList;
  SearchLoaded({required this.storyListItemList});
}

class SearchError extends SearchState {
  final error;
  SearchError({this.error});
}
