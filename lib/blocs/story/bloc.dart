import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/services/storyService.dart';

class StoryBloc extends Bloc<StoryEvents, StoryState> {
  final StoryRepos storyRepos;

  StoryBloc({required this.storyRepos}) : super(StoryInitState());

  @override
  Stream<StoryState> mapEventToState(StoryEvents event) async* {
    yield* event.run(storyRepos);
  }
}
