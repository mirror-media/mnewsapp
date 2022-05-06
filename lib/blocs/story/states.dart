import 'package:tv/models/story.dart';

abstract class StoryState {
  final double? textSize;
  StoryState({this.textSize});
}

class StoryInitState extends StoryState {}

class StoryLoading extends StoryState {}

class StoryLoaded extends StoryState {
  final Story? story;
  StoryLoaded({required this.story});
}

class TextSizeChanged extends StoryState {
  final double textSize;
  TextSizeChanged({required this.textSize});
}

class StoryError extends StoryState {
  final error;
  StoryError({this.error});
}
