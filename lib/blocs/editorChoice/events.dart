import 'package:tv/models/storyListItemList.dart';

abstract class EditorChoiceEvents {}

class TabStoryListIsLoaded extends EditorChoiceEvents {
  final StoryListItemList storyListItemList;
  TabStoryListIsLoaded(this.storyListItemList);
}

class FetchEditorChoiceList extends EditorChoiceEvents {}

class FetchVideoEditorChoiceList extends EditorChoiceEvents {}
