import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/programListItem.dart';
import 'package:tv/services/programListService.dart';

part 'program_list_state.dart';

class ProgramListCubit extends Cubit<ProgramListState> {
  ProgramListCubit() : super(ProgramListInitial());

  void fetchProgramList() async {
    print('FetchProgramList');
    try {
      List<ProgramListItem> programList =
          await ProgramListServices().fetchProgramList();
      emit(ProgramListLoaded(programList: programList));
    } on SocketException {
      emit(ProgramListError(
        error: NoInternetException('No Internet'),
      ));
    } on HttpException {
      emit(ProgramListError(
        error: NoServiceFoundException('No Service Found'),
      ));
    } on FormatException {
      emit(ProgramListError(
        error: InvalidFormatException('Invalid Response format'),
      ));
    } on FetchDataException {
      emit(ProgramListError(
        error: NoInternetException('Error During Communication'),
      ));
    } on BadRequestException {
      emit(ProgramListError(
        error: Error400Exception('Invalid Request'),
      ));
    } on UnauthorisedException {
      emit(ProgramListError(
        error: Error400Exception('Unauthorised'),
      ));
    } on InvalidInputException {
      emit(ProgramListError(
        error: Error400Exception('Invalid Input'),
      ));
    } on InternalServerErrorException {
      emit(ProgramListError(
        error: Error500Exception('Internal Server Error'),
      ));
    } catch (e) {
      emit(ProgramListError(
        error: UnknownException(e.toString()),
      ));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('SectionError: $error');
    super.onError(error, stackTrace);
    emit(ProgramListError(error: error));
  }
}
