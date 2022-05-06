import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/liveCamItem.dart';
import 'package:tv/services/liveService.dart';

part 'liveState.dart';

class LiveCubit extends Cubit<LiveState> {
  LiveCubit() : super(LiveInitial());

  void fetchLiveId(String id) async {
    print('Fetch live id');
    try {
      String liveId = await LiveServices().fetchLiveIdByPostId(id);
      emit(LiveIdLoaded(liveId: liveId));
    } on SocketException {
      emit(LiveError(
        error: NoInternetException('No Internet'),
      ));
    } on HttpException {
      emit(LiveError(
        error: NoServiceFoundException('No Service Found'),
      ));
    } on FormatException {
      emit(LiveError(
        error: InvalidFormatException('Invalid Response format'),
      ));
    } on FetchDataException {
      emit(LiveError(
        error: NoInternetException('Error During Communication'),
      ));
    } on BadRequestException {
      emit(LiveError(
        error: Error400Exception('Invalid Request'),
      ));
    } on UnauthorisedException {
      emit(LiveError(
        error: Error400Exception('Unauthorised'),
      ));
    } on InvalidInputException {
      emit(LiveError(
        error: Error400Exception('Invalid Input'),
      ));
    } on InternalServerErrorException {
      emit(LiveError(
        error: Error500Exception('Internal Server Error'),
      ));
    } catch (e) {
      emit(LiveError(
        error: UnknownException(e.toString()),
      ));
    }
  }

  void fetchLiveIdList(String category) async {
    print('Fetch live id list');
    try {
      List<LiveCamItem> liveCamList =
          await LiveServices().fetchLiveIdByPostCategory(category);
      emit(LiveIdListLoaded(liveCamList: liveCamList));
    } on SocketException {
      emit(LiveError(
        error: NoInternetException('No Internet'),
      ));
    } on HttpException {
      emit(LiveError(
        error: NoServiceFoundException('No Service Found'),
      ));
    } on FormatException {
      emit(LiveError(
        error: InvalidFormatException('Invalid Response format'),
      ));
    } on FetchDataException {
      emit(LiveError(
        error: NoInternetException('Error During Communication'),
      ));
    } on BadRequestException {
      emit(LiveError(
        error: Error400Exception('Invalid Request'),
      ));
    } on UnauthorisedException {
      emit(LiveError(
        error: Error400Exception('Unauthorised'),
      ));
    } on InvalidInputException {
      emit(LiveError(
        error: Error400Exception('Invalid Input'),
      ));
    } on InternalServerErrorException {
      emit(LiveError(
        error: Error500Exception('Internal Server Error'),
      ));
    } catch (e) {
      emit(LiveError(
        error: UnknownException(e.toString()),
      ));
    }
  }
}
