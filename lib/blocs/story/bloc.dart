import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv/blocs/story/events.dart';
import 'package:tv/blocs/story/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/story.dart';
import 'package:tv/services/storyService.dart';

class StoryBloc extends Bloc<StoryEvents, StoryState> {
  final StoryRepos storyRepos;

  StoryBloc({required this.storyRepos}) : super(StoryInitState());

  @override
  Stream<StoryState> mapEventToState(StoryEvents event) async* {
    if (event is FetchPublishedStoryBySlug) {
      print(this.toString());
      try {
        yield StoryLoading();
        Story story = await storyRepos.fetchPublishedStoryBySlug(event.slug);
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId = AdUnitId.fromJson(fixedAdUnitId, 'story');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        double textSize = prefs.getDouble('textSize') ?? 20;
        yield StoryLoaded(story: story, adUnitId: adUnitId, textSize: textSize);
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
      } on FetchDataException {
        yield StoryError(
          error: NoInternetException('Error During Communication'),
        );
      } on BadRequestException {
        yield StoryError(
          error: Error400Exception('Invalid Request'),
        );
      } on UnauthorisedException {
        yield StoryError(
          error: Error400Exception('Unauthorised'),
        );
      } on InvalidInputException {
        yield StoryError(
          error: Error400Exception('Invalid Input'),
        );
      } on InternalServerErrorException {
        yield StoryError(
          error: Error500Exception('Internal Server Error'),
        );
      } catch (e) {
        yield StoryError(
          error: UnknownException(e.toString()),
        );
      }
    } else if (event is ChangeTextSize) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double textSize = prefs.getDouble('textSize') ?? 20;
      yield TextSizeChanged(textSize: textSize);
    }
  }
}
