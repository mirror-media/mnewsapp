import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class YoutubePlaylistState {}

class YoutubePlaylistInitState extends YoutubePlaylistState {}

class YoutubePlaylistLoading extends YoutubePlaylistState {}

class YoutubePlaylistLoadingMore extends YoutubePlaylistState {
  final YoutubePlaylistItemList youtubePlaylistItemList;
  YoutubePlaylistLoadingMore({required this.youtubePlaylistItemList});
}

class YoutubePlaylistLoadingMoreFail extends YoutubePlaylistState {
  final YoutubePlaylistItemList youtubePlaylistItemList;
  YoutubePlaylistLoadingMoreFail({required this.youtubePlaylistItemList});
}

class YoutubePlaylistLoaded extends YoutubePlaylistState {
  final YoutubePlaylistItemList youtubePlaylistItemList;
  final List<BannerAd> bannerAdList;
  YoutubePlaylistLoaded({required this.youtubePlaylistItemList, required this.bannerAdList});
}

class YoutubePlaylistError extends YoutubePlaylistState {
  final error;
  YoutubePlaylistError({this.error});
}
