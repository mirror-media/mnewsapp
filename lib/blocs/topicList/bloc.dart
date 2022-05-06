import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/helpers/errorHelper.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/services/topicService.dart';

part 'events.dart';
part 'states.dart';

class TopicListBloc extends Bloc<TopicListEvents, TopicListState> {
  final TopicService topicService = TopicService();
  List<Topic> topicList = [];

  TopicListBloc() : super(const TopicListState.initial()) {
    on<TopicListEvents>((event, emit) async {
      print(event.toString());
      try {
        if (event is FetchTopicList) {
          emit(const TopicListState.loading());
          topicList = await topicService.fetchTopicList();

          emit(TopicListState.loaded(
            topicList: topicList,
          ));
        }
      } catch (e) {
        emit(TopicListState.error(
          error: determineException(e),
        ));
      }
    });
  }
}
