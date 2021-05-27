import 'package:tv/models/youtubePlaylistItemList.dart';

abstract class PromotionVideoState {}

class PromotionVideoInitState extends PromotionVideoState {}

class PromotionVideoLoading extends PromotionVideoState {}

class PromotionVideoLoaded extends PromotionVideoState {
  final YoutubePlaylistItemList youtubePlaylistItemList;
  PromotionVideoLoaded({this.youtubePlaylistItemList});
}

class PromotionVideoError extends PromotionVideoState {
  final error;
  PromotionVideoError({this.error});
}
