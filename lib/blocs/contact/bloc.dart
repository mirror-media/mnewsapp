import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv/blocs/contact/events.dart';
import 'package:tv/blocs/contact/states.dart';
import 'package:tv/helpers/apiException.dart';
import 'package:tv/helpers/exceptions.dart';
import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';
import 'package:tv/services/contactService.dart';

class ContactBloc extends Bloc<ContactEvents, ContactState> {
  final ContactRepos contactRepos;

  ContactBloc({required this.contactRepos}) : super(ContactInitState());

  @override
  Stream<ContactState> mapEventToState(ContactEvents event) async* {
    print(event.toString());
    try {
      yield ContactLoading();
      if (event is FetchAnchorpersonOrHostContactList) {
        ContactList contactList =
            await contactRepos.fetchAnchorpersonOrHostContactList();
        yield ContactListLoaded(contactList: contactList);
      } else if (event is FetchContactById) {
        Contact contact = await contactRepos.fetchContactById(event.contactId);
        yield ContactLoaded(contact: contact);
      }
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
