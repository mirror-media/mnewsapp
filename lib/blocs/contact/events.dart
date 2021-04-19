import 'dart:io';

import 'package:tv/blocs/contact/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';
import 'package:tv/services/contactService.dart';

abstract class ContactEvents{
  Stream<ContactState> run(ContactRepos contactRepos);
}

class FetchContactList extends ContactEvents {
  FetchContactList();

  @override
  String toString() => 'FetchContactList';

  @override
  Stream<ContactState> run(ContactRepos contactRepos) async*{
    print(this.toString());
    try{
      yield ContactLoading();
      ContactList contactList = await contactRepos.fetchContactList();
      yield ContactListLoaded(contactList: contactList);
    } on SocketException {
      yield ContactError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield ContactError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield ContactError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield ContactError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield ContactError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield ContactError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield ContactError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield ContactError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield ContactError(
        error: UnknownException(e.toString()),
      );
    }
  }
}

class FetchContactById extends ContactEvents {
  final String contactId;
  FetchContactById(this.contactId);

  @override
  String toString() => 'FetchContactById : { ContactId : $contactId }';

  @override
  Stream<ContactState> run(ContactRepos contactRepos) async*{
    print(this.toString());
    try{
      yield ContactLoading();
      Contact contact = await contactRepos.fetchContactById(contactId);
      yield ContactLoaded(contact: contact);
    } on SocketException {
      yield ContactError(
        error: NoInternetException('No Internet'),
      );
    } on HttpException {
      yield ContactError(
        error: NoServiceFoundException('No Service Found'),
      );
    } on FormatException {
      yield ContactError(
        error: InvalidFormatException('Invalid Response format'),
      );
    } on FetchDataException {
      yield ContactError(
        error: NoInternetException('Error During Communication'),
      );
    } on BadRequestException {
      yield ContactError(
        error: Error400Exception('Invalid Request'),
      );
    } on UnauthorisedException {
      yield ContactError(
        error: Error400Exception('Unauthorised'),
      );
    } on InvalidInputException {
      yield ContactError(
        error: Error400Exception('Invalid Input'),
      );
    } on InternalServerErrorException {
      yield ContactError(
        error: Error500Exception('Internal Server Error'),
      );
    } catch (e) {
      yield ContactError(
        error: UnknownException(e.toString()),
      );
    }
  }
}