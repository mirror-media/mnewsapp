import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/blocs/editorChoice/states.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/editorChoiceService.dart';

class EditorChoiceBloc extends Bloc<EditorChoiceEvents, EditorChoiceState> {
  final EditorChoiceRepos editorChoiceRepos;
  final TabStoryListBloc? tabStoryListBloc;
  late StreamSubscription tabStoryListBlocSubscription;
  StoryListItemList editorChoiceList = StoryListItemList();

  EditorChoiceBloc({required this.editorChoiceRepos, this.tabStoryListBloc})
      : super(EditorChoiceLoading()) {
    if (tabStoryListBloc != null) {
      tabStoryListBlocSubscription = tabStoryListBloc!.stream.listen((state) {
        if (state.status == TabStoryListStatus.loaded) {
          add(TabStoryListIsLoaded(state.storyListItemList!));
        }
      });
    }
  }

  @override
  Stream<EditorChoiceState> mapEventToState(EditorChoiceEvents event) async* {
    yield EditorChoiceLoading();
    try {
      if (event is FetchVideoEditorChoiceList) {
        editorChoiceList = await editorChoiceRepos.fetchVideoEditorChoiceList();
        yield EditorChoiceLoaded(editorChoiceList: editorChoiceList);
      } else if (event is TabStoryListIsLoaded) {
        editorChoiceList = await editorChoiceRepos.fetchEditorChoiceList();
        yield EditorChoiceLoadedAfterTabstory(
          editorChoiceList: editorChoiceList,
          storyListItemList: event.storyListItemList,
        );
      }
    } on SocketException {
      yield EditorChoiceError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield EditorChoiceError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield EditorChoiceError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } catch (e) {
      yield EditorChoiceError(
        error: UnknownException(e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    if (tabStoryListBloc != null) tabStoryListBlocSubscription.cancel();
    return super.close();
  }
}
