import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/tabStoryList/events.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/tabStoryListService.dart';

class TabStoryListBloc extends Bloc<TabStoryListEvents, TabStoryListState> {
  final TabStoryListRepos tabStoryListRepos;
  StoryListItemList storyListItemList = StoryListItemList();

  TabStoryListBloc({required this.tabStoryListRepos})
      : super(TabStoryListInitState());

  // TODO: https://github.com/dart-lang/sdk/issues/42466
  @override
  Stream<TabStoryListState> mapEventToState(TabStoryListEvents event) async* {
    event.storyListItemList = storyListItemList;
    yield* event.run(tabStoryListRepos);
    storyListItemList = event.storyListItemList;
  }
}
