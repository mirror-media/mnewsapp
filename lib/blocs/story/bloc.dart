import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/story.dart';
import 'package:tv/services/storyService.dart';

class StoryBloc extends Bloc<StoryEvents, StoryState> {
  final StoryRepos storyRepos;

  StoryBloc({required this.storyRepos}) : super(StoryInitState()) {
    on<StoryEvents>(
      (event, emit) async {
        print(this.toString());
        try {
          if (event is FetchPublishedStoryBySlug) {
            emit(StoryLoading());
            Story story =
                await storyRepos.fetchPublishedStoryBySlug(event.slug);
            emit(StoryLoaded(story: story));
          }
        } catch (e) {
          emit(StoryError(
            error: determineException(e),
          ));
        }
      },
    );
  }
}
