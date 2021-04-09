import 'dart:io';

import 'package:tv/blocs/anchorperson/states.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/anchorpersonList.dart';
import 'package:tv/services/anchorpersonService.dart';

abstract class AnchorpersonEvents{
  Stream<AnchorpersonState> run(AnchorpersonRepos anchorpersonRepos);
}

class FetchAnchorpersonList extends AnchorpersonEvents {
  FetchAnchorpersonList();

  @override
  String toString() => 'FetchAnchorpersonList';

  @override
  Stream<AnchorpersonState> run(AnchorpersonRepos anchorpersonRepos) async*{
    print(this.toString());
    try{
      yield AnchorpersonLoading();
      AnchorpersonList anchorpersonList = await anchorpersonRepos.fetchAnchorpersonList();
      yield AnchorpersonListLoaded(anchorpersonList: anchorpersonList);
    } on SocketException {
      yield AnchorpersonError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield AnchorpersonError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield AnchorpersonError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } catch (e) {
      yield AnchorpersonError(
        error: UnknownException(e.toString()),
      );
    }
  }
}