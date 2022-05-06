import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/search/events.dart';
import 'package:tv/blocs/search/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/searchService.dart';

class SearchBloc extends Bloc<SearchEvents, SearchState> {
  final SearchRepos searchRepos;
  List<StoryListItem> storyListItemList = [];

  SearchBloc({required this.searchRepos}) : super(SearchInitState()) {
    on<SearchEvents>((event, emit) async {
      print(event.toString());
      try {
        emit(SearchLoading());
        if (event is SearchNewsStoryByKeyword) {
          storyListItemList =
              await searchRepos.searchNewsStoryByKeyword(event.keyword);
          emit(SearchLoaded(
            storyListItemList: storyListItemList,
            allStoryCount: searchRepos.allStoryCount,
          ));
        } else if (event is SearchNextPageByKeyword) {
          emit(SearchLoadingMore(storyListItemList: storyListItemList));
          List<StoryListItem> newStoryListItemList =
              await searchRepos.searchNextPageByKeyword(event.keyword);
          storyListItemList.addAll(newStoryListItemList);
          emit(SearchLoaded(
            storyListItemList: storyListItemList,
            allStoryCount: searchRepos.allStoryCount,
          ));
        } else if (event is ClearKeyword) {
          emit(SearchInitState());
        }
      } catch (e) {
        emit(SearchError(
          error: determineException(e),
        ));
      }
    });
  }
}
