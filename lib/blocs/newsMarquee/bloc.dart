import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/newsMarquee/events.dart';
import 'package:tv/blocs/newsMarquee/states.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/storyListItem.dart';
import 'package:tv/services/newsMarqueeService.dart';

class NewsMarqueeBloc extends Bloc<NewsMarqueeEvents, NewsMarqueeState> {
  final NewsMarqueeRepos newsMarqueeRepos;
  List<StoryListItem> newsList = [];

  NewsMarqueeBloc({required this.newsMarqueeRepos})
      : super(NewsMarqueeInitState()) {
    on<NewsMarqueeEvents>(
      (event, emit) async {
        emit(NewsMarqueeLoading());
        try {
          newsList = await newsMarqueeRepos.fetchNewsList();
          emit(NewsMarqueeLoaded(newsList: newsList));
        } catch (e) {
          emit(NewsMarqueeError(
            error: determineException(e),
          ));
        }
      },
    );
  }
}
