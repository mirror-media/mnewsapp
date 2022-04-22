import 'package:tv/models/storyListItem.dart';

abstract class EditorChoiceState {}

class EditorChoiceInitState extends EditorChoiceState {}

class EditorChoiceLoading extends EditorChoiceState {}

class EditorChoiceLoaded extends EditorChoiceState {
  final List<StoryListItem> editorChoiceList;
  EditorChoiceLoaded({required this.editorChoiceList});
}

class EditorChoiceLoadedAfterTabstory extends EditorChoiceState {
  final List<StoryListItem> editorChoiceList;
  final List<StoryListItem> storyListItemList;
  EditorChoiceLoadedAfterTabstory({
    required this.editorChoiceList,
    required this.storyListItemList,
  });
}

class EditorChoiceError extends EditorChoiceState {
  final error;
  EditorChoiceError({this.error});
}
