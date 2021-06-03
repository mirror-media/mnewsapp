import 'package:tv/models/storyListItemList.dart';

abstract class NewsMarqueeState {}

class NewsMarqueeInitState extends NewsMarqueeState {}

class NewsMarqueeLoading extends NewsMarqueeState {}

class NewsMarqueeLoaded extends NewsMarqueeState {
  final StoryListItemList newsList;
  NewsMarqueeLoaded({required this.newsList});
}

class NewsMarqueeError extends NewsMarqueeState {
  final error;
  NewsMarqueeError({this.error});
}
