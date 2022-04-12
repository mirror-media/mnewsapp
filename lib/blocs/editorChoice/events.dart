import 'package:tv/models/storyListItem.dart';

abstract class EditorChoiceEvents {}

class TabStoryListIsLoaded extends EditorChoiceEvents {
  final List<StoryListItem> storyListItemList;
  TabStoryListIsLoaded(this.storyListItemList);
}

class FetchEditorChoiceList extends EditorChoiceEvents {}

class FetchVideoEditorChoiceList extends EditorChoiceEvents {}
