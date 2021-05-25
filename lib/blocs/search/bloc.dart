import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/search/events.dart';
import 'package:tv/blocs/search/states.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/searchService.dart';

class SearchBloc extends Bloc<SearchEvents, SearchState> {
  final SearchRepos searchRepos;
  StoryListItemList storyListItemList = StoryListItemList();

  SearchBloc({this.searchRepos}) : super(SearchInitState());

  @override
  Stream<SearchState> mapEventToState(SearchEvents event) async* {
    event.storyListItemList = storyListItemList;
    yield* event.run(searchRepos);
    storyListItemList = event.storyListItemList;
  }
}
