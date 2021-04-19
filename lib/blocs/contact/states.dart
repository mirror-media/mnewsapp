import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';

abstract class ContactState {}

class ContactInitState extends ContactState {}

class ContactLoading extends ContactState {}

class ContactListLoaded extends ContactState {
  final ContactList contactList;
  ContactListLoaded({this.contactList});
}

class ContactLoaded extends ContactState {
  final Contact contact;
  ContactLoaded({this.contact});
}

class ContactError extends ContactState {
  final error;
  ContactError({this.error});
}
