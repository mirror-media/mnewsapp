import 'dart:io';

import 'package:tv/blocs/anchorperson/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';
import 'package:tv/services/contactService.dart';

abstract class AnchorpersonEvents{
  Stream<AnchorpersonState> run(ContactRepos contactRepos);
}

class FetchAnchorpersonList extends AnchorpersonEvents {
  FetchAnchorpersonList();

  @override
  String toString() => 'FetchAnchorpersonList';

  @override
  Stream<AnchorpersonState> run(ContactRepos contactRepos) async*{
    print(this.toString());
    try{
      yield AnchorpersonLoading();
      ContactList contactList = await contactRepos.fetchContactList();
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
  final String contactId;
  FetchAnchorpersonById(this.contactId);

  @override
  String toString() => 'FetchAnchorpersonById : { ContactId : $contactId }';

  @override
  Stream<AnchorpersonState> run(ContactRepos contactRepos) async*{
    print(this.toString());
    try{
      yield AnchorpersonLoading();
      Contact contact = await contactRepos.fetchContactById(contactId);
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