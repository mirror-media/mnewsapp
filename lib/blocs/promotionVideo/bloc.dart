import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/promotionVideo/events.dart';
import 'package:tv/blocs/promotionVideo/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/youtubePlaylistItem.dart';
import 'package:tv/services/promotionVideosService.dart';

class PromotionVideoBloc
    extends Bloc<PromotionVideoEvents, PromotionVideoState> {
  final PromotionVideosRepos promotionVideosRepos;

  PromotionVideoBloc({required this.promotionVideosRepos})
      : super(PromotionVideoInitState());

  @override
  Stream<PromotionVideoState> mapEventToState(
      PromotionVideoEvents event) async* {
    print(event.toString());
    try {
      if (event is FetchAllPromotionVideos) {
        yield PromotionVideoLoading();
        List<YoutubePlaylistItem> youtubePlaylistItemList =
            await promotionVideosRepos.fetchAllPromotionVideos();
        yield PromotionVideoLoaded(
            youtubePlaylistItemList: youtubePlaylistItemList);
      }
    } on SocketException {
      yield PromotionVideoError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield PromotionVideoError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield PromotionVideoError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield PromotionVideoError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield PromotionVideoError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield PromotionVideoError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield PromotionVideoError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield PromotionVideoError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield PromotionVideoError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
