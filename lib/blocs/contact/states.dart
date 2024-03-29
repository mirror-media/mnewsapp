import 'package:tv/models/contact.dart';

abstract class ContactState {}

class ContactInitState extends ContactState {}

class ContactLoading extends ContactState {}

class ContactListLoaded extends ContactState {
  final List<Contact> contactList;
  ContactListLoaded({required this.contactList});
}

class ContactLoaded extends ContactState {
  final Contact contact;
  ContactLoaded({required this.contact});
}

class ContactError extends ContactState {
  final error;
  ContactError({this.error});
}
