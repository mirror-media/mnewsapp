import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/newsMarquee/events.dart';
import 'package:tv/blocs/newsMarquee/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/newsMarqueeService.dart';

class NewsMarqueeBloc extends Bloc<NewsMarqueeEvents, NewsMarqueeState> {
  final NewsMarqueeRepos newsMarqueeRepos;
  List<StoryListItem> newsList = [];

  NewsMarqueeBloc({required this.newsMarqueeRepos})
      : super(NewsMarqueeInitState());

  @override
  Stream<NewsMarqueeState> mapEventToState(NewsMarqueeEvents event) async* {
    switch (event) {
      case NewsMarqueeEvents.fetchNewsList:
        yield NewsMarqueeLoading();
        try {
          newsList = await newsMarqueeRepos.fetchNewsList();
          yield NewsMarqueeLoaded(newsList: newsList);
        } on SocketException {
          yield NewsMarqueeError(
            error: NoInternetException('No Internet'),
          );
        } on HttpException {
          yield NewsMarqueeError(
            error: NoServiceFoundException('No Service Found'),
          );
        } on FormatException {
          yield NewsMarqueeError(
            error: InvalidFormatException('Invalid Response format'),
          );
        } catch (e) {
          yield NewsMarqueeError(
            error: UnknownException(e.toString()),
          );
        }

        break;
    }
  }
}
