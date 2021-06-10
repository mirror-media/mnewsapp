import 'dart:io';

import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/tabStoryListService.dart';

abstract class TabStoryListEvents{
  StoryListItemList storyListItemList = StoryListItemList();
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos);
}

class FetchStoryList extends TabStoryListEvents {
  @override
  String toString() => 'FetchStoryList';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    try {
      yield TabStoryListLoading();
      storyListItemList = await tabStoryListRepos.fetchStoryList();
      yield TabStoryListLoaded(storyListItemList: storyListItemList);
    } on SocketException {
      yield TabStoryListError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield TabStoryListError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield TabStoryListError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield TabStoryListError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield TabStoryListError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield TabStoryListError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield TabStoryListError(
        error: UnknownException(e.toString()),
      );
    }
  }
}

class FetchNextPage extends TabStoryListEvents {
  final int loadingMorePage;

  FetchNextPage({this.loadingMorePage = 20});

  @override
  String toString() => 'FetchNextPage { loadingMorePage: $loadingMorePage }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
    StoryListItemList newStoryListItemList = await tabStoryListRepos.fetchNextPage(
      loadingMorePage: loadingMorePage
    );
    storyListItemList.addAll(newStoryListItemList);
    yield TabStoryListLoaded(storyListItemList: storyListItemList);
  }
}

class FetchStoryListByCategorySlug extends TabStoryListEvents {
  final String slug;

  FetchStoryListByCategorySlug(this.slug);

  @override
  String toString() => 'FetchStoryListByCategorySlug { slug: $slug }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    try {
      yield TabStoryListLoading();
      storyListItemList = await tabStoryListRepos.fetchStoryListByCategorySlug(slug);
      yield TabStoryListLoaded(storyListItemList: storyListItemList);
    } on SocketException {
      yield TabStoryListError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield TabStoryListError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield TabStoryListError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield TabStoryListError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield TabStoryListError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield TabStoryListError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield TabStoryListError(
        error: UnknownException(e.toString()),
      );
    }
  }
}

class FetchNextPageByCategorySlug extends TabStoryListEvents {
  final String slug;
  final int loadingMorePage;

  FetchNextPageByCategorySlug(this.slug, {this.loadingMorePage = 20});

  @override
  String toString() => 'FetchNextPageByCategorySlug { slug: $slug, loadingMorePage: $loadingMorePage }';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
    StoryListItemList newStoryListItemList = await tabStoryListRepos.fetchNextPageByCategorySlug(
      slug, 
      loadingMorePage: loadingMorePage
    );
    storyListItemList.addAll(newStoryListItemList);
    yield TabStoryListLoaded(storyListItemList: storyListItemList);
  }
}

class FetchPopularStoryList extends TabStoryListEvents {
  FetchPopularStoryList();

  @override
  String toString() => 'FetchPopularStoryList';

  @override
  Stream<TabStoryListState> run(TabStoryListRepos tabStoryListRepos) async*{
    print(this.toString());
    try {
      yield TabStoryListLoading();
      storyListItemList = await tabStoryListRepos.fetchPopularStoryList();
      yield TabStoryListLoaded(storyListItemList: storyListItemList);
    } on SocketException {
      yield TabStoryListError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield TabStoryListError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield TabStoryListError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield TabStoryListError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield TabStoryListError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield TabStoryListError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield TabStoryListError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield TabStoryListError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
