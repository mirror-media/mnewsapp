

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tv/blocs/show/states.dart';
import 'package:tv/helpers/dataConstants.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/adUnitId.dart';
import 'package:tv/models/showIntro.dart';
import 'package:tv/services/showService.dart';

abstract class ShowEvents{
  Stream<ShowState> run(ShowRepos showRepos);
}

class FetchShowIntro extends ShowEvents {
  final String showCategoryId;
  FetchShowIntro(this.showCategoryId);
  @override
  String toString() => 'FetchShowIntro { ShowCategoryId: $showCategoryId }';

  @override
  Stream<ShowState> run(ShowRepos showRepos) async*{
    print(this.toString());
    try{
      yield ShowLoading();
      ShowIntro showIntro = await showRepos.fetchShowIntroById(showCategoryId);
      String jsonFixed = await rootBundle.loadString(adUnitIdJson);
      final fixedAdUnitId = json.decode(jsonFixed);
      AdUnitId adUnitId = AdUnitId.fromJson(fixedAdUnitId,'show');
      yield ShowIntroLoaded(showIntro: showIntro, adUnitId: adUnitId);
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