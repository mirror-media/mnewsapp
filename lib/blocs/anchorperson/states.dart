import 'package:tv/models/contact.dart';
import 'package:tv/models/contactList.dart';

abstract class AnchorpersonState {}

class AnchorpersonInitState extends AnchorpersonState {}

class AnchorpersonLoading extends AnchorpersonState {}

class AnchorpersonListLoaded extends AnchorpersonState {
  final ContactList contactList;
  AnchorpersonListLoaded({this.contactList});
}

class AnchorpersonLoaded extends AnchorpersonState {
  final Contact contact;
  AnchorpersonLoaded({this.contact});
}

class AnchorpersonError extends AnchorpersonState {
  final error;
  AnchorpersonError({this.error});
}
