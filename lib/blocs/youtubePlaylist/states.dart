import 'package:tv/models/youtubePlaylistItem.dart';

abstract class YoutubePlaylistState {}

class YoutubePlaylistInitState extends YoutubePlaylistState {}

class YoutubePlaylistLoading extends YoutubePlaylistState {}

class YoutubePlaylistLoadingMore extends YoutubePlaylistState {
  final List<YoutubePlaylistItem> youtubePlaylistItemList;
  YoutubePlaylistLoadingMore({required this.youtubePlaylistItemList});
}

class YoutubePlaylistLoadingMoreFail extends YoutubePlaylistState {
  final List<YoutubePlaylistItem> youtubePlaylistItemList;
  YoutubePlaylistLoadingMoreFail({required this.youtubePlaylistItemList});
}

class YoutubePlaylistLoaded extends YoutubePlaylistState {
  final List<YoutubePlaylistItem> youtubePlaylistItemList;
  YoutubePlaylistLoaded({required this.youtubePlaylistItemList});
}

class YoutubePlaylistError extends YoutubePlaylistState {
  final error;
  YoutubePlaylistError({this.error});
}
