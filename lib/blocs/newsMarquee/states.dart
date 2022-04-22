import 'package:tv/models/storyListItem.dart';

abstract class NewsMarqueeState {}

class NewsMarqueeInitState extends NewsMarqueeState {}

class NewsMarqueeLoading extends NewsMarqueeState {}

class NewsMarqueeLoaded extends NewsMarqueeState {
  final List<StoryListItem> newsList;
  NewsMarqueeLoaded({required this.newsList});
}

class NewsMarqueeError extends NewsMarqueeState {
  final error;
  NewsMarqueeError({this.error});
}
