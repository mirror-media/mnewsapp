import 'package:tv/models/story.dart';

abstract class StoryState {}

class StoryInitState extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final Story? story;
  StoryLoaded({required this.story});
}

class StoryError extends StoryState {
  final error;
  StoryError({this.error});
}
