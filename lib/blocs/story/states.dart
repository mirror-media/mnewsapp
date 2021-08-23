import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tv/models/story.dart';

abstract class StoryState {}

class StoryInitState extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final Story? story;
  final List<BannerAd> bannerAdList;
  StoryLoaded({required this.story, required this.bannerAdList});
}

class StoryError extends StoryState {
  final error;
  StoryError({this.error});
}
