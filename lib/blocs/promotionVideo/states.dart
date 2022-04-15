import 'package:tv/models/youtubePlaylistItem.dart';

abstract class PromotionVideoState {}

class PromotionVideoInitState extends PromotionVideoState {}

class PromotionVideoLoading extends PromotionVideoState {}

class PromotionVideoLoaded extends PromotionVideoState {
  final List<YoutubePlaylistItem> youtubePlaylistItemList;
  PromotionVideoLoaded({required this.youtubePlaylistItemList});
}

class PromotionVideoError extends PromotionVideoState {
  final error;
  PromotionVideoError({this.error});
}
