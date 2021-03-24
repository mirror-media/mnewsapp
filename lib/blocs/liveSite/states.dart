import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class LiveSiteState {}

class LiveSiteInitState extends LiveSiteState {}

class LiveSiteLoading extends LiveSiteState {}

class LiveSiteLoaded extends LiveSiteState {
  final YoutubePlaylistItemList youtubePlaylistItemList;
  LiveSiteLoaded({this.youtubePlaylistItemList});
}

class LiveSiteError extends LiveSiteState {
  final error;
  LiveSiteError({this.error});
}
