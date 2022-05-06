import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/blocs/editorChoice/states.dart';
import 'package:tv/blocs/tabStoryList/bloc.dart';
import 'package:tv/blocs/tabStoryList/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/editorChoiceService.dart';

class EditorChoiceBloc extends Bloc<EditorChoiceEvents, EditorChoiceState> {
  final EditorChoiceRepos editorChoiceRepos;
  final TabStoryListBloc? tabStoryListBloc;
  late StreamSubscription tabStoryListBlocSubscription;
  List<StoryListItem> editorChoiceList = [];

  EditorChoiceBloc({required this.editorChoiceRepos, this.tabStoryListBloc})
      : super(EditorChoiceLoading()) {
    if (tabStoryListBloc != null) {
      tabStoryListBlocSubscription = tabStoryListBloc!.stream.listen((state) {
        if (state.status == TabStoryListStatus.loaded) {
          add(TabStoryListIsLoaded(state.storyListItemList!));
        }
      });
    }
    on<EditorChoiceEvents>(
      (event, emit) async {
        emit(EditorChoiceLoading());
        try {
          if (event is FetchVideoEditorChoiceList) {
            editorChoiceList =
                await editorChoiceRepos.fetchVideoEditorChoiceList();
            emit(EditorChoiceLoaded(editorChoiceList: editorChoiceList));
          } else if (event is TabStoryListIsLoaded) {
            editorChoiceList = await editorChoiceRepos.fetchEditorChoiceList();
            emit(EditorChoiceLoadedAfterTabstory(
              editorChoiceList: editorChoiceList,
              storyListItemList: event.storyListItemList,
            ));
          }
        } catch (e) {
          emit(EditorChoiceError(error: determineException(e)));
        }
      },
    );
  }

  @override
  Future<void> close() {
    if (tabStoryListBloc != null) tabStoryListBlocSubscription.cancel();
    return super.close();
  }
}
