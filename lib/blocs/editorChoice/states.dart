import 'package:tv/models/storyListItemList.dart';

abstract class EditorChoiceState {}

class EditorChoiceInitState extends EditorChoiceState {}

class EditorChoiceLoading extends EditorChoiceState {}

class EditorChoiceLoaded extends EditorChoiceState {
  final StoryListItemList editorChoiceList;
  EditorChoiceLoaded({required this.editorChoiceList});
}

class EditorChoiceLoadedAfterTabstory extends EditorChoiceState {
  final StoryListItemList editorChoiceList;
  final StoryListItemList storyListItemList;
  EditorChoiceLoadedAfterTabstory({
    required this.editorChoiceList,
    required this.storyListItemList,
  });
}

class EditorChoiceError extends EditorChoiceState {
  final error;
  EditorChoiceError({this.error});
}
