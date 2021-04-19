import 'dart:io';

import 'package:tv/blocs/anchorperson/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';
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
      ContactList contactList = await anchorpersonRepos.fetchAnchorpersonList();
      yield AnchorpersonListLoaded(contactList: contactList);
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
    } on FetchDataException {
      yield AnchorpersonError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield AnchorpersonError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield AnchorpersonError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield AnchorpersonError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield AnchorpersonError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield AnchorpersonError(
        error: UnknownException(e.toString()),
      );
    }
  }
}

class FetchAnchorpersonById extends AnchorpersonEvents {
  final String anchorpersonId;
  FetchAnchorpersonById(this.anchorpersonId);

  @override
  String toString() => 'FetchAnchorpersonById : { AnchorpersonId : $anchorpersonId }';

  @override
  Stream<AnchorpersonState> run(AnchorpersonRepos anchorpersonRepos) async*{
    print(this.toString());
    try{
      yield AnchorpersonLoading();
      Contact contact = await anchorpersonRepos.fetchAnchorpersonById(anchorpersonId);
      yield AnchorpersonLoaded(contact: contact);
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
    } on FetchDataException {
      yield AnchorpersonError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield AnchorpersonError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield AnchorpersonError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield AnchorpersonError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield AnchorpersonError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield AnchorpersonError(
        error: UnknownException(e.toString()),
      );
    }
  }
}