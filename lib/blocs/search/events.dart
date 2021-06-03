import 'dart:io';

import 'package:tv/blocs/search/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/searchService.dart';

abstract class SearchEvents{
  StoryListItemList storyListItemList = StoryListItemList();
  Stream<SearchState> run(SearchRepos searchRepos);
}

class SearchNewsStoryByKeyword extends SearchEvents {
  final String keyword;
  SearchNewsStoryByKeyword(this.keyword);

  @override
  String toString() => 'SearchNewsStoryByKeyword { keyword: $keyword }';

  @override
  Stream<SearchState> run(SearchRepos searchRepos) async*{
    print(this.toString());
    try{
      yield SearchLoading();
      storyListItemList = await searchRepos.searchNewsStoryByKeyword(keyword);
      yield SearchLoaded(storyListItemList: storyListItemList);
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

class SearchNextPageByKeyword extends SearchEvents {
  final String keyword;
  SearchNextPageByKeyword(this.keyword);

  @override
  String toString() => 'SearchNextPageByKeyword { keyword: $keyword }';

  @override
  Stream<SearchState> run(SearchRepos searchRepos) async*{
    print(this.toString());
    try{
      yield SearchLoadingMore(storyListItemList: storyListItemList);
      StoryListItemList newStoryListItemList = await searchRepos.searchNextPageByKeyword(keyword);
      storyListItemList.addAll(newStoryListItemList);
      yield SearchLoaded(storyListItemList: storyListItemList);
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

class ClearKeyword extends SearchEvents {
  @override
  String toString() => 'ClearKeyword';

  @override
  Stream<SearchState> run(SearchRepos searchRepos) async*{
    print(this.toString());
    yield SearchInitState();
  }
}