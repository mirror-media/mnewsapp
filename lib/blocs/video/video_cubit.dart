import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/video.dart';
import 'package:tv/services/videoService.dart';

part 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(VideoInitial());

  void fetchVideoByName(String name) async{
    print('GetVideoByName: { name: $name }');
    try{
      Video video = await VideoServices().fetchVideoByName(name);
      emit(VideoLoaded(video: video));
    } on SocketException {
      emit(VideoError(
        error: NoInternetException('No Internet'),
      ));
    } on HttpException {
      emit(VideoError(
        error: NoServiceFoundException('No Service Found'),
      ));
    } on FormatException {
      emit (VideoError(
        error: InvalidFormatException('Invalid Response format'),
      ));
    } on FetchDataException {
      emit (VideoError(
        error: NoInternetException('Error During Communication'),
      ));
    } on BadRequestException {
      emit (VideoError(
        error: Error400Exception('Invalid Request'),
      ));
    } on UnauthorisedException {
      emit (VideoError(
        error: Error400Exception('Unauthorised'),
      ));
    } on InvalidInputException {
      emit (VideoError(
        error: Error400Exception('Invalid Input'),
      ));
    } on InternalServerErrorException {
      emit (VideoError(
        error: Error500Exception('Internal Server Error'),
      ));
    } catch (e) {
      emit (VideoError(
        error: UnknownException(e.toString()),
      ));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('SectionError: $error');
    super.onError(error, stackTrace);
    emit(VideoError(error: error));
  }
}
