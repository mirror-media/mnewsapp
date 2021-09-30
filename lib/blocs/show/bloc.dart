import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/show/events.dart';
import 'package:tv/blocs/show/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/services/showService.dart';

class ShowIntroBloc extends Bloc<ShowEvents, ShowState> {
  final ShowRepos showRepos;

  ShowIntroBloc({required this.showRepos}) : super(ShowInitState());

  @override
  Stream<ShowState> mapEventToState(ShowEvents event) async* {
    print(event.toString());
    try {
      yield ShowLoading();
      if (event is FetchShowIntro) {
        ShowIntro showIntro =
            await showRepos.fetchShowIntroById(event.showCategoryId);
        String jsonFixed = await rootBundle.loadString(adUnitIdJson);
        final fixedAdUnitId = json.decode(jsonFixed);
        AdUnitId adUnitId = AdUnitId.fromJson(fixedAdUnitId, 'show');
        yield ShowIntroLoaded(showIntro: showIntro, adUnitId: adUnitId);
      }
    } on SocketException {
      yield ShowError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield ShowError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield ShowError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } catch (e) {
      yield ShowError(
        error: UnknownException(e.toString()),
      );
    }
  }
}
