import 'package:tv/models/storyListItemList.dart';

abstract class SearchState {}

class SearchInitState extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final StoryListItemList storyListItemList;
  SearchLoaded({this.storyListItemList});
}

class SearchError extends SearchState {
  final error;
  SearchError({this.error});
}
