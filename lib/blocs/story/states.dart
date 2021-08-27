import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/story.dart';

abstract class StoryState {}

class StoryInitState extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final Story? story;
  final AdUnitId adUnitId;
  StoryLoaded({required this.story, required this.adUnitId});
}

class StoryError extends StoryState {
  final error;
  StoryError({this.error});
}
