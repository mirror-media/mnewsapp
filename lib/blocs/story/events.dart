import 'dart:io';

import 'package:tv/blocs/story/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/story.dart';
import 'package:tv/services/storyService.dart';

abstract class StoryEvents{
  Story story;
  Stream<StoryState> run(StoryRepos storyRepos);
}

class FetchPublishedStoryBySlug extends StoryEvents {
  final String slug;
  FetchPublishedStoryBySlug(this.slug);

  @override
  String toString() => 'FetchPublishedStoryBySlug { storySlug: $slug }';

  @override
  Stream<StoryState> run(StoryRepos storyRepos) async*{
    print(this.toString());
    try{
      yield StoryLoading();
      story = await storyRepos.fetchPublishedStoryBySlug(slug);
      yield StoryLoaded(story: story);
    } on SocketException {
      yield StoryError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield StoryError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield StoryError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } catch (e) {
      yield StoryError(
        error: UnknownException(e.toString()),
      );
    }
  }
}