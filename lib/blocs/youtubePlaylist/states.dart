import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class YoutubePlaylistState {}

class YoutubePlaylistInitState extends YoutubePlaylistState {}

class YoutubePlaylistLoading extends YoutubePlaylistState {}

class YoutubePlaylistLoadingMore extends YoutubePlaylistState {
  final YoutubePlaylistItemList youtubePlaylistItemList;
  YoutubePlaylistLoadingMore({required this.youtubePlaylistItemList});
}

class YoutubePlaylistLoaded extends YoutubePlaylistState {
  final YoutubePlaylistItemList youtubePlaylistItemList;
  YoutubePlaylistLoaded({required this.youtubePlaylistItemList});
}

class YoutubePlaylistError extends YoutubePlaylistState {
  final error;
  YoutubePlaylistError({this.error});
}
