import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/models/storyListItemList.dart';

abstract class TabStoryListState {}

class TabStoryListInitState extends TabStoryListState {}

class TabStoryListLoading extends TabStoryListState {}

class TabStoryListLoadingMore extends TabStoryListState {
  final StoryListItemList storyListItemList;
  TabStoryListLoadingMore({required this.storyListItemList});
}

class TabStoryListLoadingMoreFail extends TabStoryListState {
  final StoryListItemList storyListItemList;
  TabStoryListLoadingMoreFail({required this.storyListItemList});
}

class TabStoryListLoaded extends TabStoryListState {
  final StoryListItemList storyListItemList;
  final List<BannerAd> bannerAdList;
  TabStoryListLoaded({required this.storyListItemList, required this.bannerAdList,});
}

class TabStoryListError extends TabStoryListState {
  final error;
  TabStoryListError({this.error});
}
