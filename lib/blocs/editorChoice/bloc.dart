import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/editorChoice/events.dart';
import 'package:tv/blocs/editorChoice/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItemList.dart';
import 'package:tv/services/editorChoiceService.dart';

class EditorChoiceBloc extends Bloc<EditorChoiceEvents, EditorChoiceState> {
  final EditorChoiceRepos editorChoiceRepos;
  StoryListItemList editorChoiceList = StoryListItemList();

  EditorChoiceBloc({required this.editorChoiceRepos}) : super(EditorChoiceInitState());

  @override
  Stream<EditorChoiceState> mapEventToState(EditorChoiceEvents event) async* {
    yield EditorChoiceLoading();
    try {
      switch (event) {
        case EditorChoiceEvents.fetchEditorChoiceList:
          editorChoiceList = await editorChoiceRepos.fetchEditorChoiceList();
          break;
        case EditorChoiceEvents.fetchVideoEditorChoiceList: 
          editorChoiceList = await editorChoiceRepos.fetchVideoEditorChoiceList();
          break;
      }
      yield EditorChoiceLoaded(editorChoiceList: editorChoiceList);
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
}
