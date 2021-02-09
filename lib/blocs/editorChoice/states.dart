

import 'package:tv/models/storyListItemList.dart';

abstract class EditorChoiceState {}

class EditorChoiceInitState extends EditorChoiceState {}

class EditorChoiceLoading extends EditorChoiceState {}

class EditorChoiceLoaded extends EditorChoiceState {
  final StoryListItemList editorChoiceList;
  EditorChoiceLoaded({this.editorChoiceList});
}

class EditorChoiceError extends EditorChoiceState {
  final error;
  EditorChoiceError({this.error});
}
