import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/topic.dart';
import 'package:tv/services/topicService.dart';

part 'events.dart';
part 'states.dart';

class TopicListBloc extends Bloc<TopicListEvents, TopicListState> {
  final TopicService topicService = TopicService();
  List<Topic> topicList = [];

  TopicListBloc() : super(const TopicListState.initial());

  Stream<TopicListState> mapEventToState(TopicListEvents event) async* {
    print(event.toString());
    try {
      if (event is FetchTopicList) {
        yield const TopicListState.loading();
        topicList = await topicService.fetchTopicList();

        yield TopicListState.loaded(
          topicList: topicList,
        );
      }
    } catch (e) {
      if (e is SocketException) {
        yield TopicListState.error(
          error: NoInternetException('No Internet'),
        );
      } else if (e is HttpException) {
        yield TopicListState.error(
          error: NoServiceFoundException('No Service Found'),
        );
      } else if (e is FormatException) {
        yield TopicListState.error(
          error: InvalidFormatException('Invalid Response format'),
        );
      } else if (e is FetchDataException) {
        yield TopicListState.error(
          error: NoInternetException('Error During Communication'),
        );
      } else if (e is BadRequestException ||
          e is UnauthorisedException ||
          e is InvalidInputException) {
        yield TopicListState.error(
          error: Error400Exception('Unauthorised'),
        );
      } else if (e is InternalServerErrorException) {
        yield TopicListState.error(
          error: Error500Exception('Internal Server Error'),
        );
      } else {
        yield TopicListState.error(
          error: UnknownException(e.toString()),
        );
      }
    }
  }
}
