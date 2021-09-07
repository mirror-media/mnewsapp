import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/story.dart';

abstract class StoryState {}

class StoryInitState extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final Story? story;
  final AdUnitId adUnitId;
  final double textSize;
  StoryLoaded({required this.story, required this.adUnitId, required this.textSize});
}

class StoryError extends StoryState {
  final error;
  StoryError({this.error});
}
