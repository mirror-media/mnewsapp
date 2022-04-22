import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/search/events.dart';
import 'package:tv/blocs/search/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/searchService.dart';

class SearchBloc extends Bloc<SearchEvents, SearchState> {
  final SearchRepos searchRepos;
  List<StoryListItem> storyListItemList = [];

  SearchBloc({required this.searchRepos}) : super(SearchInitState());

  @override
  Stream<SearchState> mapEventToState(SearchEvents event) async* {
    print(event.toString());
    try {
      yield SearchLoading();
      if (event is SearchNewsStoryByKeyword) {
        storyListItemList =
            await searchRepos.searchNewsStoryByKeyword(event.keyword);
        yield SearchLoaded(
          storyListItemList: storyListItemList,
          allStoryCount: searchRepos.allStoryCount,
        );
      } else if (event is SearchNextPageByKeyword) {
        yield SearchLoadingMore(storyListItemList: storyListItemList);
        List<StoryListItem> newStoryListItemList =
            await searchRepos.searchNextPageByKeyword(event.keyword);
        storyListItemList.addAll(newStoryListItemList);
        yield SearchLoaded(
          storyListItemList: storyListItemList,
          allStoryCount: searchRepos.allStoryCount,
        );
      } else if (event is ClearKeyword) {
        yield SearchInitState();
      }
    } on SocketException {
      yield SearchError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield SearchError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield SearchError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield SearchError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield SearchError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield SearchError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield SearchError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield SearchError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield SearchError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
