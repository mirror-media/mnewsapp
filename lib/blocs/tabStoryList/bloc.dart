import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/tabStoryListService.dart';

class TabStoryListBloc extends Bloc<TabStoryListEvents, TabStoryListState> {
  final TabStoryListRepos tabStoryListRepos;
  StoryListItemList storyListItemList;

  TabStoryListBloc({this.tabStoryListRepos}) : super(TabStoryListInitState());

  @override
  Stream<TabStoryListState> mapEventToState(TabStoryListEvents event) async* {
    try {
      if(event is FetchStoryList) {
        yield TabStoryListLoading();
        storyListItemList = await tabStoryListRepos.fetchStoryList();
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if(event is FetchNextPage) {
        yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList = await tabStoryListRepos.fetchNextPage(
          loadingMorePage: event.loadingMorePage
        );
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if(event is FetchStoryListByCategorySlug) {
        yield TabStoryListLoading();
        storyListItemList = await tabStoryListRepos.fetchStoryListByCategorySlug(event.slug);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      } else if(event is FetchNextPageByCategorySlug) {
        yield TabStoryListLoadingMore(storyListItemList: storyListItemList);
        StoryListItemList newStoryListItemList = await tabStoryListRepos.fetchNextPageByCategorySlug(
          event.slug, 
          loadingMorePage: event.loadingMorePage
        );
        await Future.delayed(Duration(seconds: 3));
        storyListItemList.addAll(newStoryListItemList);
        yield TabStoryListLoaded(storyListItemList: storyListItemList);
      }
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
    } catch (e) {
      yield TabStoryListError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
